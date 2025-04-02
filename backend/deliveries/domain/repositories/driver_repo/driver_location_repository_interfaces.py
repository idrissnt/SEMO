"""
Repository interfaces for driver location tracking.

This module defines the repository interfaces for driver location tracking
following the Dependency Inversion Principle from SOLID.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities.driver_entities import DriverLocation
from deliveries.domain.models.value_objects import GeoPoint


class DriverLocationRepository(ABC):
    """Interface for driver location repository"""
    
    @abstractmethod
    def update_driver_location(self, driver_id: UUID, location: GeoPoint) -> bool:
        """
        Update a driver's current location
        
        Args:
            driver_id: UUID of the driver
            location: Current geographic location
            
        Returns:
            True if location was updated successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def get_driver_location(self, driver_id: UUID) -> Optional[DriverLocation]:
        """
        Get a driver's current location
        
        Args:
            driver_id: UUID of the driver
            
        Returns:
            Current location as DriverLocation if available, None otherwise
        """
        pass
    
    @abstractmethod
    def find_nearby_drivers(self, location: GeoPoint, radius_km: float = 5.0, 
                          available_only: bool = True, exclude_user_id: Optional[UUID] = None) -> List[DriverLocation]:
        """
        Find drivers near a specific location
        
        Args:
            location: Center point to search around
            radius_km: Search radius in kilometers
            available_only: If True, only return available drivers
            exclude_user_id: Optional user ID to exclude from results (e.g., the user who placed the order)
            
        Returns:
            List of DriverLocation entities
        """
        pass
