from abc import ABC, abstractmethod
from typing import Any, List, Dict, Optional

from store.domain.value_objects.coordinates import Coordinates

class CacheService(ABC):
    """Interface for caching services"""
    
    @abstractmethod
    def get(self, key: str) -> Any:
        """Get a value from the cache
        
        Args:
            key: Cache key to look up
            
        Returns:
            Cached value if found, None otherwise
        """
        pass
    
    @abstractmethod
    def set(self, key: str, value: Any, timeout: int) -> None:
        """Set a value in the cache
        
        Args:
            key: Cache key to store under
            value: Value to store
            timeout: Cache timeout in seconds
        """
        pass
    
    @abstractmethod
    def set_with_adaptive_timeout(self, key: str, value: Any, 
                                 complexity: float = 0.5, 
                                 result_size: int = 0) -> None:
        """
        Set value in cache with TIMEOUT adjusted based on query complexity and result size
        
        Args:
            key: Cache key
            value: Value to cache
            complexity: Query complexity score (0-1), higher means more complex
            result_size: Size of result set (number of items)
        """
        pass
    
    @abstractmethod
    def generate_store_location_key(self, coordinates: Coordinates, 
                                   radius_km: float, brand_slugs: Optional[List[str]], 
                                   address: Optional[str] = None) -> str:
        """Generate a cache key for location-based data
        
        Args:
            coordinates: User's coordinates (latitude, longitude)
            radius_km: Search radius in kilometers
            brand_slugs: Optional list of brand slugs
            address: Optional user's address
            
        Returns:
            Cache key string
        """
        pass
    
    @abstractmethod
    def generate_search_key(self, query: str, 
                      store_id: Optional[str] = None, 
                      filters: Optional[Dict] = None) -> str:
        """
        Generate a standardized cache key for search queries
        
        Args:
            query: Search query string
            store_id: Optional store ID to scope the search
            filters: Optional dictionary of filters applied to the search
        
        Returns:
            Standardized cache key string
        """
        pass
    
    @abstractmethod
    def clear_cache(self, cache_type: str) -> None:
        """Clear specific or all cache types"""
        pass

    @abstractmethod
    def delete(self, key: str) -> None:
        """Delete a value from the cache
        
        Args:
            key: Cache key to delete
        """
        pass


    