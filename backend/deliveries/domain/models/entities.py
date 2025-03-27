from dataclasses import dataclass
from typing import Optional, List, Dict
from uuid import UUID
from datetime import datetime


@dataclass
class Driver:
    """Driver domain entity"""
    id: UUID
    user_id: UUID
    # We don't duplicate is_available here since it's part of the User entity


@dataclass
class DeliveryTimelineEvent:
    """Delivery timeline event for tracking delivery history"""
    id: UUID
    delivery_id: UUID
    event_type: str  # 'created', 'assigned', 'picked_up', 'out_for_delivery', 'delivered', 'cancelled'
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
    store_brand_id: UUID
    store_brand_address: str
    driver_id: Optional[UUID]
    status: str
    delivery_address: str
    created_at: datetime
    timeline_events: Optional[List[DeliveryTimelineEvent]] = None
    current_location: Optional[DeliveryLocation] = None
    
    def can_transition_to(self, new_status: str) -> bool:
        """Check if the delivery can transition to the new status"""
        valid_transitions = {
            'pending': ['assigned', 'cancelled'],
            'assigned': ['out_for_delivery', 'cancelled'],
            'out_for_delivery': ['delivered', 'cancelled'],
            'delivered': [],  # Terminal state
            'cancelled': []   # Terminal state
        }
        
        return new_status in valid_transitions.get(self.status, [])
