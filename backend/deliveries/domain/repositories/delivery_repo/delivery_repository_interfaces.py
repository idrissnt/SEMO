from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities.delivery_entities import Delivery
from deliveries.domain.models.value_objects import GeoPoint

from datetime import datetime

class DeliveryRepository(ABC):
    """Interface for delivery repository"""
    
    @abstractmethod
    def get_by_id(self, delivery_id: UUID) -> Optional[Delivery]:
        """Get a delivery by ID"""
        pass
    
    @abstractmethod
    def get_by_order_id(self, order_id: UUID) -> Optional[Delivery]:
        """Get a delivery by order ID"""
        pass
    
    @abstractmethod
    def list_by_driver(self, driver_id: UUID) -> List[Delivery]:
        """List all deliveries for a driver"""
        pass
    
    @abstractmethod
    def list_by_status(self, status: str) -> List[Delivery]:
        """List all deliveries with a specific status"""
        pass
    
    @abstractmethod
    def create(self, order_id: UUID) -> Delivery:
        """Create a new delivery"""
        pass
    
    @abstractmethod
    def update_status(self, delivery_id: UUID, status: str) -> Optional[Delivery]:
        """Update delivery status"""
        pass
    
    @abstractmethod
    def assign_driver(self, delivery_id: UUID, driver_id: UUID) -> Optional[Delivery]:
        """Assign a driver to a delivery"""
        pass
    
    @abstractmethod
    def list_by_proximity(self, location: GeoPoint, max_distance_km: float = 2.0,
                         status: Optional[str] = None) -> List[Delivery]:
        """List deliveries within a specified distance from the given coordinates
        
        Args:
            location: Current location point
            max_distance_km: Maximum distance in kilometers (default 2km)
            status: Optional status filter
            
        Returns:
            List of deliveries within the specified distance
        """
        pass
    
    @abstractmethod
    def update_delivery_locations(self, delivery_id: UUID, 
                                delivery_location: Optional[GeoPoint] = None,
                                store_location: Optional[GeoPoint] = None) -> Optional[Delivery]:
        """Update the geospatial locations for a delivery
        
        Args:
            delivery_id: ID of the delivery to update
            delivery_location: Optional delivery destination coordinates
            store_location: Optional store coordinates
            
        Returns:
            Updated delivery or None if not found
        """
        pass
    
    @abstractmethod
    def update_estimated_arrival(self, delivery_id: UUID, 
                               estimated_arrival_time: datetime) -> Optional[Delivery]:
        """Update the estimated arrival time for a delivery
        
        Args:
            delivery_id: ID of the delivery to update
            estimated_arrival_time: New estimated arrival time
            
        Returns:
            Updated delivery or None if not found
        """
        pass
