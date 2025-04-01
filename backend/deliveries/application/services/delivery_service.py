import uuid
from typing import List, Tuple, Optional

from deliveries.domain.models.entities import Delivery
from deliveries.domain.models.constants import DeliveryStatus, DeliveryEventType
from deliveries.domain.repositories.repository_interfaces import DeliveryRepository, DriverRepository
from the_user_app.domain.repositories.repository_interfaces import UserRepository
from core.domain_events.event_bus import event_bus
from deliveries.domain.models.events.deliveries_events import (
    DeliveryCreatedEvent,
    DeliveryAssignedEvent, DeliveryStatusChangedEvent
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

    def create(self, order_id: uuid.UUID) -> Delivery:
        """Create a new delivery"""

        delivery = self.delivery_repository.create(
            order_id=order_id
        )

        # Publish delivery created event
        event_bus.publish(DeliveryCreatedEvent.create(
            delivery_id=delivery.id,
            order_id=order_id,
            delivery_address=delivery.delivery_address
        ))

        return delivery
    
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
        
        return True, "Driver assigned to delivery, put driver availability to true", updated_delivery
    
    def get_all_pending_deliveries(self) -> List[Delivery]:
        """Get all pending deliveries"""
        return self.delivery_repository.list_by_status(DeliveryStatus.PENDING)