"""
Driver Notification Application service for handling driver notifications.

This module defines the service for handling driver notifications.
"""
import logging
from typing import Dict, List, Optional, Tuple
from uuid import UUID

from deliveries.domain.models.entities.notification_entities import DriverNotification
from deliveries.domain.models.value_objects import NotificationStatus
from deliveries.application.services.notification.base_notification_service import BaseNotificationService

logger = logging.getLogger(__name__)

class DriverNotificationService(BaseNotificationService):
    """Driver Notification Application service for handling driver notifications"""
    
    def send_pending_notifications(self, driver_id: UUID) -> Dict[UUID, bool]:
        """
        Send all pending notifications for a driver
        
        Args:
            driver_id: UUID of the driver
            
        Returns:
            Dictionary mapping notification IDs to success status
        """
        try:
            # Get all pending notifications for the driver
            notifications = self.notification_repository.get_pending_notifications(driver_id)
            results = {}
            
            for notification in notifications:
                # Send the notification
                success = self.notification_service.send_to_driver(
                    driver_id=notification.driver_id,
                    title=notification.title,
                    body=notification.body,
                    data=notification.data
                )
                
                # Update notification status
                if success:
                    self.notification_repository.update_status(
                        notification_id=notification.id,
                        new_status=NotificationStatus.SENT
                    )
                
                results[notification.id] = success
            
            return results
            
        except Exception as e:
            logger.error(f"Error sending pending notifications: {str(e)}")
            return {}
    
    def get_driver_notifications(self, driver_id: UUID, status: Optional[NotificationStatus] = None, 
                            limit: Optional[int] = None, offset: Optional[int] = None) -> List[DriverNotification]:
        """
        Get all notifications for a driver with optional filtering and pagination
        
        This method is useful for the frontend to display notifications and update the UI
        based on notification status changes.
        
        Args:
            driver_id: ID of the driver
            status: Optional status filter
            limit: Optional maximum number of notifications to return
            offset: Optional offset for pagination
            
        Returns:
            List of driver notifications
        """
        try:
            return self.notification_repository.get_all_driver_notifications(
                driver_id=driver_id,
                status=status,
                limit=limit,
                offset=offset
            )
        except Exception as e:
            logger.error(f"Error getting driver notifications: {str(e)}")
            return []
    
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
                    new_status=NotificationStatus.REFUSED
                )
                
                # Record the refusal (this would be implemented in a real system)
                logger.info(f"Driver {driver_id} refused delivery {delivery_id}")
                
                return True, "Delivery refusal recorded successfully"
            else:
                return False, "Notification not found"
                
        except Exception as e:
            logger.error(f"Error handling delivery refusal: {str(e)}")
            return False, f"Error handling delivery refusal: {str(e)}"
