"""
Firebase Cloud Messaging implementation of the notification service.

This module provides a Firebase Cloud Messaging (FCM) implementation of the 
NotificationServiceInterface for sending push notifications to drivers.
"""
import logging
from typing import Dict, List, Optional, Any
from uuid import UUID

from django.conf import settings
from firebase_admin import messaging, credentials, initialize_app

from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.services.notification_service_interface import NotificationServiceInterface
from deliveries.domain.repositories.driver_repo.driver_device_repository_interfaces import DriverDeviceRepository
from deliveries.domain.repositories.driver_repo.driver_location_repository_interfaces import DriverLocationRepository

from deliveries.infrastructure.django_repositories.driver_repo.driver_device_repository import DjangoDriverDeviceRepository
from deliveries.infrastructure.django_repositories.driver_repo.driver_location_repository import DjangoDriverLocationRepository

logger = logging.getLogger(__name__)

class FCMNotificationService(NotificationServiceInterface):
    """Firebase Cloud Messaging implementation of NotificationServiceInterface"""
    
    def __init__(self, 
                 driver_device_repository: Optional[DriverDeviceRepository] = None,
                 driver_location_repository: Optional[DriverLocationRepository] = None):
        """Initialize the FCM client"""
        try:
            # Store repositories for device tokens and driver locations
            self.driver_device_repository = driver_device_repository or DjangoDriverDeviceRepository()
            self.driver_location_repository = driver_location_repository or DjangoDriverLocationRepository()
            
            # Initialize Firebase Admin SDK if not already initialized
            if not hasattr(FCMNotificationService, '_initialized'):
                cred = credentials.Certificate(settings.FCM_CREDENTIALS_FILE)
                initialize_app(cred)
                FCMNotificationService._initialized = True
                
            logger.info("FCM notification service initialized")
        except Exception as e:
            logger.error(f"Failed to initialize FCM client: {str(e)}")
            raise
    
    def _get_device_tokens(self, driver_id: UUID) -> List[str]:
        """
        Get FCM device tokens for a driver
        
        This method uses the driver device repository to get all active device tokens
        for a specific driver.
        
        Args:
            driver_id: UUID of the driver
            
        Returns:
            List of FCM device tokens
        """
        try:
            # Get active devices from the repository
            devices = self.driver_device_repository.get_active_devices(driver_id)
            return [device.device_token for device in devices]
        except Exception as e:
            logger.error(f"Error getting device tokens: {str(e)}")
            return []
    
    def send_to_driver(self, driver_id: UUID, title: str, body: str, data: Optional[Dict[str, Any]] = None) -> bool:
        """Send a notification to a specific driver"""
        try:
            # Get device tokens for this driver
            tokens = self._get_device_tokens(driver_id)
            if not tokens:
                logger.warning(f"No device tokens found for driver {driver_id}")
                return False
            
            # Create the message
            message = messaging.MulticastMessage(
                tokens=tokens,
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                android=messaging.AndroidConfig(
                    priority="high",
                    notification=messaging.AndroidNotification(
                        sound="default",
                        priority="high",
                        channel_id="delivery_notifications"
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound="default",
                            badge=1
                        )
                    )
                )
            )
            
            # Send the message
            response = messaging.send_multicast(message)
            success = response.success_count > 0
            
            if not success:
                logger.warning(f"Failed to send notification to driver {driver_id}")
            
            return success
            
        except Exception as e:
            logger.error(f"Error sending notification to driver {driver_id}: {str(e)}")
            return False
    
    def send_to_drivers(self, driver_ids: List[UUID], title: str, body: str, data: Optional[Dict[str, Any]] = None) -> Dict[UUID, bool]:
        """Send a notification to multiple drivers"""
        results = {}
        
        for driver_id in driver_ids:
            results[driver_id] = self.send_to_driver(driver_id, title, body, data)
            
        return results
    
    def send_to_nearby_drivers(self, latitude: float, longitude: float, radius_km: float, 
                             title: str, body: str, data: Optional[Dict[str, Any]] = None,
                             exclude_user_id: Optional[UUID] = None) -> Dict[UUID, bool]:
        """Send a notification to all available drivers near a specific location"""
        try:
            # Create a GeoPoint from the coordinates
            location = GeoPoint(latitude=latitude, longitude=longitude)
            
            # Find nearby available drivers, excluding the user who placed the order
            nearby_drivers = self.driver_location_repository.find_nearby_drivers(
                location=location,
                radius_km=radius_km,
                available_only=True,
                exclude_user_id=exclude_user_id
            )
            
            # Extract driver IDs
            driver_ids = [driver.driver_id for driver in nearby_drivers]
            
            # Add distance information to the notification data
            if data is None:
                data = {}
                
            # Add order location to data
            data['order_latitude'] = latitude
            data['order_longitude'] = longitude
            
            # Send notifications to all nearby drivers
            return self.send_to_drivers(driver_ids, title, body, data)
            
        except Exception as e:
            logger.error(f"Error sending notifications to nearby drivers: {str(e)}")
            return {}
