"""
Payment service interfaces that define the operations available for payment processing.
These interfaces follow the Dependency Inversion Principle by allowing application services
to depend on abstractions rather than concrete implementations.
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, Tuple, List
from uuid import UUID

from payments.domain.models.entities import PaymentMethod

class PaymentMethodServiceInterface(ABC):
    """
    Interface for payment method operations.
    
    This service handles operations related to payment methods like
    creating setup intents, saving payment methods, and managing default methods.
    """
    
    @abstractmethod
    def create_setup_intent(self, user_id: UUID, payment_method_id: Optional[str] = None) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Create a setup intent for saving a payment method.
        
        Args:
            user_id: The ID of the user to create the setup intent for
            payment_method_id: Optional ID of an existing payment method
            
        Returns:
            Tuple containing:
            - Success flag (True/False)
            - Message describing the result
            - Dictionary with setup intent details (client_secret, etc.)
        """
        pass
    
    @abstractmethod
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
        pass
    
    @abstractmethod
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
        pass
    
    @abstractmethod
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
        pass
    
    @abstractmethod
    def get_payment_methods(self, user_id: UUID) -> List[PaymentMethod]:
        """
        Get all payment methods for a user.
        
        Args:
            user_id: The ID of the user
            
        Returns:
            List of PaymentMethod entities
        """
        pass
    
    @abstractmethod
    def get_default_payment_method(self, user_id: UUID) -> Optional[PaymentMethod]:
        """
        Get the default payment method for a user.
        
        Args:
            user_id: The ID of the user
            
        Returns:
            Default PaymentMethod entity if one exists, None otherwise
        """
        pass
