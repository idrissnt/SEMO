from dataclasses import dataclass
import math

@dataclass(frozen=True)
class Coordinates:
    """Value object representing geographic coordinates"""
    latitude: float
    longitude: float
    
    def distance_to(self, other):
        """Calculate distance in kilometers using Haversine formula"""
        R = 6371  # Earth radius in kilometers
        
        lat1_rad = math.radians(float(self.latitude))
        lon1_rad = math.radians(float(self.longitude))
        lat2_rad = math.radians(float(other.latitude))
        lon2_rad = math.radians(float(other.longitude))
        
        dlon = lon2_rad - lon1_rad
        dlat = lat2_rad - lat1_rad
        
        a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        
        return R * c