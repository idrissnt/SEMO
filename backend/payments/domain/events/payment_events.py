"""
Domain events for the payment domain.

These events are published when significant actions occur in the payment domain,
allowing other parts of the system to react to them.
"""
from dataclasses import dataclass
from datetime import datetime
from typing import ClassVar

from core.domain_events.events import DomainEvent


@dataclass
class PaymentCreatedEvent(DomainEvent):
    """
    Event published when a new payment is created.
    
    This event is published when a payment is first created, before any
    payment processing has occurred.
    """
    payment_id: str
    order_id: str
    amount: float
    currency: str
    
    EVENT_TYPE: ClassVar[str] = 'payment.created'
    
    @classmethod
    def create(cls, payment_id: str, order_id: str, amount: float, currency: str) -> 'PaymentCreatedEvent':
        """
        Create a new PaymentCreatedEvent.
        
        Args:
            payment_id: The ID of the payment that was created
            order_id: The ID of the order the payment is for
            amount: The amount of the payment
            currency: The currency of the payment
            
        Returns:
            A new PaymentCreatedEvent
        """
        return cls(
            event_id=cls.generate_id(),
            event_type=cls.EVENT_TYPE,
            timestamp=datetime.now().isoformat(),
            payment_id=payment_id,
            order_id=order_id,
            amount=amount,
            currency=currency
        )


@dataclass
class PaymentCompletedEvent(DomainEvent):
    """
    Event published when a payment is completed successfully.
    
    This event is published when a payment has been successfully processed
    and the funds have been captured.
    """
    payment_id: str
    order_id: str
    amount: float
    currency: str
    
    EVENT_TYPE: ClassVar[str] = 'payment.completed'
    
    @classmethod
    def create(cls, payment_id: str, order_id: str, amount: float, currency: str) -> 'PaymentCompletedEvent':
        """
        Create a new PaymentCompletedEvent.
        
        Args:
            payment_id: The ID of the payment that was completed
            order_id: The ID of the order the payment is for
            amount: The amount of the payment
            currency: The currency of the payment
            
        Returns:
            A new PaymentCompletedEvent
        """
        return cls(
            event_id=cls.generate_id(),
            event_type=cls.EVENT_TYPE,
            timestamp=datetime.now().isoformat(),
            payment_id=payment_id,
            order_id=order_id,
            amount=amount,
            currency=currency
        )


@dataclass
class PaymentFailedEvent(DomainEvent):
    """
    Event published when a payment fails.
    
    This event is published when a payment attempt has failed for any reason,
    such as insufficient funds, card declined, etc.
    """
    payment_id: str
    order_id: str
    amount: float
    currency: str
    error_message: str
    
    EVENT_TYPE: ClassVar[str] = 'payment.failed'
    
    @classmethod
    def create(cls, payment_id: str, order_id: str, amount: float, currency: str,
              error_message: str) -> 'PaymentFailedEvent':
        """
        Create a new PaymentFailedEvent.
        
        Args:
            payment_id: The ID of the payment that failed
            order_id: The ID of the order the payment is for
            amount: The amount of the payment
            currency: The currency of the payment
            error_message: The error message explaining why the payment failed
            
        Returns:
            A new PaymentFailedEvent
        """
        return cls(
            event_id=cls.generate_id(),
            event_type=cls.EVENT_TYPE,
            timestamp=datetime.now().isoformat(),
            payment_id=payment_id,
            order_id=order_id,
            amount=amount,
            currency=currency,
            error_message=error_message
        )


@dataclass
class PaymentRefundedEvent(DomainEvent):
    """
    Event published when a payment is refunded.
    
    This event is published when a payment has been refunded, either
    partially or fully.
    """
    payment_id: str
    order_id: str
    amount: float
    currency: str
    refund_amount: float
    
    EVENT_TYPE: ClassVar[str] = 'payment.refunded'
    
    @classmethod
    def create(cls, payment_id: str, order_id: str, amount: float, currency: str,
              refund_amount: float) -> 'PaymentRefundedEvent':
        """
        Create a new PaymentRefundedEvent.
        
        Args:
            payment_id: The ID of the payment that was refunded
            order_id: The ID of the order the payment is for
            amount: The original amount of the payment
            currency: The currency of the payment
            refund_amount: The amount that was refunded
            
        Returns:
            A new PaymentRefundedEvent
        """
        return cls(
            event_id=cls.generate_id(),
            event_type=cls.EVENT_TYPE,
            timestamp=datetime.now().isoformat(),
            payment_id=payment_id,
            order_id=order_id,
            amount=amount,
            currency=currency,
            refund_amount=refund_amount
        )


@dataclass
class PaymentMethodAddedEvent(DomainEvent):
    """
    Event published when a payment method is added.
    
    This event is published when a user adds a new payment method to their account.
    """
    payment_method_id: str
    user_id: str
    payment_method_type: str
    is_default: bool
    
    EVENT_TYPE: ClassVar[str] = 'payment_method.added'
    
    @classmethod
    def create(cls, payment_method_id: str, user_id: str, payment_method_type: str,
              is_default: bool) -> 'PaymentMethodAddedEvent':
        """
        Create a new PaymentMethodAddedEvent.
        
        Args:
            payment_method_id: The ID of the payment method that was added
            user_id: The ID of the user who added the payment method
            payment_method_type: The type of payment method (e.g., 'card', 'apple_pay')
            is_default: Whether this payment method is the user's default
            
        Returns:
            A new PaymentMethodAddedEvent
        """
        return cls(
            event_id=cls.generate_id(),
            event_type=cls.EVENT_TYPE,
            timestamp=datetime.now().isoformat(),
            payment_method_id=payment_method_id,
            user_id=user_id,
            payment_method_type=payment_method_type,
            is_default=is_default
        )


@dataclass
class PaymentMethodRemovedEvent(DomainEvent):
    """
    Event published when a payment method is removed.
    
    This event is published when a user removes a payment method from their account.
    """
    payment_method_id: str
    user_id: str
    
    EVENT_TYPE: ClassVar[str] = 'payment_method.removed'
    
    @classmethod
    def create(cls, payment_method_id: str, user_id: str) -> 'PaymentMethodRemovedEvent':
        """
        Create a new PaymentMethodRemovedEvent.
        
        Args:
            payment_method_id: The ID of the payment method that was removed
            user_id: The ID of the user who removed the payment method
            
        Returns:
            A new PaymentMethodRemovedEvent
        """
        return cls(
            event_id=cls.generate_id(),
            event_type=cls.EVENT_TYPE,
            timestamp=datetime.now().isoformat(),
            payment_method_id=payment_method_id,
            user_id=user_id
        )
