import uuid
from typing import List, Tuple, Optional
from datetime import datetime

from deliveries.domain.models.entities import Delivery
from deliveries.domain.repositories.repository_interfaces import DeliveryRepository, DriverRepository
from the_user_app.domain.repositories.repository_interfaces import UserRepository
from core.domain_events.event_bus import event_bus
from core.domain_events.events import (
    OrderCreatedEvent, OrderStatusChangedEvent, 
    DeliveryCreatedEvent, DeliveryAssignedEvent, DeliveryStatusChangedEvent
)


class DeliveryApplicationService:
    """Application service for delivery management"""
    
    def __init__(
        self,
        delivery_repository: DeliveryRepository,
        driver_repository: DriverRepository,
        user_repository: UserRepository
    ):
        self.delivery_repository = delivery_repository
        self.driver_repository = driver_repository
        self.user_repository = user_repository
        
        # Register event handlers
        event_bus.register(OrderCreatedEvent, self._handle_order_created)
        event_bus.register(OrderStatusChangedEvent, self._handle_order_status_changed)
    
    def _handle_order_created(self, event: OrderCreatedEvent):
        """Handle OrderCreatedEvent by creating a delivery"""
        # Create a delivery for the order
        delivery = self.delivery_repository.create(
            order_id=event.order_id,
            delivery_address=event.delivery_address
        )
        
        # Publish delivery created event
        event_bus.publish(DeliveryCreatedEvent.create(
            delivery_id=delivery.id,
            order_id=event.order_id,
            delivery_address=event.delivery_address
        ))
    
    def _handle_order_status_changed(self, event: OrderStatusChangedEvent):
        """Handle OrderStatusChangedEvent"""
        # If order is cancelled, cancel the delivery too
        if event.new_status == 'cancelled':
            delivery = self.delivery_repository.get_by_order_id(event.order_id)
            if delivery and delivery.status != 'delivered':
                self.update_delivery_status(delivery.id, 'cancelled')
    
    def get_delivery(self, delivery_id: uuid.UUID) -> Optional[Delivery]:
        """Get a delivery by ID"""
        return self.delivery_repository.get_by_id(delivery_id)
    
    def get_deliveries_by_driver(self, driver_id: int) -> List[Delivery]:
        """Get all deliveries for a driver"""
        return self.delivery_repository.list_by_driver(driver_id)
    
    def assign_driver(
        self, 
        delivery_id: uuid.UUID, 
        driver_id: int
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
        if delivery.status != 'pending':
            return False, f"Cannot assign driver to delivery in {delivery.status} state", None
        
        # Get driver
        driver = self.driver_repository.get_by_id(driver_id)
        if not driver:
            return False, "Driver not found", None
        
        # Get user associated with driver
        user = self.user_repository.get_by_id(driver.user_id)
        if not user:
            return False, "User not found", None
        
        # Check if user is available
        if not user.is_available:
            return False, "Driver is not available", None
        
        # Assign driver to delivery
        updated_delivery = self.delivery_repository.update_driver(delivery_id, driver_id)
        
        # Update delivery status
        updated_delivery = self.delivery_repository.update_status(delivery_id, 'assigned')
        
        # Publish event
        event_bus.publish(DeliveryAssignedEvent.create(
            delivery_id=delivery_id,
            driver_id=driver_id,
            order_id=delivery.order_id
        ))
        
        return True, "Driver assigned to delivery", updated_delivery
    
    def update_delivery_status(
        self, 
        delivery_id: uuid.UUID, 
        new_status: str,
        location: Optional[dict] = None,
        notes: Optional[str] = None
    ) -> Tuple[bool, str, Optional[Delivery]]:
        """
        Update the status of a delivery
        
        Args:
            delivery_id: ID of the delivery
            new_status: New status for the delivery
            location: Optional location data (lat/lng)
            notes: Optional notes
            
        Returns:
            Tuple of (success, message, delivery)
        """
        # Get delivery
        delivery = self.delivery_repository.get_by_id(delivery_id)
        if not delivery:
            return False, "Delivery not found", None
        
        # Validate status transition
        valid_transitions = {
            'pending': ['assigned', 'cancelled'],
            'assigned': ['out_for_delivery', 'cancelled'],
            'out_for_delivery': ['delivered', 'cancelled'],
            'delivered': [],  # Terminal state
            'cancelled': []   # Terminal state
        }
        
        if new_status not in valid_transitions.get(delivery.status, []):
            return False, f"Cannot transition from {delivery.status} to {new_status}", None
        
        # Update status
        previous_status = delivery.status
        updated_delivery = self.delivery_repository.update_status(delivery_id, new_status)
        
        # Publish event
        event_bus.publish(DeliveryStatusChangedEvent.create(
            delivery_id=delivery_id,
            previous_status=previous_status,
            new_status=new_status,
            location=location,
            notes=notes
        ))
        
        return True, f"Delivery status updated to {new_status}", updated_delivery
    
    def update_delivery_location(
        self,
        delivery_id: uuid.UUID,
        latitude: float,
        longitude: float
    ) -> Tuple[bool, str, Optional[dict]]:
        """
        Update the location of a delivery
        
        Args:
            delivery_id: ID of the delivery
            latitude: Latitude coordinate
            longitude: Longitude coordinate
            
        Returns:
            Tuple of (success, message, location_data)
        """
        # Get delivery
        delivery = self.delivery_repository.get_by_id(delivery_id)
        if not delivery:
            return False, "Delivery not found", None
        
        # Check if delivery has a driver
        if not delivery.driver_id:
            return False, "Delivery does not have a driver assigned", None
        
        # Check if delivery is in a valid state
        if delivery.status not in ['assigned', 'out_for_delivery']:
            return False, f"Cannot update location for delivery in {delivery.status} state", None
        
        # Get the repository from the factory
        from deliveries.infrastructure.factory import RepositoryFactory
        location_repository = RepositoryFactory.create_delivery_location_repository()
        
        # Create the location record
        location = location_repository.create(
            delivery_id=delivery_id,
            driver_id=delivery.driver_id,
            latitude=latitude,
            longitude=longitude
        )
        
        # Publish the location update event
        event_bus.publish(DeliveryLocationUpdatedEvent.create(
            delivery_id=delivery_id,
            driver_id=delivery.driver_id,
            latitude=latitude,
            longitude=longitude
        ))
        
        location_data = {
            'id': str(location.id),
            'delivery_id': str(location.delivery_id),
            'driver_id': location.driver_id,
            'latitude': location.latitude,
            'longitude': location.longitude,
            'timestamp': location.timestamp.isoformat()
        }
        
        return True, "Location updated successfully", location_data
