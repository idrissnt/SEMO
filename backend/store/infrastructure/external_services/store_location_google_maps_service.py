import os
from typing import Optional, Dict, Any, List, Tuple
from googlemaps import Client
from django.conf import settings
from unittest.mock import MagicMock

from backend.store.domain.value_objects.coordinates import Coordinates
from backend.store.domain.value_objects.address import Address
from backend.store.domain.services.store_location_service import StoreLocationService
from backend.store.config.constants import MAX_RESULTS_STORES_BRANDS_NEARBY


class GoogleMapsService(StoreLocationService):
    """Service for interacting with Google Maps API"""
    
    def __init__(self, test_mode=False):
        """Initialize the Google Maps service.

        Args:
            test_mode: If True, skips API key validation and uses mock client
        """
        if test_mode:
            self.client = MagicMock()
            return

        try:
            api_key = settings.GOOGLE_MAPS_API_KEY
        except (ImportError, AttributeError):
            api_key = os.getenv('GOOGLE_MAPS_API_KEY')
        
        if not api_key:
            raise ValueError("GOOGLE_MAPS_API_KEY must be provided either in Django settings or as an environment variable")
    
        self.client = Client(key=api_key)
    
    def geocode_address(self, address_str: str) -> Optional[Tuple[Coordinates, Address]]:
        """Convert address string to coordinates and structured address"""
        try:
            results = self.client.geocode(address_str)
            if not results:
                return None
                
            result = results[0]
            
            # Extract location
            location = result['geometry']['location']
            coordinates = Coordinates(
                latitude=location['lat'],
                longitude=location['lng']
            )
            
            # Extract address components
            address_components = result['address_components']
            street_number = ""
            route = ""
            city = ""
            postal_code = ""
            country = ""
            
            for component in address_components:
                if 'street_number' in component['types']:
                    street_number = component['long_name']
                elif 'route' in component['types']:
                    route = component['long_name']
                elif 'locality' in component['types']:
                    city = component['long_name']
                elif 'postal_code' in component['types']:
                    postal_code = component['long_name']
                elif 'country' in component['types']:
                    country = component['long_name']
            
            address = Address(
                street_number=street_number,
                route=route,
                city=city,
                postal_code=postal_code,
                country=country
            )
            
            return coordinates, address
        except Exception as e:
            # Log the error
            print(f"Error geocoding address: {e}")
            return None

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
        # Convert km to meters for the API
        radius_m = int(radius_km * 1000)
        
        # Search for places with the given name
        places = self._find_store_brands_nearby(
            coordinates=coordinates,
            radius_m=radius_m,
            type=brand_type, # the type of the brand (e.g. supermarket, hypermarket, etc.)
            keyword=name,
        )
        
        # Return the first (closest) match, or None if no matches
        return places[0] if places else None
    
    def _find_store_brands_nearby(self, coordinates: Coordinates, radius_m: int, 
                          type: str, keyword: str = None) -> List[Dict[str, Any]]:
        """Find nearby store brands using Google Places API
        
        Args:
            coordinates: The coordinates to search around
            radius_m: Search radius in meters
            keyword: Optional keyword to filter results (e.g., 'supermarket')
            type: Optional place type (e.g., 'store', 'supermarket')
            
        Returns:
            List of store brand results with location and address information
        """
        # Prepare the location tuple for the API
        location = (coordinates.latitude, coordinates.longitude)
        
        # Make the nearby search request
        places_result = self.client.places_nearby(
            location=location,
            radius=radius_m,
            keyword=keyword,
            type=type,
            rank_by='distance' if radius_m > 50000 else None  # Use rank_by for large radii
        )
        
        # Process and enhance the results
        places = []
        for place in places_result.get('results', [])[:MAX_RESULTS_STORES_BRANDS_NEARBY]:
            # Extract basic information
            place_info = {
                'place_id': place.get('place_id'),
                'name': place.get('name'),
                'vicinity': place.get('vicinity', ''),
                'types': place.get('types', []),
                'business_status': place.get('business_status'),
                'rating': place.get('rating'),
                'user_ratings_total': place.get('user_ratings_total'),
            }
            
            # Extract location information
            if 'geometry' in place and 'location' in place['geometry']:
                location = place['geometry']['location']
                place_info['latitude'] = location.get('lat')
                place_info['longitude'] = location.get('lng')
                
                # Calculate distance from search point
                from math import radians, cos, sin, asin, sqrt
                def haversine(lat1, lon1, lat2, lon2):
                    # Convert decimal degrees to radians
                    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
                    # Haversine formula
                    dlon = lon2 - lon1
                    dlat = lat2 - lat1
                    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                    c = 2 * asin(sqrt(a))
                    r = 6371000  # Radius of earth in meters
                    return c * r
                
                # Calculate distance
                distance = haversine(
                    coordinates.latitude, coordinates.longitude,
                    place_info['latitude'], place_info['longitude']
                )
                place_info['distance'] = distance  # Distance in meters
            
            # Parse address components from vicinity
            address_parts = place_info['vicinity'].split(', ')
            if len(address_parts) >= 2:
                # Simple parsing - this could be enhanced with more detailed address parsing
                street = address_parts[0]
                city = address_parts[-1]
                
                # Try to extract street number and route
                import re
                street_match = re.match(r'^(\d+)\s+(.+)$', street)
                if street_match:
                    place_info['street_number'] = street_match.group(1)
                    place_info['route'] = street_match.group(2)
                else:
                    place_info['street_number'] = ''
                    place_info['route'] = street
                
                place_info['city'] = city
                
                # Create an Address object
                address = Address(
                    street_number=place_info.get('street_number', ''),
                    route=place_info.get('route', ''),
                    city=place_info.get('city', ''),
                    postal_code='',  # Not available in nearby search
                    country=''  # Not available in nearby search
                )
                place_info['address'] = address
            
            places.append(place_info)
        
        return places
    