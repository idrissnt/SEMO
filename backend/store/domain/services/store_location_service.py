from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, Tuple

from backend.store.domain.value_objects.coordinates import Coordinates
from backend.store.domain.value_objects.address import Address


class StoreLocationService(ABC):
    """Interface for location-related services"""
    
    @abstractmethod
    def geocode_address(self, address: str) -> Optional[Tuple[Coordinates, Address]]:
        """Convert an address string to coordinates and structured address
        
        Args:
            address: Address string to geocode
            
        Returns:
            Tuple of (Coordinates, Address) if successful, None otherwise
        """
        pass
    
    @abstractmethod
    def find_store_brand_by_name(self, name: str, brand_type: str, coordinates: Coordinates, radius_km: float) -> Optional[Dict[str, Any]]:
        """Find a store brand by name near the specified coordinates
        
        Args:
            name: Name of the store brand to search for
            brand_type: Type of the brand to search for
            coordinates: Center point for the search
            radius_km: Search radius in kilometers
            
        Returns:
            Store brand information if found, None otherwise
        """
        pass



