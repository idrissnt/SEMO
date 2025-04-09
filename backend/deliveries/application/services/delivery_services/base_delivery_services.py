import uuid
from typing import List, Optional, Tuple
from datetime import datetime, timedelta

from deliveries.domain.models.entities.delivery_entities import Delivery
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.domain.repositories.driver_repo.driver_repository_interfaces import DriverRepository
from deliveries.domain.services.maps_service_interface import MapsServiceInterface
from deliveries.domain.services.notification_service_interface import NotificationServiceInterface
from deliveries.application.services.notification_services.delivery_notification_service import DeliveryNotificationService
from deliveries.domain.repositories.notification_repo.driver_notification_repository_interfaces import DriverNotificationRepository
from core.domain_events.event_bus import event_bus

from deliveries.domain.models.constants import DeliveryStatus
from deliveries.domain.models.events.deliveries_events import (
    DeliveryCreatedEvent,
)

from deliveries.infrastructure.services.fcm_notification_service import FCMNotificationService
from deliveries.infrastructure.services.google_maps_service import GoogleMapsService


class BaseDeliveryApplicationService:
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
        maps_service: Optional[MapsServiceInterface] = None,
        notification_service: Optional[NotificationServiceInterface] = None,
        driver_notification_repository: Optional[DriverNotificationRepository] = None
    ):
        self.delivery_repository = delivery_repository
        self.driver_repository = driver_repository
        self.maps_service = maps_service or GoogleMapsService()
        self.notification_service = notification_service or FCMNotificationService()
        self.driver_notification_repository = driver_notification_repository 
        
        # Create the notification application service
        self.notification_app_service = DeliveryNotificationService(
            delivery_repository=delivery_repository,
            driver_repository=driver_repository,
            notification_service=self.notification_service,
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
            delivery_point = self.maps_service.geocode_address(delivery.delivery_address_human_readable)
            
            # Geocode store address
            store_point = self.maps_service.geocode_address(delivery.store_brand_address_human_readable)
            
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
            delivery_address=delivery.delivery_address_human_readable
        ))
        
        # Prepare notifications for nearby drivers about the new order
        if delivery.delivery_location_geopoint:
            notifications = self.notification_app_service.prepare_notifications_for_new_order(
                delivery_id=delivery.id,
                radius_km=5.0  # Default radius in kilometers
            )
            
            # Log the number of notifications prepared
            if notifications:
                print(f"Prepared {len(notifications)} notifications for nearby drivers")

        return delivery

    def handle_delivery_acceptance(self, delivery_id: uuid.UUID, driver_id: uuid.UUID) -> Tuple[bool, str, Optional[Delivery]]:
        """
        Handle a driver accepting a delivery
        
        Args:
            delivery_id: UUID of the delivery
            driver_id: UUID of the driver
            
        Returns:
            Tuple of (success, message)
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
        assigned_delivery = self.delivery_repository.assign_driver(delivery_id, driver_id)
        
        # Update delivery status
        updated_delivery = self.delivery_repository.update_status(assigned_delivery.id, DeliveryStatus.ASSIGNED)

        return True, f"Delivery assigned successfully to {driver.id}", updated_delivery
    
    def get_delivery(self, delivery_id: uuid.UUID) -> Optional[Delivery]:
        """Get a delivery by ID"""
        return self.delivery_repository.get_by_id(delivery_id)
    
    def get_deliveries_by_driver(self, driver_id: uuid.UUID) -> List[Delivery]:
        """Get all deliveries for a driver"""
        return self.delivery_repository.list_by_driver(driver_id)
    
    def get_all_pending_deliveries(self) -> List[Delivery]:
        """Get all pending deliveries"""
        return self.delivery_repository.list_by_status(DeliveryStatus.PENDING)