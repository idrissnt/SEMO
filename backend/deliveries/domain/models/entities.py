from dataclasses import dataclass
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime

from deliveries.domain.models.constants import DeliveryStatus, DeliveryEventType


@dataclass
class Driver:
    """Driver domain entity"""
    id: UUID
    user_id: UUID
    mean_time_taken: float
    license_number: Optional[str] = None
    is_available: bool = True
    has_vehicle: Optional[bool] = False

    def compute_mean_time_taken(self) -> None:
        # TODO: Implement mean time taken calculation
        pass


@dataclass
class DeliveryTimelineEvent:
    """Delivery timeline event for tracking delivery history"""
    id: UUID
    delivery_id: UUID
    event_type: DeliveryEventType  # Use DeliveryEventType constants
    timestamp: datetime
    notes: Optional[str] = None
    location: Optional[Dict[str, float]] = None  # {'latitude': float, 'longitude': float}


@dataclass
class DeliveryLocation:
    """Delivery location tracking"""
    id: UUID
    delivery_id: UUID
    driver_id: Optional[UUID]
    latitude: float
    longitude: float
    timestamp: datetime


@dataclass
class Delivery:
    """Delivery domain entity"""
    id: UUID
    order_id: UUID
    fee: float
    total_items: int
    items: List[Dict[str, Any]]
    estimated_total_time: float
    order_total_price: float
    delivery_address: str
    schedule_for: Optional[datetime] = None
    notes_for_driver: Optional[str] = None

    store_brand_id: UUID
    store_brand_name: str
    store_brand_image_logo: str
    store_brand_address: str

    driver_id: Optional[UUID]
    status: DeliveryStatus
    
    created_at: datetime
    timeline_events: Optional[List[DeliveryTimelineEvent]] = None
    current_location: Optional[DeliveryLocation] = None
    
    def can_transition_to(self, new_status: str) -> bool:
        """Check if the delivery can transition to the new status"""
        return new_status in DeliveryStatus.TRANSITIONS.get(self.status, [])
