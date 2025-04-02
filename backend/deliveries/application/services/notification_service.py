"""
Application service for delivery notifications.

This service coordinates the notification use cases, including sending notifications
to drivers about new orders and delivery status updates.
"""
import logging
from typing import Dict, Optional, Tuple
from uuid import UUID

from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.domain.repositories.driver_repo.driver_repository_interfaces import DriverRepository
from deliveries.domain.services.notification_service_interface import NotificationServiceInterface
from deliveries.domain.repositories.driver_repo.driver_device_repository_interfaces import DriverDeviceRepository
from deliveries.domain.repositories.driver_repo.driver_location_repository_interfaces import DriverLocationRepository
from deliveries.infrastructure.factory import ServiceFactory, RepositoryFactory

from orders.domain.models.entities import Order
from orders.domain.repositories.repository_interfaces import OrderRepository

logger = logging.getLogger(__name__)

class NotificationApplicationService:
    """Application service for delivery notifications
    
    This service coordinates notification-related use cases, including sending
    notifications to drivers about new orders, delivery status updates, and
    other important events.
    """
    
    def __init__(
        self,
        delivery_repository: DeliveryRepository,
        driver_repository: DriverRepository,
        notification_service: Optional[NotificationServiceInterface] = None,
        driver_device_repository: Optional[DriverDeviceRepository] = None,
        driver_location_repository: Optional[DriverLocationRepository] = None,
        order_repository: Optional[OrderRepository] = None
    ):
        self.delivery_repository = delivery_repository
        self.driver_repository = driver_repository
        self.notification_service = notification_service or ServiceFactory.create_notification_service()
        self.driver_device_repository = driver_device_repository or RepositoryFactory.create_driver_device_repository()
        self.driver_location_repository = driver_location_repository or RepositoryFactory.create_driver_location_repository()
        self.order_repository = order_repository
        
    def get_order_by_id(self, order_id: UUID) -> Optional[Order]:
        """Get an order by ID"""
        if self.order_repository:
            return self.order_repository.get_by_id(order_id)
        return None
    
    def notify_nearby_drivers_about_new_order(
        self, 
        delivery_id: UUID,
        radius_km: float = 5.0
    ) -> Tuple[bool, str, Dict[UUID, bool]]:
        """
        Notify nearby available drivers about a new order
        
        This method finds all available drivers within the specified radius
        of the delivery location and sends them a notification about the new order.
        
        Args:
            delivery_id: ID of the delivery
            radius_km: Search radius in kilometers
            
        Returns:
            Tuple of (success, message, results)
            success is True if at least one notification was sent
            message contains information about the operation
            results is a dictionary mapping driver IDs to notification success status
        """
        try:
            # Get the delivery
            delivery = self.delivery_repository.get_by_id(delivery_id)
            if not delivery:
                return False, f"Delivery with ID {delivery_id} not found", {}
                
            # Get the order to find the user who placed it
            order = self.get_order_by_id(delivery.order_id)
            if not order:
                return False, f"Order with ID {delivery.order_id} not found", {}
                
            # Get the user ID who placed the order
            order_user_id = order.user_id
            
            # Check if delivery has a location
            if not delivery.delivery_location_geopoint:
                return False, "Delivery has no location information", {}
            
            # Get the store name for the notification
            store_name = delivery.store_brand_name
            
            # Create notification content
            title = f"New Order from {store_name}"
            body = f"New delivery available {delivery.fee:.2f}$ - {delivery.total_items} items"
            
            # Add delivery details to the notification data
            data = {
                "delivery_id": str(delivery_id),
                "order_id": str(delivery.order_id),
                "store_name": store_name,
                "delivery_fee": str(delivery.fee),
                "total_items": str(delivery.total_items),
                "notification_type": "new_order"
            }
            
            # Send notifications to nearby drivers, excluding the user who placed the order
            results = self.notification_service.send_to_nearby_drivers(
                latitude=delivery.delivery_location_geopoint.latitude,
                longitude=delivery.delivery_location_geopoint.longitude,
                radius_km=radius_km,
                title=title,
                body=body,
                data=data,
                exclude_user_id=order_user_id
            )
            
            # Check if any notifications were sent
            if not results:
                return False, "No available drivers found nearby", {}
            
            success_count = sum(1 for success in results.values() if success)
            return True, f"Notified {success_count} nearby drivers", results
            
        except Exception as e:
            logger.error(f"Error notifying drivers about new order: {str(e)}")
            return False, f"Error notifying drivers: {str(e)}", {}
    
    def notify_driver_about_assignment(self, delivery_id: UUID, driver_id: UUID) -> Tuple[bool, str]:
        """
        Notify a driver about being assigned to a delivery
        
        Args:
            delivery_id: ID of the delivery
            driver_id: ID of the driver
            
        Returns:
            Tuple of (success, message)
        """
        try:
            # Get the delivery
            delivery = self.delivery_repository.get_by_id(delivery_id)
            if not delivery:
                return False, f"Delivery with ID {delivery_id} not found"
            
            # Get the driver
            driver = self.driver_repository.get_by_id(driver_id)
            if not driver:
                return False, f"Driver with ID {driver_id} not found"
            
            # Create notification content
            title = "New Delivery Assignment"
            body = f"You've been assigned a delivery from {delivery.store_brand_name}"
            
            # Add delivery details to the notification data
            data = {
                "delivery_id": str(delivery_id),
                "order_id": str(delivery.order_id),
                "store_name": delivery.store_brand_name,
                "store_address": delivery.store_brand_address_human_readable,
                "delivery_address": delivery.delivery_address_human_readable,
                "notification_type": "delivery_assignment"
            }
            
            # Send notification to the driver
            success = self.notification_service.send_to_driver(
                driver_id=driver_id,
                title=title,
                body=body,
                data=data
            )
            
            if success:
                return True, "Driver notified successfully"
            else:
                return False, "Failed to send notification to driver"
            
        except Exception as e:
            logger.error(f"Error notifying driver about assignment: {str(e)}")
            return False, f"Error notifying driver: {str(e)}"
    
    def notify_customer_about_status_update(self, delivery_id: UUID, status: str) -> Tuple[bool, str]:
        """
        Notify a customer about a delivery status update
        
        This would typically integrate with a customer notification service.
        For now, it's a placeholder that logs the notification.
        
        Args:
            delivery_id: ID of the delivery
            status: New delivery status
            
        Returns:
            Tuple of (success, message)
        """
        try:
            # Get the delivery
            delivery = self.delivery_repository.get_by_id(delivery_id)
            if not delivery:
                return False, f"Delivery with ID {delivery_id} not found"
            
            # Log the notification (in a real implementation, you would send to the customer)
            logger.info(f"Customer notification for delivery {delivery_id}: Status updated to {status}")
            
            return True, "Customer notification logged (not actually sent)"
            
        except Exception as e:
            logger.error(f"Error notifying customer about status update: {str(e)}")
            return False, f"Error notifying customer: {str(e)}"
