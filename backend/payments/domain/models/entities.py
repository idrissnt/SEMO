from dataclasses import dataclass
from typing import Optional
from uuid import UUID
from datetime import datetime


@dataclass
class Payment:
    """Payment domain entity"""
    id: UUID
    order_id: UUID
    payment_method: str  # 'credit_card', 'debit_card', 'paypal'
    status: str  # 'pending', 'completed', 'failed'
    amount: float
    transaction_id: Optional[str] = None
    created_at: datetime = None
    
    def can_transition_to(self, new_status: str) -> bool:
        """Check if the payment can transition to the new status"""
        valid_transitions = {
            'pending': ['completed', 'failed'],
            'completed': [],  # Terminal state
            'failed': ['pending']  # Can retry a failed payment
        }
        
        return new_status in valid_transitions.get(self.status, [])


@dataclass
class PaymentMethod:
    """Payment method domain entity"""
    id: str  # External payment method ID (e.g., Stripe payment method ID)
    type: str  # 'credit_card', 'debit_card', 'paypal'
    user_id: UUID
    is_default: bool = False
    last_four: Optional[str] = None  # Last four digits of card
    expiry_month: Optional[int] = None
    expiry_year: Optional[int] = None
    card_brand: Optional[str] = None  # 'visa', 'mastercard', etc.


@dataclass
class PaymentTransaction:
    """Payment transaction domain entity for tracking payment history"""
    id: UUID
    payment_id: UUID
    transaction_type: str  # 'authorization', 'capture', 'refund', 'void'
    status: str  # 'success', 'failed', 'pending'
    amount: float
    provider_transaction_id: str  # Transaction ID from payment provider
    error_message: Optional[str] = None
    created_at: datetime = None
