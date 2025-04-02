"""
Maps service interface for the deliveries domain.

This module defines the interface for maps-related services that the delivery domain
can use without depending on specific implementations. This follows the Dependency
Inversion Principle from SOLID, allowing the domain to define the interface that
infrastructure implementations must adhere to.
"""
from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from datetime import datetime

from deliveries.domain.models.value_objects import GeoPoint, RouteInfo


class MapsServiceInterface(ABC):
    """Interface for maps service operations"""
    
    @abstractmethod
    def geocode_address(self, address: str) -> Optional[GeoPoint]:
        """
        Convert a text address to geographic coordinates
        
        Args:
            address: The address to geocode
            
        Returns:
            GeoPoint with latitude and longitude if successful, None otherwise
        """
        pass
    
    @abstractmethod
    def calculate_route(self, origin: GeoPoint, 
                       destination: GeoPoint) -> Optional[RouteInfo]:
        """
        Calculate a route between two points
        
        Args:
            origin: Starting point
            destination: Ending point
            
        Returns:
            RouteInfo containing distance, duration, and polyline data
        """
        pass
    
    @abstractmethod
    def estimate_travel_time(self, origin: GeoPoint, 
                           destination: GeoPoint,
                           departure_time: Optional[datetime] = None) -> int:
        """
        Estimate travel time between two points
        
        Args:
            origin: Starting point
            destination: Ending point
            departure_time: Optional departure time for traffic-based estimation
            
        Returns:
            Estimated travel time in seconds
        """
        pass
    
    @abstractmethod
    def find_nearby_places(self, location: GeoPoint, 
                         radius_km: float, 
                         place_type: str) -> List[Dict[str, Any]]:
        """
        Find nearby places of a specific type
        
        Args:
            location: Center point to search from
            radius_km: Search radius in kilometers
            place_type: Type of place to search for (e.g., 'hypermarket', 'supermarket')
            
        Returns:
            List of places with their details
        """
        pass
