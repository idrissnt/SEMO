"""
Stripe implementation of payment method service interface.

This module contains the concrete implementation of the payment method service interface
using Stripe as the payment provider. It uses the StripeGateway to interact with
the Stripe API and maps between domain entities and Stripe-specific concepts.
"""
from typing import Dict, Any, Optional, Tuple, List
from uuid import UUID
import uuid
import logging

from payments.domain.models.entities import PaymentMethod
from payments.domain.models.constants import PaymentMethodTypes
from payments.domain.services.payment_service_interface import PaymentMethodServiceInterface
from payments.domain.repositories.payment_method_repository_interfaces import PaymentMethodRepository
from payments.infrastructure.external.stripe_gateway import StripeGateway

logger = logging.getLogger(__name__)


class StripePaymentMethodService(PaymentMethodServiceInterface):
    """
    Stripe implementation of the payment method service interface.
    
    This service handles payment method operations using Stripe as the payment provider.
    It uses the StripeGateway to interact with the Stripe API and the payment method
    repository to store and retrieve payment method information.
    """
    
    def __init__(self, payment_method_repository: PaymentMethodRepository):
        """
        Initialize the service with required dependencies.
        
        Args:
            payment_method_repository: Repository for payment method entities
        """
        self.payment_method_repository = payment_method_repository
        self.stripe_gateway = StripeGateway()
    
    def create_setup_intent(self, user_id: UUID, payment_method_id: Optional[str] = None) -> Tuple[bool, str, Dict[str, Any]]:
        try:
            # Try to get existing customer ID
            customer_id = self.payment_method_repository.get_or_create_customer_id(user_id)
        except ValueError:
            # No customer ID found, create a new one in Stripe
            try:
                # Create a new customer in Stripe
                customer_id = self.stripe_gateway.create_customer(user_id=str(user_id))
                
                # Save the customer ID with a placeholder payment method
                self._save_customer_id(user_id, customer_id)
                
                logger.info(f"Created new Stripe customer for user {user_id}: {customer_id}")
            except Exception as e:
                error_msg = f"Failed to create customer in Stripe: {str(e)}"
                logger.error(error_msg)
                return False, error_msg, {}
        
        # Create a setup intent using the Stripe gateway
        result = self.stripe_gateway.create_setup_intent(
            customer_id=customer_id,
            payment_method_id=payment_method_id
        )
        
        if not result['success']:
            return False, result.get('error', 'Failed to create setup intent'), {}
        
        return True, 'Setup intent created successfully', {
            'client_secret': result['client_secret'],
            'setup_intent_id': result['setup_intent_id']
        }
    
    def confirm_setup_intent(self, setup_intent_id: str, user_id: UUID) -> Tuple[bool, str, Optional[PaymentMethod]]:
        # Confirm the setup intent using the Stripe gateway
        result = self.stripe_gateway.confirm_setup_intent(setup_intent_id)
        
        if not result['success']:
            return False, result.get('error', 'Failed to confirm setup intent'), None
        
        if result['status'] != 'succeeded':
            return False, f"Setup intent has status: {result['status']}", None
        
        # Get the payment method details
        payment_method_id = result['payment_method_id']
        payment_method_result = self.stripe_gateway.retrieve_payment_method(payment_method_id)
        
        if not payment_method_result['success']:
            return False, payment_method_result.get('error', 'Failed to retrieve payment method'), None
        
        # Get or create a customer ID for the user
        try:
            customer_id = self.payment_method_repository.get_or_create_customer_id(user_id)
        except ValueError as e:
            return False, str(e), None
        
        # Create a new payment method entity
        payment_method = PaymentMethod(
            id=payment_method_id,
            user_id=user_id,
            type=payment_method_result['type'],
            is_default=False,
            last_four=payment_method_result.get('last_four'),
            expiry_month=payment_method_result.get('expiry_month'),
            expiry_year=payment_method_result.get('expiry_year'),
            card_brand=payment_method_result.get('card_brand'),
            external_customer_id=customer_id,
            billing_details=payment_method_result.get('billing_details')
        )
        
        # Save the payment method
        created_payment_method = self.payment_method_repository.create(payment_method)
        
        return True, 'Payment method saved successfully', created_payment_method
    
    def set_default_payment_method(self, user_id: UUID, payment_method_id: str) -> Tuple[bool, str]:

        # Check if the payment method exists and belongs to the user
        payment_method = self.payment_method_repository.get_by_id(payment_method_id)
        if not payment_method:
            return False, f"Payment method with ID {payment_method_id} not found"
        
        if payment_method.user_id != user_id:
            return False, "Payment method does not belong to this user"
        
        # Set the payment method as default
        success = self.payment_method_repository.set_default(user_id, payment_method_id)
        
        if not success:
            return False, "Failed to set payment method as default"
        
        return True, "Payment method set as default"
    
    def delete_payment_method(self, payment_method_id: str, user_id: UUID) -> Tuple[bool, str]:

        # Check if the payment method exists and belongs to the user
        payment_method = self.payment_method_repository.get_by_id(payment_method_id)
        if not payment_method:
            return False, f"Payment method with ID {payment_method_id} not found"
        
        if payment_method.user_id != user_id:
            return False, "Payment method does not belong to this user"
        
        # Detach the payment method from the customer in Stripe
        result = self.stripe_gateway.detach_payment_method(payment_method_id)
        
        if not result['success']:
            return False, result.get('error', 'Failed to detach payment method')
        
        # Delete the payment method from the repository
        success = self.payment_method_repository.delete(payment_method_id)
        
        if not success:
            return False, "Failed to delete payment method"
        
        return True, "Payment method deleted successfully"
    
    def get_payment_methods(self, user_id: UUID) -> List[PaymentMethod]:
        return self.payment_method_repository.get_by_user_id(user_id)
    
    def get_default_payment_method(self, user_id: UUID) -> Optional[PaymentMethod]:
        return self.payment_method_repository.get_default_for_user(user_id)
    
    def _save_customer_id(self, user_id: UUID, customer_id: str) -> None:
        """
        Save a Stripe customer ID to a placeholder payment method
        
        This creates a placeholder payment method record with the customer ID,
        so that future calls to get_or_create_customer_id will find this customer ID.
        
        Args:
            user_id: The ID of the user
            customer_id: The Stripe customer ID to save
        """
        # Create a placeholder payment method with the customer ID
        from datetime import datetime
        
        placeholder_method = PaymentMethod(
            id=str(uuid.uuid4()),
            user_id=user_id,
            type=PaymentMethodTypes.CARD,  # Placeholder type
            is_default=False,
            last_four="0000",  # Placeholder value
            external_customer_id=customer_id,
            created_at=datetime.now()
        )
        
        # Save the placeholder payment method
        self.payment_method_repository.create(placeholder_method)
        logger.info(f"Saved customer ID {customer_id} for user {user_id}")
