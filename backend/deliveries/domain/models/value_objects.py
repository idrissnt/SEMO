"""
Value objects for the deliveries domain.

This module contains immutable value objects that represent concepts in the deliveries domain.
These objects encapsulate domain logic related to their specific concept without having
an identity of their own.
"""
from dataclasses import dataclass
from typing import Optional, Dict, Any
from enum import Enum
import math


@dataclass(frozen=True)
class GeoPoint:
    """
    Value object representing a geographic point with latitude and longitude.
    
    This is immutable (frozen) to ensure it behaves as a true value object.
    Contains methods for calculating distances and comparing locations.
    """
    latitude: float
    longitude: float
    
    def __post_init__(self):
        """Validate latitude and longitude values"""
        if not -90 <= self.latitude <= 90:
            raise ValueError(f"Latitude must be between -90 and 90, got {self.latitude}")
        if not -180 <= self.longitude <= 180:
            raise ValueError(f"Longitude must be between -180 and 180, got {self.longitude}")
    
    def distance_to(self, other: 'GeoPoint') -> float:
        """
        Calculate distance in kilometers to another point using the Haversine formula.
        
        The Haversine formula determines the great-circle distance between two points
        on a sphere given their longitudes and latitudes.
        
        Args:
            other: Another GeoPoint to calculate distance to
            
        Returns:
            Distance in kilometers
        """
        # Earth radius in kilometers
        earth_radius = 6371.0
        
        # Convert latitude and longitude from degrees to radians
        lat1 = math.radians(self.latitude)
        lon1 = math.radians(self.longitude)
        lat2 = math.radians(other.latitude)
        lon2 = math.radians(other.longitude)
        
        # Haversine formula
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        distance = earth_radius * c
        
        return distance
    
    def to_dict(self) -> Dict[str, float]:
        """Convert to dictionary representation"""
        return {
            'latitude': self.latitude,
            'longitude': self.longitude
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> Optional['GeoPoint']:
        """Create a GeoPoint from a dictionary"""
        if not data or 'latitude' not in data or 'longitude' not in data:
            return None
        
        try:
            return cls(
                latitude=float(data['latitude']),
                longitude=float(data['longitude'])
            )
        except (ValueError, TypeError):
            return None


@dataclass(frozen=True)
class RouteInfo:
    """
    Value object representing route information between two geographic points.
    
    Contains details about the route such as distance, duration, and waypoints.
    """
    origin: GeoPoint
    destination: GeoPoint
    distance_meters: int
    duration_seconds: int
    polyline: str  # Encoded polyline string representing the route
    waypoints: Optional[list[GeoPoint]] = None
    
    @property
    def distance_km(self) -> float:
        """Get distance in kilometers"""
        return self.distance_meters / 1000.0
    
    @property
    def duration_minutes(self) -> float:
        """Get duration in minutes"""
        return self.duration_seconds / 60.0
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary representation"""
        return {
            'origin': self.origin.to_dict(),
            'destination': self.destination.to_dict(),
            'distance': {
                'meters': self.distance_meters,
                'kilometers': self.distance_km
            },
            'duration': {
                'seconds': self.duration_seconds,
                'minutes': self.duration_minutes
            },
            'polyline': self.polyline,
            'waypoints': [wp.to_dict() for wp in self.waypoints] if self.waypoints else []
        }


class NotificationStatus(Enum):
    """Notification status value object"""
    PENDING = "pending"
    SENT = "sent"
    ACCEPTED = "accepted"
    REFUSED = "refused"
    CANCELLED = "cancelled"
