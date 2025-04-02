"""
Repository interfaces for driver notifications.

This module defines the repository interfaces for driver notifications
following the Dependency Inversion Principle from SOLID.
"""
from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any, Union
from uuid import UUID

from deliveries.domain.models.entities.notification_entities import DriverNotification
from deliveries.domain.models.value_objects import NotificationStatus

class DriverNotificationRepository(ABC):
    """Interface for driver notification repository"""
    
    @abstractmethod
    def create(self, driver_id: UUID, delivery_id: UUID, title: str, body: str, 
              data: Dict[str, Any]) -> DriverNotification:
        """
        Create a new driver notification
        
        Args:
            driver_id: UUID of the driver
            delivery_id: UUID of the delivery
            title: Notification title
            body: Notification body
            data: Additional notification data
            
        Returns:
            Created DriverNotification entity
        """
        pass
    
    @abstractmethod
    def get_pending_notifications(self, driver_id: UUID) -> List[DriverNotification]:
        """
        Get all pending notifications for a driver
        
        Args:
            driver_id: UUID of the driver
            
        Returns:
            List of pending DriverNotification entities
        """
        pass
    
    @abstractmethod
    def update_status(self, notification_id: UUID, new_status: NotificationStatus, data: Optional[Dict] = None) -> bool:
        """
        Update the status and optionally the data of a notification
        
        Args:
            notification_id: UUID of the notification
            new_status: New notification status
            data: Optional additional data to update
            
        Returns:
            True if status was updated successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def get_by_delivery_and_driver(self, delivery_id: UUID, driver_id: UUID) -> Optional[DriverNotification]:
        """
        Get a notification by delivery and driver IDs
        
        Args:
            delivery_id: UUID of the delivery
            driver_id: UUID of the driver
            
        Returns:
            DriverNotification entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_id(self, notification_id: UUID) -> Optional[DriverNotification]:
        """
        Get a notification by ID
        
        Args:
            notification_id: UUID of the notification
            
        Returns:
            DriverNotification entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def delete_notifications(self, 
                           driver_id: UUID,
                           notification_id: Optional[UUID] = None,
                           notification_ids: Optional[List[UUID]] = None,
                           status: Optional[NotificationStatus] = None,
                           delete_all: bool = False) -> int:
        """
        Unified method to delete notifications with various filtering options
        
        This method provides a flexible way to delete notifications based on different criteria:
        - Delete a single notification by ID
        - Delete multiple notifications by ID list
        - Delete all notifications for a driver
        - Delete notifications with a specific status
        
        Args:
            driver_id: Driver ID to verify ownership
            notification_id: Optional single notification ID to delete
            notification_ids: Optional list of notification IDs to delete
            status: Optional status filter
            delete_all: If True, delete all notifications for the driver
            
        Returns:
            Number of notifications deleted
        """
        pass
        
    @abstractmethod
    def update_delivery_notifications(self,
                                    delivery_id: UUID,
                                    new_status: NotificationStatus,
                                    exclude_driver_id: Optional[UUID] = None,
                                    data: Optional[Dict] = None) -> int:
        """
        Update all notifications for a delivery
        
        This method updates the status of all notifications for a specific delivery,
        optionally excluding a specific driver (e.g., the one who accepted the delivery).
        
        Args:
            delivery_id: ID of the delivery
            new_status: New status for the notifications
            exclude_driver_id: Optional driver ID to exclude from the update
            data: Optional additional data to update in the notifications
            
        Returns:
            Number of notifications updated
        """
        pass
        
    @abstractmethod
    def get_notifications_for_delivery(self,
                                     delivery_id: UUID,
                                     status: Optional[NotificationStatus] = None) -> List[DriverNotification]:
        """
        Get all notifications for a specific delivery
        
        This method retrieves all notifications associated with a delivery,
        optionally filtered by status.
        
        Args:
            delivery_id: ID of the delivery
            status: Optional status filter
            
        Returns:
            List of driver notifications for the delivery
        """
        pass
        
    @abstractmethod
    def get_all_driver_notifications(self,
                                  driver_id: UUID,
                                  status: Optional[NotificationStatus] = None,
                                  limit: Optional[int] = 20,
                                  cursor: Optional[UUID] = None) -> List[DriverNotification]:
        """
        Get all notifications for a driver with optional filtering and cursor-based pagination
        
        This method retrieves all notifications for a specific driver,
        optionally filtered by status and with cursor-based pagination support.
        
        Args:
            driver_id: ID of the driver
            status: Optional status filter
            limit: Optional maximum number of notifications to return
            cursor: Optional cursor (notification ID) for pagination - returns notifications older than this ID
            
        Returns:
            List of driver notifications
        """
        pass
