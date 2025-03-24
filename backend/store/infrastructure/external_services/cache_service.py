from typing import Any, Dict, Optional, List
import json
import hashlib
from django.core.cache import cache
from backend.store.domain.services.cache_service import CacheService
from backend.store.domain.value_objects.coordinates import Coordinates
from backend.store.config.constants import (
    CACHE_KEY_PREFIX,
    ADDRESS_KEY_PREFIX,
    BRAND_KEY_PREFIX,
    LOCATION_KEY_PREFIX,
    MIN_TIMEOUT,
    MAX_TIMEOUT,
    COMPLEXITY_WEIGHT,
    SIZE_WEIGHT,
    COORDINATE_PRECISION
)

class DjangoCacheService(CacheService):
    """Service for caching data with monitoring capabilities"""
    
    def get(self, key: str) -> Any:
        """Get value from cache"""
        return cache.get(key)
    
    def set(self, key: str, value: Any, timeout: int) -> None:
        """Set value in cache"""
        cache.set(key, value, timeout)
    
    def set_with_adaptive_timeout(self, key: str, value: Any, 
                                 complexity: float = 0.5, 
                                 result_size: int = 0) -> None:
        """
        Set value in cache with TIMEOUT adjusted based on query complexity and result size
        
        The TIMEOUT calculation logic:
        - More complex queries get longer TIMEOUT (they're expensive to recompute)
        - Larger result sets get shorter TIMEOUT (they consume more memory)
        - The final TIMEOUT is a weighted combination of these factors
        """
        # Normalize complexity to 0-1 range
        complexity = max(0.0, min(1.0, complexity))
        
        # Calculate size factor (0-1 range, inversely proportional to size)
        # Larger results get lower values (shorter TIMEOUT)
        size_factor = 1.0 / (1.0 + (result_size / 100.0))
        size_factor = max(0.1, min(1.0, size_factor))
        
        # Calculate weighted score
        weighted_score = (
            (complexity * COMPLEXITY_WEIGHT) + 
            (size_factor * SIZE_WEIGHT)
        )
        
        # Calculate TIMEOUT based on weighted score
        timeout_range = MAX_TIMEOUT - MIN_TIMEOUT
        adaptive_timeout = int(MIN_TIMEOUT + (weighted_score * timeout_range))
        
        # Set with calculated TIMEOUT
        self.set(key, value, adaptive_timeout)

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
        # Round coordinates based on configured precision
        lat_rounded = round(coordinates.latitude, COORDINATE_PRECISION)
        lng_rounded = round(coordinates.longitude, COORDINATE_PRECISION)
        
        # Create base key with coordinates and radius
        if address:
            key = f"{LOCATION_KEY_PREFIX}:{address}:{lat_rounded}:{lng_rounded}:{radius_km}"
        else:
            key = f"{LOCATION_KEY_PREFIX}:{lat_rounded}:{lng_rounded}:{radius_km}"
        
        # Sort to ensure consistent key regardless of order
        sorted_slugs = sorted(brand_slugs)
        brands_str = "-".join(sorted_slugs)
        key = f"{key}:{brands_str}"
            
        return key

    def generate_search_key(self, query: str, store_id: Optional[str] = None, 
                      filters: Optional[Dict] = None) -> str:
        """Generate a standardized cache key for search queries"""
        # Normalize query (lowercase, trim whitespace)
        normalized_query = query.lower().strip()
        
        # Create a dictionary of all parameters
        key_parts = {
            'q': normalized_query,
            'store': store_id,
        }
        
        # Add filters if provided
        if filters:
            # Sort filter keys for consistent ordering
            for k in sorted(filters.keys()):
                key_parts[f'filter_{k}'] = filters[k]
        
        # Convert to JSON string and hash it
        key_json = json.dumps(key_parts, sort_keys=True)
        key_hash = hashlib.md5(key_json.encode()).hexdigest()
        
        # Create final key
        prefix = 'store_search'
        if store_id:
            return f"{prefix}:store:{store_id}:{key_hash}"
        else:
            return f"{prefix}:global:{key_hash}"

    def clear_cache(self, cache_type: Optional[str] = None) -> None:
        """Clear specific or all cache types"""
        if cache_type == 'address':
            cache.delete_pattern(f"{ADDRESS_KEY_PREFIX}:*")
        elif cache_type == 'brand':
            cache.delete_pattern(f"{BRAND_KEY_PREFIX}:*")
        else:
            cache.delete_pattern(f"{CACHE_KEY_PREFIX}:*")

    def delete(self, key: str) -> None:
        """Delete value from cache"""
        cache.delete(key)