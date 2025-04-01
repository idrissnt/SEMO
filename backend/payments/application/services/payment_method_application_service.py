"""
Payment method application service that orchestrates payment method operations.

This service uses the domain service interfaces to perform payment method operations
and coordinates between different domain services and repositories.
"""
from typing import Dict, Any, Optional, Tuple, List
from uuid import UUID

from payments.domain.models.entities import PaymentMethod
from payments.domain.services.payment_method_service_interface import PaymentMethodServiceInterface


class PaymentMethodApplicationService:
    """
    Application service for payment method operations.
    
    This service orchestrates payment method operations by coordinating between
    domain services and repositories. It implements the application-specific
    use cases related to payment methods.
    """
    
    def __init__(self, payment_method_service: PaymentMethodServiceInterface):
        """
        Initialize the service with required dependencies.
        
        Args:
            payment_method_service: Service for payment method operations
        """
        self.payment_method_service = payment_method_service
    
    def add_payment_method(self, user_id: UUID, payment_method_id: str,
                          set_as_default: bool = False) -> Tuple[bool, str, Optional[PaymentMethod]]:
        """
        Add a payment method for a user.
        
        Args:
            user_id: The ID of the user
            payment_method_id: The ID of the payment method to add
            set_as_default: Whether to set this payment method as the default
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Added PaymentMethod entity if successful, None otherwise
        """
        # Create a setup intent to confirm the payment method
        success, message, result = self.payment_method_service.create_setup_intent(
            user_id=user_id,
            payment_method_id=payment_method_id
        )
        
        if not success:
            return False, message, None
        
        # Confirm the setup intent
        success, message, payment_method = self.payment_method_service.confirm_setup_intent(
            setup_intent_id=result['setup_intent_id'],
            user_id=user_id
        )
        
        if not success:
            return False, message, None
        
        # Set as default if requested
        if set_as_default and payment_method:
            self.payment_method_service.set_default_payment_method(
                user_id=user_id,
                payment_method_id=payment_method.id
            )
        
        return True, "Payment method added successfully", payment_method
    
    def get_payment_methods(self, user_id: UUID) -> List[PaymentMethod]:
        """
        Get all payment methods for a user.
        
        Args:
            user_id: The ID of the user
            
        Returns:
            List of PaymentMethod entities
        """
        return self.payment_method_service.get_payment_methods(user_id)
    
    def get_default_payment_method(self, user_id: UUID) -> Optional[PaymentMethod]:
        """
        Get the default payment method for a user.
        
        Args:
            user_id: The ID of the user
            
        Returns:
            Default PaymentMethod entity if one exists, None otherwise
        """
        return self.payment_method_service.get_default_payment_method(user_id)
    
    def set_default_payment_method(self, user_id: UUID, payment_method_id: str) -> Tuple[bool, str]:
        """
        Set a payment method as the default for a user.
        
        Args:
            user_id: The ID of the user
            payment_method_id: The ID of the payment method to set as default
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
        """
        return self.payment_method_service.set_default_payment_method(user_id, payment_method_id)
    
    def delete_payment_method(self, payment_method_id: str, user_id: UUID) -> Tuple[bool, str]:
        """
        Delete a payment method.
        
        Args:
            payment_method_id: The ID of the payment method to delete
            user_id: The ID of the user who owns the payment method
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
        """
        return self.payment_method_service.delete_payment_method(payment_method_id, user_id)
    
    def create_setup_intent(self, user_id: UUID, payment_method_id: Optional[str] = None) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Create a setup intent for saving a payment method.
        
        Args:
            user_id: The ID of the user to create the setup intent for
            payment_method_id: Optional ID of an existing payment method to set up
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Dictionary with setup intent details (client_secret, etc.)
        """
        return self.payment_method_service.create_setup_intent(user_id, payment_method_id)
    
    def confirm_setup_intent(self, setup_intent_id: str, user_id: UUID) -> Tuple[bool, str, Optional[PaymentMethod]]:
        """
        Confirm a setup intent and save the payment method.
        
        Args:
            setup_intent_id: The ID of the setup intent to confirm
            user_id: The ID of the user who owns the payment method
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Saved PaymentMethod entity if successful, None otherwise
        """
        return self.payment_method_service.confirm_setup_intent(setup_intent_id, user_id)
