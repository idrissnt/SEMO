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
    driver_id: UUID
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
    """Event fired when a delivery's location is updated
    
    This event is published when a delivery's location is updated, typically
    from a driver's device. It includes the geographic coordinates and timestamp
    of the update, allowing other parts of the system to track the delivery in real-time.
    """
    delivery_id: UUID
    latitude: float
    longitude: float
    recorded_at: Optional[str] = None
    driver_id: Optional[int] = None
    
    @classmethod
    def create(cls, delivery_id: UUID, latitude: float, longitude: float, 
              recorded_at=None, driver_id: Optional[int] = None):
        """Factory method to create a new DeliveryLocationUpdatedEvent"""
        return cls(
            event_id=UUID(int=0),  # Will be replaced by EventBus
            delivery_id=delivery_id,
            latitude=latitude,
            longitude=longitude,
            recorded_at=recorded_at.isoformat() if recorded_at else None,
            driver_id=driver_id
        )
