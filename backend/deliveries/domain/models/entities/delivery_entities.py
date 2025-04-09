from dataclasses import dataclass
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime

from deliveries.domain.models.constants import DeliveryStatus, DeliveryEventType
from deliveries.domain.models.value_objects import GeoPoint, RouteInfo


@dataclass
class DeliveryTimelineEvent:
    """Domain entity for DeliveryTimeline
    Records a chronological sequence of events 
    (created, assigned, picked up, delivered, etc.) for each delivery
    Captures when and why a delivery's status changed"""
    id: UUID
    delivery_id: UUID
    event_type: DeliveryEventType  # Use DeliveryEventType constants
    timestamp: datetime
    notes: Optional[str] = None
    location: Optional[GeoPoint] = None
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'DeliveryTimelineEvent':
        """Create a DeliveryTimelineEvent from a dictionary"""
        location = None
        if data.get('location'):
            location = GeoPoint.from_dict(data['location'])
            
        return cls(
            id=data['id'],
            delivery_id=data['delivery_id'],
            event_type=data['event_type'],
            timestamp=data['timestamp'],
            notes=data.get('notes'),
            location=location
        )


@dataclass
class DeliveryLocation:
    """Domain entity for DeliveryLocation
    to track the location of the driver during the delivery
    Captures the exact location of the driver at specific points in time"""
    id: UUID
    delivery_id: UUID
    driver_id: Optional[UUID]
    location: GeoPoint
    timestamp: datetime
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'DeliveryLocation':
        """Create a DeliveryLocation from a dictionary"""
        location = GeoPoint(
            latitude=data['latitude'],
            longitude=data['longitude']
        ) if 'latitude' in data and 'longitude' in data else GeoPoint.from_dict(data['location'])
        
        return cls(
            id=data['id'],
            delivery_id=data['delivery_id'],
            driver_id=data.get('driver_id'),
            location=location,
            timestamp=data['timestamp']
        )


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
    delivery_address_human_readable: str
    schedule_for: Optional[datetime] = None
    notes_for_driver: Optional[str] = None

    store_brand_id: Optional[UUID] = None
    store_brand_name: Optional[str] = None
    store_brand_image_logo: Optional[str] = None
    store_brand_address_human_readable: Optional[str] = None

    driver_id: Optional[UUID] = None
    status: DeliveryStatus = DeliveryStatus.PENDING
    
    created_at: datetime = datetime.now()
    timeline_events: Optional[List[DeliveryTimelineEvent]] = None
    current_location: Optional[DeliveryLocation] = None
    
    # New geospatial fields
    delivery_location_geopoint: Optional[GeoPoint] = None
    store_location_geopoint: Optional[GeoPoint] = None
    route_info: Optional[RouteInfo] = None
    estimated_arrival_time: Optional[datetime] = None
    
    def can_transition_to(self, new_status: str) -> bool:
        """Check if the delivery can transition to the new status"""
        return new_status in DeliveryStatus.TRANSITIONS.get(self.status, [])
    
    def update_estimated_arrival(self, current_location: GeoPoint, 
                               route_info: RouteInfo, 
                               current_time: datetime) -> datetime:
        """
        Update the estimated arrival time based on current location and route information
        
        Args:
            current_location: Current driver location
            route_info: Route information including duration
            current_time: Current time
            
        Returns:
            Updated estimated arrival time
        """
        from datetime import timedelta
        
        # Calculate how far along the route the driver is
        if route_info.origin.distance_to(route_info.destination) > 0:
            progress_ratio = current_location.distance_to(route_info.destination) / \
                           route_info.origin.distance_to(route_info.destination)
            
            # Adjust for the fact that distance ratio isn't perfect for time estimation
            # (e.g., highways vs city streets)
            remaining_time_seconds = max(60, route_info.duration_seconds * progress_ratio)
            
            # Calculate new ETA
            self.estimated_arrival_time = current_time + timedelta(seconds=remaining_time_seconds)
        else:
            # If origin and destination are the same or very close
            self.estimated_arrival_time = current_time + timedelta(minutes=5)
            
        return self.estimated_arrival_time
    
    def get_status_label(self) -> str:
        """Get human-readable status label"""
        return DeliveryStatus.LABELS.get(self.status, self.status)
