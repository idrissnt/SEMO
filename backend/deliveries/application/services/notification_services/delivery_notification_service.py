"""
Delivery Notification Application service for delivery notifications.

This service coordinates the notification use cases, including sending notifications
to drivers about new orders and delivery status updates.
"""
import logging
from typing import Optional, Tuple, List
from uuid import UUID
from datetime import datetime

from deliveries.domain.models.entities.notification_entities import DriverNotification
from deliveries.domain.models.value_objects import NotificationStatus
from deliveries.domain.models.entities.delivery_entities import Delivery
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.domain.services.notification_service_interface import NotificationServiceInterface
from deliveries.domain.repositories.driver_repo.driver_location_repository_interfaces import DriverLocationRepository
from deliveries.domain.repositories.notification_repo.driver_notification_repository_interfaces import DriverNotificationRepository

from orders.domain.repositories.repository_interfaces import OrderRepository

logger = logging.getLogger(__name__)

class DeliveryNotificationService:
    """Delivery Notification Application service for delivery notifications
    
    This service coordinates notification-related use cases, including sending
    notifications to drivers about new orders, delivery status updates, and
    other important events.
    """
    
    def __init__(
        self,
        delivery_repository: DeliveryRepository,
        notification_service: NotificationServiceInterface,
        driver_location_repository: DriverLocationRepository,
        notification_repository: DriverNotificationRepository,
        order_repository: OrderRepository
    ):
        self.delivery_repository = delivery_repository
        self.notification_service = notification_service
        self.driver_location_repository = driver_location_repository 
        self.notification_repository = notification_repository
        self.order_repository = order_repository
    
    def prepare_notifications_for_new_order(
        self, 
        delivery_id: UUID,
        radius_km: float = 5.0
    ) -> List[DriverNotification]:
        """
        Prepare notifications for nearby drivers about a new order
        but don't send them immediately
        
        Args:
            delivery_id: ID of the delivery
            radius_km: Search radius in kilometers
            
        Returns:
            List of created DriverNotification entities
        """
        try:
            # Get the delivery
            delivery = self.delivery_repository.get_by_id(delivery_id)
            if not delivery or not delivery.delivery_location_geopoint:
                return []
                
            # Get the order to find the user who placed it
            order = self.order_repository.get_by_id(delivery.order_id)
            exclude_user_id = order.user_id if order else None
            
            # Find nearby drivers
            nearby_drivers = self.driver_location_repository.find_nearby_drivers(
                location=delivery.delivery_location_geopoint,
                radius_km=radius_km,
                available_only=True,
                exclude_user_id=exclude_user_id
            )
            
            # Create notification content
            title = f"New Order from {delivery.store_brand_name}"
            body = f"New delivery available {delivery.fee:.2f}$ - {delivery.total_items} items"
            
            # Add delivery details to the notification data
            data = {
                "delivery_id": str(delivery_id),
                "order_id": str(delivery.order_id),
                "store_name": delivery.store_brand_name,
                "delivery_fee": str(delivery.fee),
                "total_items": str(delivery.total_items),
                "notification_type": "new_order"
            }
            
            # Store notifications for each driver
            notifications = []
            for driver_location in nearby_drivers:
                notification = self.notification_repository.create(
                    driver_id=driver_location.driver_id,
                    delivery_id=delivery_id,
                    title=title,
                    body=body,
                    data=data
                )
                notifications.append(notification)
            
            return notifications
            
        except Exception as e:
            logger.error(f"Error preparing notifications for new order: {str(e)}")
            return []
    
    def handle_delivery_acceptance_from_notification(self, delivery_id: UUID, driver_id: UUID) -> Tuple[bool, str, Optional[Delivery]]:
        """
        Handle a driver accepting a delivery
        
        Args:
            delivery_id: UUID of the delivery
            driver_id: UUID of the driver
            
        Returns:
            Tuple of (success, message)
        """

        try:
            # Update notification status
            notification = self.notification_repository.get_by_delivery_and_driver(
                delivery_id=delivery_id,
                driver_id=driver_id
            )
            
            if notification:
                self.notification_repository.update_status(
                    notification_id=notification.id,
                    status=NotificationStatus.ACCEPTED
                )
            
            # Assign the delivery to the driver
            delivery = self.delivery_repository.get_by_id(delivery_id)
            if not delivery:
                return False, f"Delivery with ID {delivery_id} not found"
                
            # Check if already assigned
            if delivery.driver_id:
                return False, "Delivery is already assigned to a driver"
                
            # Assign the delivery
            success = self.delivery_repository.assign_driver(
                delivery_id=delivery_id,
                driver_id=driver_id
            )
            
            if success:
                # Notify other drivers that the delivery is no longer available
                self._notify_other_drivers_delivery_assigned(delivery_id, driver_id)
                
                return True, "Delivery assigned successfully", delivery
            else:
                return False, "Failed to assign delivery", None
                
        except Exception as e:
            logger.error(f"Error handling delivery acceptance: {str(e)}")
            return False, f"Error handling delivery acceptance: {str(e)}"
    
    def _notify_other_drivers_delivery_assigned(self, delivery_id: UUID, assigned_driver_id: UUID) -> None:
        """
        Update notifications for other drivers when a delivery is assigned
        
        This method:
        1. Finds all pending notifications for this delivery (excluding the assigned driver)
        2. Updates their status to CANCELLED
        3. Sends push notifications to other drivers informing them the delivery is no longer available
            the UI will be update when a user will want to access their notifications
            since is will be cancelled, the frontend should be updated based on that status
        
        Args:
            delivery_id: UUID of the delivery
            assigned_driver_id: UUID of the driver who was assigned the delivery
        """
        try:
            # Get the delivery
            delivery = self.delivery_repository.get_by_id(delivery_id)
            if not delivery:
                logger.warning(f"Cannot notify other drivers: Delivery with ID {delivery_id} not found")
                return
            
            # Get all pending notifications for this delivery (excluding the assigned driver)
            notifications = self.notification_repository.get_notifications_for_delivery(
                delivery_id=delivery_id,
                status=NotificationStatus.PENDING
            )
            
            # Filter out the assigned driver's notification
            other_drivers_notifications = [
                n for n in notifications if n.driver_id != assigned_driver_id
            ]
            
            if not other_drivers_notifications:
                logger.info(f"No pending notifications found for delivery {delivery_id} to update")
                return
            
            # Create notification data for the cancellation
            cancellation_data = {
                "delivery_id": str(delivery_id),
                "store_name": delivery.store_brand_name,
                "notification_type": "delivery_cancelled",
                "reason": "assigned_to_another_driver",
                "timestamp": datetime.now().isoformat()
            }
            
            # Update notification status in the database
            driver_ids = [n.driver_id for n in other_drivers_notifications]
            notification_ids = [n.id for n in other_drivers_notifications]
            
            # Update all notifications to CANCELLED status
            for notification_id in notification_ids:
                self.notification_repository.update_status(
                    notification_id=notification_id,
                    new_status=NotificationStatus.CANCELLED,
                    data=cancellation_data
                )
            
            # Send push notifications to all other drivers
            for notification in other_drivers_notifications:
                # Create a cancellation notification
                title = f"Delivery no longer available"
                body = f"The delivery from {delivery.store_brand_name} has been assigned to another driver"
                
                # Send the notification
                self.notification_service.send_to_driver(
                    driver_id=notification.driver_id,
                    title=title,
                    body=body,
                    data=cancellation_data
                )
            
            logger.info(f"Sent cancellation notifications to {len(other_drivers_notifications)} drivers for delivery {delivery_id}")
                
        except Exception as e:
            logger.error(f"Error updating notifications for other drivers: {str(e)}")
        
    def handle_delivery_refusal(self, delivery_id: UUID, driver_id: UUID) -> Tuple[bool, str]:
        """
        Handle a driver refusing a delivery
        
        Args:
            delivery_id: UUID of the delivery
            driver_id: UUID of the driver
            
        Returns:
            Tuple of (success, message)
        """
        try:
            # Update notification status
            notification = self.notification_repository.get_by_delivery_and_driver(
                delivery_id=delivery_id,
                driver_id=driver_id
            )
            
            if notification:
                self.notification_repository.update_status(
                    notification_id=notification.id,
                    status=NotificationStatus.REFUSED
                )
                
                # Record the refusal (this would be implemented in a real system)
                logger.info(f"Driver {driver_id} refused delivery {delivery_id}")
                
                return True, "Delivery refusal recorded successfully"
            else:
                return False, "Notification not found"
                
        except Exception as e:
            logger.error(f"Error handling delivery refusal: {str(e)}")
            return False, f"Error handling delivery refusal: {str(e)}"
   