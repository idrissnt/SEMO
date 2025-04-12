from typing import List, Dict, Any

from store.domain.models.entities import StoreBrand
from store.domain.services.cache_service import CacheService
from store.domain.services.store_location_service import StoreLocationService
from store.domain.value_objects.coordinates import Coordinates
from store.domain.repositories.repository_interfaces import(
    StoreBrandRepository
)
from store.config.constants import (
    DEFAULT_SEARCH_RADIUS, 
    LOCATION_CACHE_TIMEOUT
)

class StoreBrandLocationService:
    """Application service for finding nearby store brands
    
    This service provides methods to find nearby store brands based on
    a user's address or coordinates. It orchestrates the interaction between
    repositories, location services, and caching services.
    """
    
    def __init__(self, 
                 store_brand_repository: StoreBrandRepository,
                 store_location_service: StoreLocationService,
                 cache_service: CacheService):
        self.store_brand_repository = store_brand_repository
        self.store_location_service = store_location_service
        self.cache_service = cache_service
    
    def find_nearby_store_brands_by_address(
        self,
        address: str,
        radius_km: float = DEFAULT_SEARCH_RADIUS,
    ) -> List[StoreBrand]:
        """Find nearby store brands using a user-provided address
        
        Args:
            address: User's address as a string
            radius_km: Search radius in kilometers
            
        Returns:
            List of StoreBrand objects with location information attached
        """

        if not address:
            # If geocoding fails, return all brands without locations
            return self.store_brand_repository.get_all_store_brands()

        # First, geocode the address to get coordinates
        geocode_result = self.store_location_service.geocode_address(address)
        
        coordinates, address_obj = geocode_result
        
        # Generate cache key based on location and brand_slugs
        cache_key = self.cache_service.generate_store_location_key(coordinates, radius_km, address)
        
        # Try to get from cache first
        cached_results = self.cache_service.get(cache_key)
        if cached_results:
            return cached_results
        
        # Cache miss - need to query for locations
        return self._find_and_cache_nearby_brands(coordinates, radius_km, cache_key)
    
    def _find_and_cache_nearby_brands(
        self,
        coordinates: Coordinates,
        radius_km: float,
        cache_key: str = None
    ) -> List[StoreBrand]:
        """Find nearby store brands and cache the results
        
        Args:
            coordinates: User's coordinates
            radius_km: Search radius in kilometers
            cache_key: Optional cache key to store results under
            
        Returns:
            List of StoreBrand objects with location information attached
        """
        # Get all store brands we need to search for
        store_brands = self.store_brand_repository.get_all_store_brands()
        
        # Find the closest location for each store brand
        results = []
        for brand in store_brands:
            # Search for this specific brand near the coordinates
            place = self.store_location_service.find_store_brand_by_name(
                name=brand.name,
                brand_type=brand.type,
                coordinates=coordinates,
                radius_km=radius_km
            )
            
            # If we found a place for this brand
            if place:
                # Create a copy of the brand with location data
                brand_with_location = self._create_brand_with_location(brand, place)
                results.append(brand_with_location)
            else:
                # No location found, skip this brand
                continue
        
        # Cache the results if we have a cache key
        if cache_key:
            self.cache_service.set(cache_key, results, LOCATION_CACHE_TIMEOUT)
        
        return results
    
    def _create_brand_with_location(self, brand: StoreBrand, place: Dict[str, Any]) -> StoreBrand:
        """Create a copy of a store brand with location information attached
        
        Args:
            brand: StoreBrand object to copy
            place: Place information from Google Maps API
            
        Returns:
            Copy of StoreBrand with location attributes added
        """
        # Create a copy of the brand
        store_brand = StoreBrand(
            id=brand.id,
            name=brand.name,
            type=brand.type,
            slug=brand.slug,
            image_logo=brand.image_logo,
            image_banner=brand.image_banner
        )
        
        # Add place information as attributes
        if 'distance' in place:
            # Convert from meters to kilometers
            distance_km = float(place['distance']) / 1000
            setattr(store_brand, 'distance_km', distance_km)
        
        # Add address information if available
        if 'address' in place:
            setattr(store_brand, 'address', place['address'])
        elif 'vicinity' in place:
            setattr(store_brand, 'address', place['vicinity'])
        
        # Add place_id for reference
        if 'place_id' in place:
            setattr(store_brand, 'place_id', place['place_id'])
            
        # Add coordinates if available
        if 'latitude' in place and 'longitude' in place:
            coordinates = Coordinates(
                latitude=place['latitude'],
                longitude=place['longitude']
            )
            setattr(store_brand, 'coordinates', coordinates)
            
        return store_brand
