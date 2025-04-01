"""
Repository interfaces for the payments domain.

These interfaces define the data access operations for the Payment
entities, following the Repository pattern from Domain-Driven Design.
"""

from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from payments.domain.models.entities import Payment


class PaymentRepository(ABC):
    """Repository interface for Payment entity
    
    This interface defines the data access operations for the Payment entity.
    It follows the Repository pattern from Domain-Driven Design, which abstracts
    the data access logic from the domain logic.
    """
    
    @abstractmethod
    def create(self, payment: Payment) -> Payment:
        """Create a new payment
        
        Args:
            payment: The payment entity to create
            
        Returns:
            The created payment entity with any generated fields populated
        """
        pass
    
    @abstractmethod
    def get_by_id(self, payment_id: UUID) -> Optional[Payment]:
        """Get payment by ID
        
        Args:
            payment_id: The ID of the payment to retrieve
            
        Returns:
            The payment entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_order_id(self, order_id: UUID) -> Optional[Payment]:
        """Get payment by order ID
        
        Args:
            order_id: The ID of the order associated with the payment
            
        Returns:
            The payment entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_external_id(self, external_id: str) -> Optional[Payment]:
        """Get payment by external payment system ID
        
        Args:
            external_id: The ID assigned by the external payment provider
            
        Returns:
            The payment entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: UUID) -> List[Payment]:
        """Get all payments for a user
        
        Args:
            user_id: The ID of the user
            
        Returns:
            List of payment entities belonging to the user
        """
        pass
    
    @abstractmethod
    def update(self, payment: Payment) -> Payment:
        """Update an existing payment
        
        Args:
            payment: The payment entity with updated fields
            
        Returns:
            The updated payment entity
        """
        pass
        
    @abstractmethod
    def belongs_to_user(self, payment_id: UUID, user_id: UUID) -> bool:
        """Check if a payment belongs to a user
        
        Args:
            payment_id: The ID of the payment to check
            user_id: The ID of the user
            
        Returns:
            True if the payment belongs to the user, False otherwise
        """
        pass
