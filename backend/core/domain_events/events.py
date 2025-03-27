from dataclasses import dataclass, asdict
from typing import Optional, Dict, Any, ClassVar, Type
from uuid import UUID
from datetime import datetime
import json
import uuid


@dataclass
class DomainEvent:
    """Base class for all domain events"""
    event_id: UUID
    timestamp: datetime
    
    @classmethod
    def create(cls, **kwargs):
        """Factory method to create a new event"""
        return cls(
            event_id=uuid.uuid4(),
            timestamp=datetime.now(),
            **kwargs
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert event to dictionary for serialization"""
        result = asdict(self)
        # Convert UUID objects to strings
        for key, value in result.items():
            if isinstance(value, UUID):
                result[key] = str(value)
            elif isinstance(value, datetime):
                result[key] = value.isoformat()
        return result
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'DomainEvent':
        """Create event from dictionary"""
        # Convert string UUIDs back to UUID objects
        for key, value in data.items():
            if key.endswith('_id') and isinstance(value, str):
                try:
                    data[key] = uuid.UUID(value)
                except ValueError:
                    pass  # Not a valid UUID, leave as string
            elif key == 'timestamp' and isinstance(value, str):
                data[key] = datetime.fromisoformat(value)
        return cls(**data)


# Order Events
@dataclass
class OrderCreatedEvent(DomainEvent):
    """Event fired when a new order is created"""
    order_id: UUID
    user_id: UUID
    store_brand_id: UUID
    total_amount: float
    delivery_address: str


@dataclass
class OrderStatusChangedEvent(DomainEvent):
    """Event fired when an order's status changes"""
    order_id: UUID
    previous_status: str
    new_status: str
    notes: Optional[str] = None


@dataclass
class OrderPaidEvent(DomainEvent):
    """Event fired when an order is paid"""
    order_id: UUID
    payment_id: UUID
    amount: float


# Delivery Events
@dataclass
class DeliveryCreatedEvent(DomainEvent):
    """Event fired when a new delivery is created"""
    delivery_id: UUID
    order_id: UUID
    delivery_address: str


@dataclass
class DeliveryAssignedEvent(DomainEvent):
    """Event fired when a delivery is assigned to a driver"""
    delivery_id: UUID
    driver_id: int
    order_id: UUID


@dataclass
class DeliveryStatusChangedEvent(DomainEvent):
    """Event fired when a delivery's status changes"""
    delivery_id: UUID
    previous_status: str
    new_status: str
    location: Optional[Dict[str, float]] = None
    notes: Optional[str] = None


@dataclass
class DeliveryLocationUpdatedEvent(DomainEvent):
    """Event fired when a delivery's location is updated"""
    delivery_id: UUID
    latitude: float
    longitude: float
    driver_id: int


# Cart Events
@dataclass
class CartCheckedOutEvent(DomainEvent):
    """Event fired when a cart is checked out"""
    cart_id: UUID
    user_id: UUID
    store_brand_id: UUID
    total_amount: float


# Payment Events
@dataclass
class PaymentCreatedEvent(DomainEvent):
    """Event fired when a new payment is created"""
    payment_id: UUID
    order_id: UUID
    amount: float
    payment_method: str


@dataclass
class PaymentCompletedEvent(DomainEvent):
    """Event fired when a payment is completed successfully"""
    payment_id: UUID
    order_id: UUID
    amount: float


@dataclass
class PaymentFailedEvent(DomainEvent):
    """Event fired when a payment fails"""
    payment_id: UUID
    order_id: UUID
    error_message: str


@dataclass
class PaymentMethodAddedEvent(DomainEvent):
    """Event fired when a new payment method is added"""
    payment_method_id: str
    user_id: UUID
    is_default: bool
    payment_method_type: str
