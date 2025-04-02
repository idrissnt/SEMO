import uuid
from typing import Tuple, Optional, Dict, Any
from datetime import datetime, timedelta

from deliveries.domain.models.entities.delivery_entities import DeliveryLocation
from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.repositories.delivery_repo.delivery_location_repository_interfaces import DeliveryLocationRepository
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.domain.services.maps_service_interface import MapsServiceInterface
from core.domain_events.event_bus import event_bus
from deliveries.domain.models.events.deliveries_events import (
    DeliveryLocationUpdatedEvent
)


class LocationApplicationService:
    """Application service for delivery location management
    
    This service coordinates the use cases related to delivery locations, including
    creating, updating, and tracking delivery locations. It integrates
    with the maps service for geospatial functionality like geocoding addresses,
    calculating routes, and estimating travel times.
    """
    
    def __init__(
        self,
        delivery_repository: DeliveryRepository,
        delivery_location_repository: DeliveryLocationRepository,
        maps_service: MapsServiceInterface,
    ):
        self.delivery_repository = delivery_repository
        self.delivery_location_repository = delivery_location_repository
        self.maps_service = maps_service
    
    def update_delivery_location(self, 
                               delivery_id: uuid.UUID, 
                               latitude: float, 
                               longitude: float) -> Tuple[bool, str, Optional[DeliveryLocation]]:
        """Update the current location of a delivery
        
        This method records the current location of a delivery (typically from a driver's
        device) and updates the estimated arrival time based on the new location.
        
        Args:
            delivery_id: ID of the delivery
            latitude: Current latitude
            longitude: Current longitude
            
        Returns:
            Tuple of (success, message, delivery_location)
        """
        # Validate parameters
        if not -90 <= latitude <= 90 or not -180 <= longitude <= 180:
            return False, "Invalid coordinates", None
            
        # Check if delivery exists
        delivery = self.delivery_repository.get_by_id(delivery_id)
        if not delivery:
            return False, "Delivery not found", None
            
        # Create GeoPoint from coordinates
        current_location = GeoPoint(latitude=latitude, longitude=longitude)
        
        # Create delivery location record
        delivery_location = self.delivery_location_repository.create(
            delivery_id=delivery_id,
            location=current_location,
            recorded_at=datetime.now()
        )
            
        # Update estimated arrival time if destination is available
        if self.maps_service and delivery.delivery_location_geopoint:
            # Get updated travel time estimate
            travel_time_seconds = self.maps_service.estimate_travel_time(
                origin=current_location,
                destination=delivery.delivery_location_geopoint
            )
                
            if travel_time_seconds > 0:
                # Calculate new estimated arrival time
                estimated_arrival = datetime.now() + timedelta(seconds=travel_time_seconds)
                    
                # Update delivery with new ETA
                self.delivery_repository.update_estimated_arrival(
                    delivery_id=delivery_id,
                    estimated_arrival_time=estimated_arrival
                )
            
            # Publish location updated event
            event_bus.publish(DeliveryLocationUpdatedEvent.create(
                delivery_id=delivery_id,
                latitude=latitude,
                longitude=longitude,
                recorded_at=delivery_location.recorded_at
            ))
            
            return True, "Location updated successfully", delivery_location
        
        return False, "Location repository not available", None
    
    def get_delivery_route(self, delivery_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get the route information for a delivery
        
        This method calculates the route between the store and delivery location,
        providing distance, duration, and polyline data for map display.
        
        Args:
            delivery_id: ID of the delivery
            
        Returns:
            Dictionary with route information or None if not available
        """
        # Get delivery
        delivery = self.delivery_repository.get_by_id(delivery_id)
        if not delivery:
            return None
            
        # Check if we have the required location data
        if not delivery.store_location_geopoint or not delivery.delivery_location_geopoint:
            return None
            
        # Calculate route
        if self.maps_service:
            route_info = self.maps_service.calculate_route(
                origin=delivery.store_location_geopoint,
                destination=delivery.delivery_location_geopoint
            )
            
            if route_info:
                # Convert to dictionary for API response
                return {
                    "origin": {
                        "lat": route_info.origin.latitude,
                        "lng": route_info.origin.longitude
                    },
                    "destination": {
                        "lat": route_info.destination.latitude,
                        "lng": route_info.destination.longitude
                    },
                    "distance_meters": route_info.distance_meters,
                    "duration_seconds": route_info.duration_seconds,
                    "polyline": route_info.polyline,
                    "waypoints": [
                        {"lat": point.latitude, "lng": point.longitude}
                        for point in route_info.waypoints
                    ] if route_info.waypoints else []
                }
        
        return None