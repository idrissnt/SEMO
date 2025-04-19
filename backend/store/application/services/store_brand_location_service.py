from typing import List, Dict, Any

from store.domain.models.entities import StoreBrand, StoreBrandLocation
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
    
    def list_all_store_brands(self) -> List[StoreBrand]:
        
        all_store_brands = self.store_brand_repository.get_all_store_brands()

        
        return all_store_brands


    def find_nearby_store_brands_by_address(
        self,
        address: str,
        radius_km: float = DEFAULT_SEARCH_RADIUS,
    ) -> List[StoreBrandLocation]:
        """Find nearby store brands using a user-provided address
        
        Args:
            address: User's address as a string
            radius_km: Search radius in kilometers
            
        Returns:
            List of StoreBrandLocation entities
        """

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
    ) -> List[StoreBrandLocation]:
        """Find nearby store brands and cache the results
        
        Args:
            coordinates: User's coordinates
            radius_km: Search radius in kilometers
            cache_key: Optional cache key to store results under
            
        Returns:
            List of StoreBrandLocation entities
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
    
    def _create_brand_with_location(self, brand: StoreBrand, place: Dict[str, Any]) -> StoreBrandLocation:
        """Create a StoreBrandLocation entity from brand and place info
        
        Args:
            brand: StoreBrand object
            place: Place information from location service
        Returns:
            StoreBrandLocation entity
        """
        distance_km = float(place['distance']) / 1000 if 'distance' in place else None
        address = place.get('address') or place.get('vicinity')
        place_id = place.get('place_id')
        coordinates = None
        if 'latitude' in place and 'longitude' in place:
            coordinates = Coordinates(latitude=place['latitude'], longitude=place['longitude'])
        return StoreBrandLocation(
            id=brand.id,
            name=brand.name,
            slug=brand.slug,
            type=brand.type,
            image_logo=brand.image_logo,
            image_banner=brand.image_banner,
            distance_km=distance_km,
            address=address,
            place_id=place_id,
            coordinates=coordinates
        )
