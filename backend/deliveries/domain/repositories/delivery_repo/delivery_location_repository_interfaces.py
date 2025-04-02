from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities.delivery_entities import DeliveryLocation
from deliveries.domain.models.value_objects import GeoPoint


class DeliveryLocationRepository(ABC):
    """Interface for delivery location repository"""
    
    @abstractmethod
    def get_by_id(self, location_id: UUID) -> Optional[DeliveryLocation]:
        """Get a location by ID"""
        pass
    
    @abstractmethod
    def get_latest_by_delivery(self, delivery_id: UUID) -> Optional[DeliveryLocation]:
        """Get the latest location for a delivery"""
        pass
    
    @abstractmethod
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryLocation]:
        """List all locations for a delivery"""
        pass
    
    @abstractmethod
    def create(
        self,
        delivery_id: UUID,
        driver_id: UUID,
        location: GeoPoint
    ) -> DeliveryLocation:
        """Create a new location record
        
        Args:
            delivery_id: ID of the delivery
            driver_id: ID of the driver
            location: GeoPoint with latitude and longitude
            
        Returns:
            Created DeliveryLocation entity
        """
        pass
    
    @abstractmethod
    def list_by_proximity(self, location: GeoPoint, 
                         max_distance_km: float = 2.0) -> List[DeliveryLocation]:
        """List delivery locations within a specified distance from the given coordinates
        
        Args:
            location: Current location point
            max_distance_km: Maximum distance in kilometers (default 2km)
            
        Returns:
            List of delivery locations within the specified distance
        """
        pass

