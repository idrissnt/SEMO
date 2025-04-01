"""
Stripe implementation of payment service interface.

This module contains the concrete implementation of the payment service interface
using Stripe as the payment provider. It uses the StripeGateway to interact with
the Stripe API and maps between domain entities and Stripe-specific concepts.
"""
from typing import Dict, Any, Optional, Tuple
from uuid import UUID
import logging

logger = logging.getLogger(__name__)

from payments.domain.models.entities import Payment
from payments.domain.services.payment_service_interface import PaymentServiceInterface
from payments.domain.repositories.payment_repository_interfaces import PaymentRepository
from payments.infrastructure.external.stripe_gateway import StripeGateway


class StripePaymentService(PaymentServiceInterface):
    """
    Stripe implementation of the payment service interface.
    
    This service handles payment operations using Stripe as the payment provider.
    It uses the StripeGateway to interact with the Stripe API and the payment
    repository to store and retrieve payment information.
    """
    
    def __init__(self, payment_repository: PaymentRepository):
        """
        Initialize the service with required dependencies.
        
        Args:
            payment_repository: Repository for payment entities
        """
        self.payment_repository = payment_repository
        self.stripe_gateway = StripeGateway()
    
    def create_payment_intent(self, payment_id: UUID, payment_method_id: Optional[str] = None,
                             customer_id: Optional[str] = None,
                             setup_future_usage: Optional[str] = None) -> Tuple[bool, str, Dict[str, Any]]:

        # Get the payment from the repository
        payment = self.payment_repository.get_by_id(payment_id)
        if not payment:
            return False, f"Payment with ID {payment_id} not found", {}
        
        # Create a payment intent using the Stripe gateway
        result = self.stripe_gateway.create_payment_intent(
            amount=payment.amount,
            currency=payment.currency,
            payment_method_id=payment_method_id,
            customer_id=customer_id,
            setup_future_usage=setup_future_usage,
            metadata={'payment_id': str(payment_id)}
        )
        
        if not result['success']:
            return False, result.get('error', 'Failed to create payment intent'), {}
        
        # Update the payment with the payment intent details
        payment.external_id = result['payment_intent_id']
        payment.external_client_secret = result['client_secret']
        payment.mark_as_processing()
        
        # Save the updated payment
        self.payment_repository.update(payment)
        
        return True, 'Payment intent created successfully', {
            'client_secret': result['client_secret'],
            'payment_intent_id': result['payment_intent_id']
        }
    
    def confirm_payment_intent(self, payment_intent_id: str) -> Tuple[bool, str, Optional[Payment]]:

        # Get the payment by its external ID (payment intent ID)
        payment = self.payment_repository.get_by_external_id(payment_intent_id)
        if not payment:
            return False, f"No payment found for payment intent {payment_intent_id}", None
        
        # Check the payment intent status using the Stripe gateway
        result = self.stripe_gateway.retrieve_payment_intent(payment_intent_id)
        
        if not result['success']:
            return False, result.get('error', 'Failed to retrieve payment intent'), None
        
        # Update the payment status based on the payment intent status
        if result['status'] == 'succeeded':
            payment.mark_as_completed()
        elif result['status'] == 'requires_action':
            payment.mark_as_requires_action()
        elif result['status'] in ['requires_payment_method', 'canceled']:
            payment.mark_as_failed()
        
        # Save the updated payment
        updated_payment = self.payment_repository.update(payment)
        
        return True, f"Payment intent status: {result['status']}", updated_payment
    
    def get_payment_status(self, payment_id: UUID) -> str:

        payment = self.payment_repository.get_by_id(payment_id)
        if not payment:
            raise ValueError(f"Payment with ID {payment_id} not found")
        
        # If the payment has an external ID, check its status with Stripe
        if payment.external_id:
            result = self.stripe_gateway.retrieve_payment_intent(payment.external_id)
            if result['success']:
                # Map Stripe status to our domain status
                if result['status'] == 'succeeded':
                    payment.mark_as_completed()
                elif result['status'] == 'requires_action':
                    payment.mark_as_requires_action()
                elif result['status'] in ['requires_payment_method', 'canceled']:
                    payment.mark_as_failed()
                
                # Update the payment in the repository
                self.payment_repository.update(payment)
        
        return payment.status
    
    def refund_payment(self, payment_id: UUID, amount: Optional[float] = None) -> Tuple[bool, str]:

        payment = self.payment_repository.get_by_id(payment_id)
        if not payment:
            return False, f"Payment with ID {payment_id} not found"
        
        if not payment.external_id:
            return False, "Payment has no associated payment intent"
        
        if not payment.is_completed():
            return False, f"Cannot refund payment with status {payment.status}"
        
        # Calculate the refund amount in cents
        refund_amount = amount if amount is not None else payment.amount
        
        # Create a refund using the Stripe gateway
        result = self.stripe_gateway.create_refund(
            payment_intent_id=payment.external_id,
            amount=refund_amount
        )
        
        if not result['success']:
            return False, result.get('error', 'Failed to create refund')
        
        # If it's a full refund, update the payment status
        if amount is None or amount >= payment.amount:
            payment.status = 'refunded'
            self.payment_repository.update(payment)
        
        return True, 'Refund processed successfully'



