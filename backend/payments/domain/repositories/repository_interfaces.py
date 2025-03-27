from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from payments.domain.models.entities import Payment, PaymentMethod, PaymentTransaction


class PaymentRepository(ABC):
    """Repository interface for Payment entity"""
    
    @abstractmethod
    def create(self, payment: Payment) -> Payment:
        """Create a new payment"""
        pass
    
    @abstractmethod
    def get_by_id(self, payment_id: UUID) -> Optional[Payment]:
        """Get payment by ID"""
        pass
    
    @abstractmethod
    def get_by_order_id(self, order_id: UUID) -> Optional[Payment]:
        """Get payment by order ID"""
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: UUID) -> List[Payment]:
        """Get all payments for a user"""
        pass
    
    @abstractmethod
    def update(self, payment: Payment) -> Payment:
        """Update an existing payment"""
        pass


class PaymentMethodRepository(ABC):
    """Repository interface for PaymentMethod entity"""
    
    @abstractmethod
    def create(self, payment_method: PaymentMethod) -> PaymentMethod:
        """Create a new payment method"""
        pass
    
    @abstractmethod
    def get_by_id(self, payment_method_id: str) -> Optional[PaymentMethod]:
        """Get payment method by ID"""
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: UUID) -> List[PaymentMethod]:
        """Get all payment methods for a user"""
        pass
    
    @abstractmethod
    def get_default_for_user(self, user_id: UUID) -> Optional[PaymentMethod]:
        """Get the default payment method for a user"""
        pass
    
    @abstractmethod
    def update(self, payment_method: PaymentMethod) -> PaymentMethod:
        """Update an existing payment method"""
        pass
    
    @abstractmethod
    def delete(self, payment_method_id: str) -> bool:
        """Delete a payment method"""
        pass
    
    @abstractmethod
    def set_default(self, user_id: UUID, payment_method_id: str) -> bool:
        """Set a payment method as default for a user"""
        pass


class PaymentTransactionRepository(ABC):
    """Repository interface for PaymentTransaction entity"""
    
    @abstractmethod
    def create(self, transaction: PaymentTransaction) -> PaymentTransaction:
        """Create a new payment transaction"""
        pass
    
    @abstractmethod
    def get_by_id(self, transaction_id: UUID) -> Optional[PaymentTransaction]:
        """Get transaction by ID"""
        pass
    
    @abstractmethod
    def get_by_payment_id(self, payment_id: UUID) -> List[PaymentTransaction]:
        """Get all transactions for a payment"""
        pass
    
    @abstractmethod
    def get_by_provider_transaction_id(self, provider_transaction_id: str) -> Optional[PaymentTransaction]:
        """Get transaction by provider transaction ID"""
        pass
