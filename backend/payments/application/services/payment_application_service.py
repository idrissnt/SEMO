"""
Payment application service that orchestrates payment operations.

This service uses the domain service interfaces to perform payment operations
and coordinates between different domain services and repositories.
"""
from typing import Dict, Any, Optional, Tuple, List
from uuid import UUID

from payments.domain.models.entities import Payment
from payments.domain.services.payment_service_interface import PaymentServiceInterface
from payments.domain.repositories.payment_repository_interfaces import PaymentRepository
from core.domain_events.event_bus import event_bus
from payments.domain.events.payment_events import (
    PaymentCreatedEvent,
    PaymentCompletedEvent
)


class PaymentApplicationService:
    """
    Application service for payment operations.
    
    This service orchestrates payment operations by coordinating between
    domain services, repositories, and the event bus. It implements
    the application-specific use cases related to payments.
    """
    
    def __init__(
        self,
        payment_service: PaymentServiceInterface,
        payment_repository: PaymentRepository
    ):
        """
        Initialize the service with required dependencies.
        
        Args:
            payment_service: Service for payment operations
            payment_repository: Repository for payment entities
        """
        self.payment_service = payment_service
        self.payment_repository = payment_repository
    
    def get_or_create_payment(self, order_id: UUID, amount: float, currency: str = 'eur',
                      metadata: Optional[Dict[str, Any]] = None) -> Tuple[str, Optional[Payment]]:
        """
        Get or create a payment for an order.
        
        Args:
            order_id: The ID of the order to create a payment for
            amount: The amount to charge
            currency: The currency to use (default: 'eur')
            metadata: Optional metadata to associate with the payment
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Created Payment entity if successful, None otherwise
        """
        # Check if a payment already exists for this order
        existing_payment = self.payment_repository.get_by_order_id(order_id)
        if existing_payment:
            return f"Payment already exists for order {order_id}", existing_payment
        
        # Create a new payment
        from uuid import uuid4
        
        payment = Payment(
            id=uuid4(),
            order_id=order_id,
            amount=amount,
            currency=currency,
            metadata=metadata,
        )
        
        # Create and save the payment
        created_payment = self.payment_repository.create(payment)
        
        # Publish a payment created event
        event_bus.publish(PaymentCreatedEvent.create(
            payment_id=str(created_payment.id),
            order_id=str(created_payment.order_id),
            amount=created_payment.amount,
            currency=created_payment.currency
        ))
        
        return "Payment created successfully", created_payment
    
    def create_payment_intent(self, payment_id: UUID, payment_method_id: Optional[str] = None,
                             customer_id: Optional[str] = None,
                             setup_future_usage: Optional[str] = None) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Create a payment intent for a payment (using the record created by create_payment).
        
        Args:
            payment_id: The ID of the payment to create an intent for
            payment_method_id: Optional ID of the payment method to use
            customer_id: Optional customer ID for the payment
            setup_future_usage: Optional flag to indicate if the payment method should be saved
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Dictionary with payment intent details (client_secret, etc.)
        """
        return self.payment_service.create_payment_intent(
            payment_id=payment_id,
            payment_method_id=payment_method_id,
            customer_id=customer_id,
            setup_future_usage=setup_future_usage
        )
    
    def confirm_payment_intent(self, payment_intent_id: str) -> Tuple[bool, str, Optional[Payment]]:
        """
        Confirm a payment intent after client-side confirmation.
        
        Args:
            payment_intent_id: The ID of the payment intent to confirm
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Updated Payment entity if successful, None otherwise
        """
        success, message, payment = self.payment_service.confirm_payment_intent(payment_intent_id)
        
        # If the payment was completed successfully, publish an event
        if success and payment and payment.is_completed():
            event_bus.publish(PaymentCompletedEvent.create(
                payment_id=str(payment.id),
                order_id=str(payment.order_id),
                amount=payment.amount,
                currency=payment.currency
            ))
        
        return success, message, payment
    
    def get_payment(self, payment_id: UUID) -> Optional[Payment]:
        """
        Get a payment by ID.
        
        Args:
            payment_id: The ID of the payment to get
            
        Returns:
            Payment entity if found, None otherwise
        """
        return self.payment_repository.get_by_id(payment_id)
    
    def get_payment_status(self, payment_id: UUID) -> str:
        """
        Get the current status of a payment.
        
        Args:
            payment_id: The ID of the payment to check
            
        Returns:
            String representing the payment status
        """
        return self.payment_service.get_payment_status(payment_id)
    
    def get_user_payments(self, user_id: UUID) -> List[Payment]:
        """
        Get all payments for a user.
        
        Args:
            user_id: The ID of the user
            
        Returns:
            List of Payment entities
        """
        return self.payment_repository.get_by_user_id(user_id)
    
    def payment_belongs_to_user(self, payment_id: UUID, user_id: UUID) -> bool:
        """
        Check if a payment belongs to a user.
        
        Args:
            payment_id: The ID of the payment to check
            user_id: The ID of the user
            
        Returns:
            True if the payment belongs to the user, False otherwise
        """
        return self.payment_repository.belongs_to_user(payment_id, user_id)
    
    def refund_payment(self, payment_id: UUID, amount: Optional[float] = None) -> Tuple[bool, str]:
        """
        Refund a payment, either partially or fully.
        
        Args:
            payment_id: The ID of the payment to refund
            amount: Optional amount to refund (if None, refund the full amount)
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
        """
        return self.payment_service.refund_payment(payment_id, amount)
    

