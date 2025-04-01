"""
Domain events for the delivery domain.

These events are published when significant actions occur in the delivery domain,
allowing other parts of the system to react to them.
"""
from dataclasses import dataclass
from typing import Optional
from uuid import UUID
from typing import Dict

from core.domain_events.events import DomainEvent
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
