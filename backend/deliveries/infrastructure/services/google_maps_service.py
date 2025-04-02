"""
Google Maps service implementation for the deliveries domain.

This module provides a concrete implementation of the MapsServiceInterface
using the Google Maps API. It handles geocoding, routing, travel time estimation,
and place search functionality.
"""
import logging
import googlemaps
from datetime import datetime
from typing import Dict, List, Optional, Any

from django.conf import settings

from deliveries.domain.models.value_objects import GeoPoint, RouteInfo
from deliveries.domain.services.maps_service_interface import MapsServiceInterface

logger = logging.getLogger(__name__)


class GoogleMapsService(MapsServiceInterface):
    """
    Google Maps implementation of maps service interface
    
    This service uses the Google Maps API to provide geospatial functionality
    for the deliveries domain. It encapsulates all Google Maps specific code
    to maintain a clean separation between the domain and external services.
    """
    
    def __init__(self):
        """
        Initialize the Google Maps client using API key from settings
        
        The API key is retrieved from Django settings, which should be
        configured in the settings file as GOOGLE_MAPS_API_KEY.
        """
        self.client = googlemaps.Client(key=settings.GOOGLE_MAPS_API_KEY)
    
    def geocode_address(self, address: str) -> Optional[GeoPoint]:
        """
        Convert a text address to geographic coordinates using Google Geocoding API
        
        Args:
            address: The address to geocode
            
        Returns:
            GeoPoint with latitude and longitude if successful, None otherwise
        """
        try:
            # Call Google Maps Geocoding API
            geocode_result = self.client.geocode(address)
            
            # Check if we got a valid result
            if geocode_result and len(geocode_result) > 0:
                location = geocode_result[0]['geometry']['location']
                return GeoPoint(
                    latitude=location['lat'],
                    longitude=location['lng']
                )
            
            logger.warning(f"No geocoding results found for address: {address}")
            return None
            
        except Exception as e:
            logger.error(f"Error geocoding address '{address}': {str(e)}")
            return None
    
    def calculate_route(self, origin: GeoPoint, 
                       destination: GeoPoint) -> Optional[RouteInfo]:
        """
        Calculate a route between two points using Google Directions API
        
        Args:
            origin: Starting point
            destination: Ending point
            
        Returns:
            RouteInfo containing distance, duration, and polyline data
        """
        try:
            # Call Google Maps Directions API
            directions = self.client.directions(
                origin=(origin.latitude, origin.longitude),
                destination=(destination.latitude, destination.longitude),
                mode="driving",
                departure_time=datetime.now()  # For traffic-based routing
            )
            
            # Check if we got a valid result
            if not directions or len(directions) == 0:
                logger.warning("No route found between the specified points")
                return None
            
            # Extract route information from the first route
            route = directions[0]
            leg = route['legs'][0]
            
            # Extract polyline for the route
            polyline = route['overview_polyline']['points']
            
            # Extract distance and duration
            distance_meters = leg['distance']['value']
            duration_seconds = leg['duration']['value']
            
            # Extract waypoints if available
            waypoints = []
            if 'steps' in leg:
                for step in leg['steps']:
                    start_point = GeoPoint(
                        latitude=step['start_location']['lat'],
                        longitude=step['start_location']['lng']
                    )
                    waypoints.append(start_point)
                
                # Add the final destination
                end_point = GeoPoint(
                    latitude=leg['end_location']['lat'],
                    longitude=leg['end_location']['lng']
                )
                waypoints.append(end_point)
            
            # Create and return RouteInfo
            return RouteInfo(
                origin=origin,
                destination=destination,
                distance_meters=distance_meters,
                duration_seconds=duration_seconds,
                polyline=polyline,
                waypoints=waypoints
            )
            
        except Exception as e:
            logger.error(f"Error calculating route: {str(e)}")
            return None
    
    def estimate_travel_time(self, origin: GeoPoint, 
                           destination: GeoPoint,
                           departure_time: Optional[datetime] = None) -> int:
        """
        Estimate travel time between two points using Google Distance Matrix API
        
        This method provides a more accurate travel time estimate than calculate_route
        as it specifically uses the Distance Matrix API which is optimized for
        this purpose and includes real-time traffic data.
        
        Args:
            origin: Starting point
            destination: Ending point
            departure_time: Optional departure time for traffic-based estimation
            
        Returns:
            Estimated travel time in seconds, 0 if estimation fails
        """
        try:
            # Use current time if departure_time not provided
            if departure_time is None:
                departure_time = datetime.now()
            
            # Call Google Maps Distance Matrix API
            matrix = self.client.distance_matrix(
                origins=[(origin.latitude, origin.longitude)],
                destinations=[(destination.latitude, destination.longitude)],
                mode="driving",
                departure_time=departure_time,
                traffic_model="best_guess"  # Options: "best_guess", "pessimistic", "optimistic"
            )
            
            # Check if we got a valid result
            if (matrix['rows'] and 
                matrix['rows'][0]['elements'] and 
                matrix['rows'][0]['elements'][0]['status'] == 'OK'):
                
                # Get duration in traffic if available, otherwise regular duration
                if 'duration_in_traffic' in matrix['rows'][0]['elements'][0]:
                    return matrix['rows'][0]['elements'][0]['duration_in_traffic']['value']
                else:
                    return matrix['rows'][0]['elements'][0]['duration']['value']
            
            logger.warning("No travel time estimation available for the specified points")
            return 0
            
        except Exception as e:
            logger.error(f"Error estimating travel time: {str(e)}")
            return 0
    
    def find_nearby_places(self, location: GeoPoint, 
                         radius_km: float, 
                         place_type: str) -> List[Dict[str, Any]]:
        """
        Find nearby places of a specific type using Google Places API
        
        Args:
            location: Center point to search from
            radius_km: Search radius in kilometers
            place_type: Type of place to search for (e.g., 'hypermarket', 'supermarket')
            
        Returns:
            List of places with their details
        """
        try:
            # Convert radius from km to meters for the API
            radius_meters = int(radius_km * 1000)
            
            # Call Google Maps Places Nearby API
            places_result = self.client.places_nearby(
                location=(location.latitude, location.longitude),
                radius=radius_meters,
                type=place_type
            )
            
            # Return the results list or empty list if no results
            return places_result.get('results', [])
            
        except Exception as e:
            logger.error(f"Error finding nearby places: {str(e)}")
            return []
