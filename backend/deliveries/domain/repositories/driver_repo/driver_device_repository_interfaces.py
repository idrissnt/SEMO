"""
Repository interfaces for driver devices.

This module defines the repository interfaces for driver devices
following the Dependency Inversion Principle from SOLID.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities.driver_entities import DriverDevice


class DriverDeviceRepository(ABC):
    """Interface for driver device repository"""
    
    @abstractmethod
    def register_device(self, driver_id: UUID, device_token: str, device_type: str) -> DriverDevice:
        """
        Register a driver's device for push notifications
        
        Args:
            driver_id: UUID of the driver
            device_token: FCM device token
            device_type: Device type (e.g., 'android', 'ios')
            
        Returns:
            The created DriverDevice entity
        """
        pass
    
    @abstractmethod
    def unregister_device(self, driver_id: UUID, device_token: str) -> bool:
        """
        Unregister a driver's device from push notifications
        
        Args:
            driver_id: UUID of the driver
            device_token: FCM device token
            
        Returns:
            True if device was unregistered successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def get_active_devices(self, driver_id: UUID) -> List[DriverDevice]:
        """
        Get all active devices for a driver
        
        Args:
            driver_id: UUID of the driver
            
        Returns:
            List of active DriverDevice entities
        """
        pass
    

