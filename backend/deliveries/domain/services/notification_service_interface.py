"""
Notification service interface for the deliveries domain.

This module defines the interface for notification services that the delivery domain
can use without depending on specific implementations. This follows the Dependency
Inversion Principle from SOLID, allowing the domain to define the interface that
infrastructure implementations must adhere to.
"""
from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from uuid import UUID

class NotificationServiceInterface(ABC):
    """Interface for notification service operations"""
    
    @abstractmethod
    def send_to_driver(self, driver_id: UUID, title: str, body: str, data: Optional[Dict[str, Any]] = None) -> bool:
        """
        Send a notification to a specific driver
        
        Args:
            driver_id: UUID of the driver to notify
            title: Notification title
            body: Notification body text
            data: Optional additional data to include with the notification
            
        Returns:
            True if notification was sent successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def send_to_drivers(self, driver_ids: List[UUID], title: str, body: str, data: Optional[Dict[str, Any]] = None) -> Dict[UUID, bool]:
        """
        Send a notification to multiple drivers
        
        Args:
            driver_ids: List of driver UUIDs to notify
            title: Notification title
            body: Notification body text
            data: Optional additional data to include with the notification
            
        Returns:
            Dictionary mapping driver UUIDs to success status (True/False)
        """
        pass
    
    @abstractmethod
    def send_to_nearby_drivers(self, latitude: float, longitude: float, radius_km: float, 
                             title: str, body: str, data: Optional[Dict[str, Any]] = None) -> Dict[UUID, bool]:
        """
        Send a notification to all available drivers near a specific location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Search radius in kilometers
            title: Notification title
            body: Notification body text
            data: Optional additional data to include with the notification
            
        Returns:
            Dictionary mapping driver UUIDs to success status (True/False)
        """
        pass
