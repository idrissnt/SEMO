"""
Payment service interfaces that define the operations available for payment processing.
These interfaces follow the Dependency Inversion Principle by allowing application services
to depend on abstractions rather than concrete implementations.
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, Tuple
from uuid import UUID

from payments.domain.models.entities import Payment


class PaymentServiceInterface(ABC):
    """
    Interface for payment processing operations.
    
    This service handles the core payment operations like creating payment intents,
    confirming payments, and retrieving payment information.
    """
    
    @abstractmethod
    def create_payment_intent(self, payment_id: UUID, payment_method_id: Optional[str] = None,
                             customer_id: Optional[str] = None,
                             setup_future_usage: Optional[str] = None) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Create a payment intent for a payment. (intention to pay)
        
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
        pass
    
    @abstractmethod
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
        pass
    
    @abstractmethod
    def get_payment_status(self, payment_id: UUID) -> str:
        """
        Get the current status of a payment.
        
        Args:
            payment_id: The ID of the payment to check
            
        Returns:
            String representing the payment status
        """
        pass
    
    @abstractmethod
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
        pass