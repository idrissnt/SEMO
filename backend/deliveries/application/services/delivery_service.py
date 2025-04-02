import uuid
from typing import List, Tuple, Optional, Dict, Any
from datetime import datetime, timedelta

from deliveries.domain.models.entities.delivery_entities import Delivery, DeliveryLocation
from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.models.constants import DeliveryStatus
from deliveries.domain.repositories.delivery_repo.delivery_location_repository_interfaces import DeliveryLocationRepository
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.domain.repositories.driver_repo.driver_repository_interfaces import DriverRepository
from deliveries.domain.services.maps_service_interface import MapsServiceInterface
from deliveries.domain.services.notification_service_interface import NotificationServiceInterface
from deliveries.infrastructure.factory import ServiceFactory
from deliveries.application.services.notification_service import NotificationApplicationService
from core.domain_events.event_bus import event_bus
from deliveries.domain.models.events.deliveries_events import (
    DeliveryCreatedEvent,
    DeliveryAssignedEvent, 
    DeliveryLocationUpdatedEvent
)


class DeliveryApplicationService:
    """Application service for delivery management
    
    This service coordinates the use cases related to deliveries, including
    creating, assigning, updating status, and tracking deliveries. It integrates
    with the maps service for geospatial functionality like geocoding addresses,
    calculating routes, and estimating travel times.
    """
    
    def __init__(
        self,
        delivery_repository: DeliveryRepository,
        driver_repository: DriverRepository,
        delivery_location_repository: Optional[DeliveryLocationRepository] = None,
        maps_service: Optional[MapsServiceInterface] = None,
        notification_service: Optional[NotificationServiceInterface] = None
    ):
        self.delivery_repository = delivery_repository
        self.driver_repository = driver_repository
        self.delivery_location_repository = delivery_location_repository
        self.maps_service = maps_service or ServiceFactory.create_maps_service()
        self.notification_service = notification_service or ServiceFactory.create_notification_service()
        
        # Create the notification application service
        self.notification_app_service = NotificationApplicationService(
            delivery_repository=delivery_repository,
            driver_repository=driver_repository,
            notification_service=notification_service
        )

    def create(self, order_id: uuid.UUID) -> Delivery:
        """Create a new delivery
        
        This method creates a new delivery for an order and geocodes the
        delivery and store addresses to geographic coordinates for route
        calculation and location tracking.
        
        Args:
            order_id: ID of the order to create a delivery for
            
        Returns:
            The created delivery entity
        """
        # Create the delivery
        delivery = self.delivery_repository.create(
            order_id=order_id
        )
        
        # Geocode addresses if maps service is available
        if self.maps_service:
            # Geocode delivery address
            delivery_point = self.maps_service.geocode_address(delivery.delivery_address)
            
            # Geocode store address
            store_point = self.maps_service.geocode_address(delivery.store_brand_address)
            
            # Update delivery with geocoded points
            if delivery_point or store_point:
                self.delivery_repository.update_delivery_locations(
                    delivery_id=delivery.id,
                    delivery_location_geopoint=delivery_point,
                    store_location_geopoint=store_point
                )
                
                # Calculate estimated arrival time if both points are available
                if delivery_point and store_point:
                    # Calculate route
                    route_info = self.maps_service.calculate_route(
                        origin=store_point,
                        destination=delivery_point
                    )
                    
                    if route_info:
                        # Calculate estimated arrival time
                        estimated_arrival = datetime.now() + timedelta(
                            seconds=route_info.duration_seconds
                        )
                        
                        # Update delivery with estimated arrival time
                        self.delivery_repository.update_estimated_arrival(
                            delivery_id=delivery.id,
                            estimated_arrival_time=estimated_arrival
                        )

        # Publish delivery created event
        event_bus.publish(DeliveryCreatedEvent.create(
            delivery_id=delivery.id,
            order_id=order_id,
            delivery_address=delivery.delivery_address
        ))
        
        # Notify nearby drivers about the new order
        if delivery.delivery_location_geopoint:
            self.notification_app_service.notify_nearby_drivers_about_new_order(
                delivery_id=delivery.id,
                radius_km=5.0  # Default radius in kilometers
            )

        return delivery
    
    def get_delivery(self, delivery_id: uuid.UUID) -> Optional[Delivery]:
        """Get a delivery by ID"""
        return self.delivery_repository.get_by_id(delivery_id)
    
    def get_deliveries_by_driver(self, driver_id: uuid.UUID) -> List[Delivery]:
        """Get all deliveries for a driver"""
        return self.delivery_repository.list_by_driver(driver_id)
    
    def assign_driver(
        self, 
        delivery_id: uuid.UUID, 
        driver_id: uuid.UUID
    ) -> Tuple[bool, str, Optional[Delivery]]:
        """
        Assign a driver to a delivery
        
        Args:
            delivery_id: ID of the delivery
            driver_id: ID of the driver
            
        Returns:
            Tuple of (success, message, delivery)
        """
        # Get delivery
        delivery = self.delivery_repository.get_by_id(delivery_id)
        if not delivery:
            return False, "Delivery not found", None
        
        # Check if delivery already has a driver
        if delivery.driver_id:
            return False, "Delivery already has a driver assigned", None
        
        # Check if delivery is in a valid state
        if delivery.status != DeliveryStatus.PENDING:
            return False, f"Cannot assign driver to delivery in {delivery.status} state", None
        
        # Get driver
        driver = self.driver_repository.get_by_id(driver_id)
        if not driver:
            return False, "Driver not found", None
        
        # Check if driver is available
        if not driver.is_available:
            # Update driver availability
            self.driver_repository.update_availability(driver_id, True)
        
        # Assign driver to delivery
        updated_delivery = self.delivery_repository.assign_driver(delivery_id, driver_id)
        
        # Update delivery status
        updated_delivery = self.delivery_repository.update_status(delivery_id, DeliveryStatus.ASSIGNED)
        
        # Publish event
        event_bus.publish(DeliveryAssignedEvent.create(
            delivery_id=delivery_id,
            driver_id=driver_id,
            order_id=delivery.order_id
        ))
        
        # Notify the driver about the assignment
        self.notification_app_service.notify_driver_about_assignment(
            delivery_id=delivery_id,
            driver_id=driver_id
        )
        
        return True, "Driver assigned successfully", updated_delivery
    
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
        if self.delivery_location_repository:
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
    
    def find_nearby_deliveries(self, 
                             latitude: float, 
                             longitude: float, 
                             radius_km: float = 2.0,
                             status: Optional[str] = None) -> List[Delivery]:
        """Find deliveries near a specific location
        
        This method is useful for drivers to find nearby deliveries they can do,
        or for customers to see deliveries happening in their area.
        
        Args:
            latitude: Current latitude
            longitude: Current longitude
            radius_km: Search radius in kilometers
            status: Optional status filter
            
        Returns:
            List of nearby deliveries
        """
        # Validate parameters
        if not -90 <= latitude <= 90 or not -180 <= longitude <= 180:
            return []
            
        # Create GeoPoint from coordinates
        location = GeoPoint(latitude=latitude, longitude=longitude)
        
        # Find nearby deliveries
        return self.delivery_repository.list_by_proximity(
            location=location,
            max_distance_km=radius_km,
            status=status
        )
    
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
            
    def get_all_pending_deliveries(self) -> List[Delivery]:
        """Get all pending deliveries"""
        return self.delivery_repository.list_by_status(DeliveryStatus.PENDING)