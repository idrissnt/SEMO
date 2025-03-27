import uuid
from typing import Tuple, Optional, Dict, Any, List
from decimal import Decimal

import stripe
from django.conf import settings

from payments.domain.models.entities import Payment, PaymentMethod, PaymentTransaction
from payments.domain.repositories.repository_interfaces import (
    PaymentRepository, 
    PaymentMethodRepository,
    PaymentTransactionRepository
)
from core.domain_events.events import PaymentCreatedEvent, PaymentCompletedEvent, PaymentFailedEvent, PaymentMethodAddedEvent
from core.domain_events.event_bus import event_bus

# Configure Stripe
stripe.api_key = settings.STRIPE_SECRET_KEY


class PaymentApplicationService:
    """Application service for payment operations"""
    
    def __init__(
        self,
        payment_repository: PaymentRepository,
        payment_method_repository: PaymentMethodRepository,
        payment_transaction_repository: PaymentTransactionRepository
    ):
        self.payment_repository = payment_repository
        self.payment_method_repository = payment_method_repository
        self.payment_transaction_repository = payment_transaction_repository
    
    def create_payment(
        self, 
        order_id: uuid.UUID, 
        payment_method: str, 
        amount: float
    ) -> Tuple[bool, str, Optional[Payment]]:
        """Create a new payment for an order"""
        # Check if payment already exists for this order
        existing_payment = self.payment_repository.get_by_order_id(order_id)
        if existing_payment:
            return False, f"Payment already exists for order {order_id}", None
        
        # Create new payment
        payment = Payment(
            id=uuid.uuid4(),
            order_id=order_id,
            payment_method=payment_method,
            status='pending',
            amount=amount,
            transaction_id=None
        )
        
        try:
            created_payment = self.payment_repository.create(payment)
            
            # Publish payment created event
            event_bus.publish(PaymentCreatedEvent.create(
                payment_id=created_payment.id,
                order_id=created_payment.order_id,
                amount=created_payment.amount,
                payment_method=created_payment.payment_method
            ))
            
            return True, "Payment created successfully", created_payment
        except Exception as e:
            return False, f"Failed to create payment: {str(e)}", None
    
    def process_payment(
        self, 
        payment_id: uuid.UUID, 
        payment_method_id: str
    ) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Process a payment using Stripe"""
        # Get the payment
        payment = self.payment_repository.get_by_id(payment_id)
        if not payment:
            return False, f"Payment with ID {payment_id} not found", None
        
        # Check if payment is in pending status
        if payment.status != 'pending':
            return False, f"Payment is already {payment.status}", None
        
        try:
            # Create Stripe PaymentIntent
            intent = stripe.PaymentIntent.create(
                amount=int(payment.amount * 100),  # Stripe uses cents
                currency='usd',
                payment_method=payment_method_id,
                confirmation_method='manual',
                confirm=True,
                metadata={
                    'payment_id': str(payment.id),
                    'order_id': str(payment.order_id)
                }
            )
            
            # Create transaction record
            transaction = PaymentTransaction(
                id=uuid.uuid4(),
                payment_id=payment.id,
                transaction_type='authorization',
                status='pending',
                amount=payment.amount,
                provider_transaction_id=intent.id
            )
            self.payment_transaction_repository.create(transaction)
            
            # Handle different PaymentIntent statuses
            if intent.status == 'succeeded':
                # Update payment status
                payment.status = 'completed'
                payment.transaction_id = intent.id
                self.payment_repository.update(payment)
                
                # Update transaction status
                transaction.status = 'success'
                self.payment_transaction_repository.create(transaction)
                
                # Publish payment completed event
                event_bus.publish(PaymentCompletedEvent(
                    order_id=payment.order_id,
                    payment_id=payment.id,
                    amount=payment.amount
                ))
                
                return True, "Payment processed successfully", {
                    'status': 'completed',
                    'transaction_id': intent.id
                }
            
            # Requires 3D Secure authentication
            elif intent.status == 'requires_action' and intent.next_action.type == 'use_stripe_sdk':
                return True, "Payment requires authentication", {
                    'requires_action': True,
                    'client_secret': intent.client_secret,
                    'payment_intent_id': intent.id
                }
            
            else:
                # Update payment status
                payment.status = 'failed'
                self.payment_repository.update(payment)
                
                # Update transaction status
                transaction.status = 'failed'
                transaction.error_message = f"Unexpected payment intent status: {intent.status}"
                self.payment_transaction_repository.create(transaction)
                
                # Publish payment failed event
                event_bus.publish(PaymentFailedEvent(
                    order_id=payment.order_id,
                    payment_id=payment.id,
                    error_message=f"Unexpected payment intent status: {intent.status}"
                ))
                
                return False, f"Payment failed with status: {intent.status}", None
                
        except stripe.error.CardError as e:
            # Card was declined
            payment.status = 'failed'
            self.payment_repository.update(payment)
            
            # Create failed transaction record
            transaction = PaymentTransaction(
                id=uuid.uuid4(),
                payment_id=payment.id,
                transaction_type='authorization',
                status='failed',
                amount=payment.amount,
                provider_transaction_id=e.payment_intent.id if hasattr(e, 'payment_intent') else 'card_error',
                error_message=e.user_message
            )
            self.payment_transaction_repository.create(transaction)
            
            # Publish payment failed event
            event_bus.publish(PaymentFailedEvent(
                order_id=payment.order_id,
                payment_id=payment.id,
                error_message=e.user_message
            ))
            
            return False, e.user_message, None
            
        except stripe.error.StripeError as e:
            # Generic Stripe error
            payment.status = 'failed'
            self.payment_repository.update(payment)
            
            # Create failed transaction record
            transaction = PaymentTransaction(
                id=uuid.uuid4(),
                payment_id=payment.id,
                transaction_type='authorization',
                status='failed',
                amount=payment.amount,
                provider_transaction_id='stripe_error',
                error_message=str(e)
            )
            self.payment_transaction_repository.create(transaction)
            
            # Publish payment failed event
            event_bus.publish(PaymentFailedEvent(
                order_id=payment.order_id,
                payment_id=payment.id,
                error_message=str(e)
            ))
            
            return False, f"Payment processing error: {str(e)}", None
            
        except Exception as e:
            # Unexpected error
            payment.status = 'failed'
            self.payment_repository.update(payment)
            
            # Create failed transaction record
            transaction = PaymentTransaction(
                id=uuid.uuid4(),
                payment_id=payment.id,
                transaction_type='authorization',
                status='failed',
                amount=payment.amount,
                provider_transaction_id='system_error',
                error_message=str(e)
            )
            self.payment_transaction_repository.create(transaction)
            
            # Publish payment failed event
            event_bus.publish(PaymentFailedEvent(
                order_id=payment.order_id,
                payment_id=payment.id,
                error_message=str(e)
            ))
            
            return False, f"Unexpected error: {str(e)}", None
    
    def confirm_payment(
        self, 
        payment_intent_id: str
    ) -> Tuple[bool, str, Optional[Payment]]:
        """Confirm a payment after 3D Secure authentication"""
        try:
            intent = stripe.PaymentIntent.retrieve(payment_intent_id)
            
            # Find the payment by transaction ID
            transactions = self.payment_transaction_repository.get_by_provider_transaction_id(payment_intent_id)
            if not transactions:
                return False, f"No transaction found for payment intent {payment_intent_id}", None
            
            payment_id = transactions[0].payment_id if isinstance(transactions, list) else transactions.payment_id
            payment = self.payment_repository.get_by_id(payment_id)
            
            if not payment:
                return False, f"Payment not found for transaction {payment_intent_id}", None
            
            if intent.status == 'succeeded':
                # Update payment status
                payment.status = 'completed'
                payment.transaction_id = intent.id
                updated_payment = self.payment_repository.update(payment)
                
                # Create success transaction record
                transaction = PaymentTransaction(
                    id=uuid.uuid4(),
                    payment_id=payment.id,
                    transaction_type='capture',
                    status='success',
                    amount=payment.amount,
                    provider_transaction_id=intent.id
                )
                self.payment_transaction_repository.create(transaction)
                
                # Publish payment completed event
                event_bus.publish(PaymentCompletedEvent(
                    order_id=payment.order_id,
                    payment_id=payment.id,
                    amount=payment.amount
                ))
                
                return True, "Payment confirmed successfully", updated_payment
            else:
                # Update payment status
                payment.status = 'failed'
                self.payment_repository.update(payment)
                
                # Create failed transaction record
                transaction = PaymentTransaction(
                    id=uuid.uuid4(),
                    payment_id=payment.id,
                    transaction_type='capture',
                    status='failed',
                    amount=payment.amount,
                    provider_transaction_id=intent.id,
                    error_message=f"Payment intent status: {intent.status}"
                )
                self.payment_transaction_repository.create(transaction)
                
                # Publish payment failed event
                event_bus.publish(PaymentFailedEvent(
                    order_id=payment.order_id,
                    payment_id=payment.id,
                    error_message=f"Payment intent status: {intent.status}"
                ))
                
                return False, f"Payment confirmation failed with status: {intent.status}", None
                
        except Exception as e:
            return False, f"Error confirming payment: {str(e)}", None
    
    def get_payment_by_id(self, payment_id: uuid.UUID) -> Optional[Payment]:
        """Get a payment by ID"""
        return self.payment_repository.get_by_id(payment_id)
    
    def get_payment_by_order_id(self, order_id: uuid.UUID) -> Optional[Payment]:
        """Get a payment by order ID"""
        return self.payment_repository.get_by_order_id(order_id)
    
    def get_payment_methods_for_user(self, user_id: uuid.UUID) -> List[PaymentMethod]:
        """Get all payment methods for a user"""
        return self.payment_method_repository.get_by_user_id(user_id)
    
    def get_default_payment_method(self, user_id: uuid.UUID) -> Optional[PaymentMethod]:
        """Get the default payment method for a user"""
        return self.payment_method_repository.get_default_for_user(user_id)
    
    def add_payment_method(
        self, 
        user_id: uuid.UUID, 
        payment_method_id: str,
        payment_method_type: str,
        set_as_default: bool = False,
        card_details: Optional[Dict[str, Any]] = None
    ) -> Tuple[bool, str, Optional[PaymentMethod]]:
        """Add a new payment method for a user"""
        try:
            # Retrieve payment method details from Stripe if card_details not provided
            if not card_details and payment_method_type == 'credit_card':
                stripe_payment_method = stripe.PaymentMethod.retrieve(payment_method_id)
                card_details = {
                    'last_four': stripe_payment_method.card.last4,
                    'expiry_month': stripe_payment_method.card.exp_month,
                    'expiry_year': stripe_payment_method.card.exp_year,
                    'card_brand': stripe_payment_method.card.brand
                }
            
            # Create payment method entity
            payment_method = PaymentMethod(
                id=payment_method_id,
                user_id=user_id,
                type=payment_method_type,
                is_default=set_as_default,
                last_four=card_details.get('last_four') if card_details else None,
                expiry_month=card_details.get('expiry_month') if card_details else None,
                expiry_year=card_details.get('expiry_year') if card_details else None,
                card_brand=card_details.get('card_brand') if card_details else None
            )
            
            # Save to repository
            created_payment_method = self.payment_method_repository.create(payment_method)
            
            # Publish payment method added event
            event_bus.publish(PaymentMethodAddedEvent.create(
                payment_method_id=created_payment_method.id,
                user_id=created_payment_method.user_id,
                is_default=created_payment_method.is_default,
                payment_method_type=created_payment_method.type
            ))
            
            return True, "Payment method added successfully", created_payment_method
            
        except Exception as e:
            return False, f"Failed to add payment method: {str(e)}", None
    
    def remove_payment_method(
        self, 
        user_id: uuid.UUID, 
        payment_method_id: str
    ) -> Tuple[bool, str]:
        """Remove a payment method"""
        # Check if payment method exists and belongs to the user
        payment_method = self.payment_method_repository.get_by_id(payment_method_id)
        if not payment_method or payment_method.user_id != user_id:
            return False, "Payment method not found or doesn't belong to the user"
        
        # Delete from Stripe if it's a card
        try:
            if payment_method.type in ['credit_card', 'debit_card']:
                stripe.PaymentMethod.detach(payment_method_id)
        except Exception as e:
            # Log the error but continue with local deletion
            print(f"Error detaching payment method from Stripe: {str(e)}")
        
        # Delete from repository
        success = self.payment_method_repository.delete(payment_method_id)
        if success:
            return True, "Payment method removed successfully"
        else:
            return False, "Failed to remove payment method"
    
    def set_default_payment_method(
        self, 
        user_id: uuid.UUID, 
        payment_method_id: str
    ) -> Tuple[bool, str]:
        """Set a payment method as default"""
        # Check if payment method exists and belongs to the user
        payment_method = self.payment_method_repository.get_by_id(payment_method_id)
        if not payment_method or payment_method.user_id != user_id:
            return False, "Payment method not found or doesn't belong to the user"
        
        # Set as default
        success = self.payment_method_repository.set_default(user_id, payment_method_id)
        if success:
            return True, "Default payment method updated successfully"
        else:
            return False, "Failed to update default payment method"
    
    def get_payment_transactions(self, payment_id: uuid.UUID) -> List[PaymentTransaction]:
        """Get all transactions for a payment"""
        return self.payment_transaction_repository.get_by_payment_id(payment_id)
