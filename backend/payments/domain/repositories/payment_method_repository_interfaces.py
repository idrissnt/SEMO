"""
Repository interfaces for the payments domain.

These interfaces define the data access operations for the PaymentMethod
entities, following the Repository pattern from Domain-Driven Design.
"""

from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from payments.domain.models.entities import PaymentMethod

class PaymentMethodRepository(ABC):
    """Repository interface for PaymentMethod entity
    
    This interface defines the data access operations for the PaymentMethod entity.
    It follows the Repository pattern from Domain-Driven Design, which abstracts
    the data access logic from the domain logic.
    """
    
    @abstractmethod
    def create(self, payment_method: PaymentMethod) -> PaymentMethod:
        """Create a new payment method
        
        Args:
            payment_method: The payment method entity to create
            
        Returns:
            The created payment method entity with any generated fields populated
        """
        pass
    
    @abstractmethod
    def get_by_id(self, payment_method_id: str) -> Optional[PaymentMethod]:
        """Get payment method by ID
        
        Args:
            payment_method_id: The ID of the payment method to retrieve
            
        Returns:
            The payment method entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: UUID) -> List[PaymentMethod]:
        """Get all payment methods for a user
        
        Args:
            user_id: The ID of the user
            
        Returns:
            List of payment method entities belonging to the user
        """
        pass
    
    @abstractmethod
    def get_default_for_user(self, user_id: UUID) -> Optional[PaymentMethod]:
        """Get the default payment method for a user
        
        Args:
            user_id: The ID of the user
            
        Returns:
            The default payment method entity if one exists, None otherwise
        """
        pass
    
    @abstractmethod
    def update(self, payment_method: PaymentMethod) -> PaymentMethod:
        """Update an existing payment method
        
        Args:
            payment_method: The payment method entity with updated fields
            
        Returns:
            The updated payment method entity
        """
        pass
    
    @abstractmethod
    def delete(self, payment_method_id: str) -> bool:
        """Delete a payment method
        
        Args:
            payment_method_id: The ID of the payment method to delete
            
        Returns:
            True if the payment method was deleted, False otherwise
        """
        pass
    
    @abstractmethod
    def set_default(self, user_id: UUID, payment_method_id: str) -> bool:
        """Set a payment method as default for a user
        
        Args:
            user_id: The ID of the user
            payment_method_id: The ID of the payment method to set as default
            
        Returns:
            True if the payment method was set as default, False otherwise
        """
        pass
    
    @abstractmethod
    def get_or_create_customer_id(self, user_id: UUID) -> str:
        """Get or create a payment customer ID for a user
        
        Args:
            user_id: The ID of the user
            
        Returns:
            The customer ID from the external payment provider
        """
        pass
