"""
Domain events for the order domain.

These events are published when significant actions occur in the order domain,
allowing other parts of the system to react to them.
"""
from dataclasses import dataclass
from typing import Optional
from uuid import UUID

from core.domain_events.events import DomainEvent

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
    cart_id: UUID
    delivery_address: str