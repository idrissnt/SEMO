from dataclasses import dataclass
from typing import Optional, Dict, Any, List
from uuid import UUID
from datetime import datetime

from payments.domain.models.constants import PaymentStatus, PaymentMethodTypes


@dataclass
class Payment:
    """Payment domain entity
    
    Represents a payment for an order. A payment has a status that changes as it progresses
    through the payment flow, from pending to completed or failed.
    
    The payment is linked to an order and optionally to a payment method. It also stores
    metadata about the payment process, including external payment provider references.
    """
    id: UUID
    order_id: UUID
    amount: float
    currency: str = 'eur'
    status: str = PaymentStatus.PENDING
    external_id: Optional[str] = None  # ID from external payment provider
    external_client_secret: Optional[str] = None  # Client secret for client-side confirmation
    payment_method_id: Optional[str] = None
    created_at: datetime = None
    updated_at: datetime = None
    metadata: Optional[Dict[str, Any]] = None
    
    def __post_init__(self):
        # Validate status
        if self.status not in PaymentStatus.ALL:
            raise ValueError(f"Invalid payment status: {self.status}")
    
    def is_completed(self) -> bool:
        """Check if payment is completed"""
        return self.status == PaymentStatus.COMPLETED
    
    def is_failed(self) -> bool:
        """Check if payment has failed"""
        return self.status == PaymentStatus.FAILED
    
    def requires_action(self) -> bool:
        """Check if payment requires additional action (like 3D Secure)"""
        return self.status == PaymentStatus.REQUIRES_ACTION
        
    def mark_as_processing(self) -> None:
        """Mark the payment as processing"""
        self.status = PaymentStatus.PROCESSING
        self.updated_at = datetime.now()
        
    def mark_as_completed(self) -> None:
        """Mark the payment as completed"""
        self.status = PaymentStatus.COMPLETED
        self.updated_at = datetime.now()
        
    def mark_as_failed(self) -> None:
        """Mark the payment as failed"""
        self.status = PaymentStatus.FAILED
        self.updated_at = datetime.now()
        
    def mark_as_requires_action(self) -> None:
        """Mark the payment as requiring action"""
        self.status = PaymentStatus.REQUIRES_ACTION
        self.updated_at = datetime.now()


@dataclass
class PaymentMethod:
    """Payment method domain entity
    
    Represents a saved payment method for a user. This could be a credit card,
    digital wallet, or other payment method supported by the payment provider.
    
    Payment methods are linked to a user and can be set as the default method.
    They store details about the payment instrument (like last four digits for cards)
    but never store sensitive payment details.
    """
    id: str  # External payment method ID
    user_id: UUID
    type: str  # Use values from PaymentMethodTypes
    is_default: bool = False
    last_four: Optional[str] = None
    card_brand: Optional[str] = None
    expiry_month: Optional[int] = None
    expiry_year: Optional[int] = None
    external_customer_id: Optional[str] = None  # External customer ID
    billing_details: Optional[Dict[str, Any]] = None
    error_message: Optional[str] = None
    created_at: datetime = None
    updated_at: datetime = None
    
    def __post_init__(self):
        # Validate payment method type
        if self.type not in PaymentMethodTypes.ALL:
            raise ValueError(f"Invalid payment method type: {self.type}")
            
    def set_as_default(self) -> None:
        """Set this payment method as the default"""
        self.is_default = True
        self.updated_at = datetime.now()
        
    def unset_as_default(self) -> None:
        """Unset this payment method as the default"""
        self.is_default = False
        self.updated_at = datetime.now()
        
    def is_card(self) -> bool:
        """Check if this payment method is a card"""
        return self.type == PaymentMethodTypes.CARD
        
    def is_digital_wallet(self) -> bool:
        """Check if this payment method is a digital wallet"""
        return self.type in [PaymentMethodTypes.APPLE_PAY, PaymentMethodTypes.GOOGLE_PAY]
