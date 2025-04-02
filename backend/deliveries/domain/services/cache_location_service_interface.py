"""
Interface for location caching service.

This module defines the interface that all location caching implementations
must adhere to, following the Dependency Inversion Principle of Clean Architecture.
"""
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, Tuple
from uuid import UUID
from datetime import datetime

from deliveries.domain.models.value_objects import GeoPoint, RouteInfo


class LocationCacheService(ABC):
    """
    Interface for location caching and real-time tracking services
    
    This interface defines the contract that all location caching implementations
    must follow, regardless of the underlying technology (Redis, Memcached, etc.).
    """
    
    @abstractmethod
    def update_delivery_location(self, delivery_id: UUID, location: GeoPoint, 
                               driver_id: Optional[UUID] = None,
                               metadata: Optional[Dict[str, Any]] = None) -> bool:
        """
        Update the current location of a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            location: Current geographic coordinates
            driver_id: Optional driver identifier
            metadata: Optional additional data to store with the location
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def get_delivery_location(self, delivery_id: UUID) -> Optional[Tuple[GeoPoint, datetime]]:
        """
        Get the current location of a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            
        Returns:
            Tuple of (location, timestamp) if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_delivery_location_history(self, delivery_id: UUID, 
                                    limit: int = 20) -> List[Tuple[GeoPoint, datetime]]:
        """
        Get the location history for a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            limit: Maximum number of history entries to return
            
        Returns:
            List of (location, timestamp) tuples, ordered by most recent first
        """
        pass
    
    @abstractmethod
    def find_nearby_deliveries(self, location: GeoPoint, radius_km: float = 5.0) -> List[Tuple[UUID, GeoPoint, float]]:
        """
        Find deliveries near a specific location
        
        Args:
            location: Center point for the search
            radius_km: Search radius in kilometers
            
        Returns:
            List of (delivery_id, location, distance) tuples, ordered by distance
        """
        pass
    
    @abstractmethod
    def cache_route(self, origin: GeoPoint, destination: GeoPoint, 
                  route_info: RouteInfo, expiry_seconds: int = 1800) -> bool:
        """
        Cache route information between two points
        
        Args:
            origin: Starting point
            destination: Ending point
            route_info: Route information to cache
            expiry_seconds: Time in seconds before the cache expires
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def get_cached_route(self, origin: GeoPoint, destination: GeoPoint) -> Optional[RouteInfo]:
        """
        Get cached route information between two points
        
        Args:
            origin: Starting point
            destination: Ending point
            
        Returns:
            RouteInfo if found in cache, None otherwise
        """
        pass
    
    @abstractmethod
    def update_delivery_eta(self, delivery_id: UUID, eta: datetime) -> bool:
        """
        Update the estimated time of arrival for a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            eta: Estimated time of arrival
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def get_delivery_eta(self, delivery_id: UUID) -> Optional[datetime]:
        """
        Get the estimated time of arrival for a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            
        Returns:
            Estimated time of arrival if available, None otherwise
        """
        pass
    
    @abstractmethod
    def clear_delivery_data(self, delivery_id: UUID) -> bool:
        """
        Remove all cached data for a delivery
        
        This should be called when a delivery is completed or cancelled.
        
        Args:
            delivery_id: Unique identifier for the delivery
            
        Returns:
            True if successful, False otherwise
        """
        pass
