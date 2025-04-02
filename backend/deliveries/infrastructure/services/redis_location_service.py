"""
Redis service for real-time location tracking and caching.

This module provides a service for storing and retrieving delivery location data
using Redis. It supports real-time location updates, caching of route information,
and efficient geospatial queries using Redis' built-in geospatial features.
This implementation follows the LocationCacheService interface defined in the domain layer.
"""
import json
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime
import redis

from django.conf import settings

from deliveries.domain.models.value_objects import GeoPoint, RouteInfo
from deliveries.domain.services.cache_location_service_interface import LocationCacheService

logger = logging.getLogger(__name__)

class RedisLocationService(LocationCacheService):
    """
    Redis-based service for real-time location tracking and caching
    
    This service uses Redis for:
    1. Storing current delivery locations with geospatial indexing
    2. Caching route information to reduce API calls to external services
    3. Maintaining a history of location updates for each delivery
    
    Redis data structures used:
    - Geo sets for spatial indexing (GEOADD, GEORADIUS)
    - Hashes for delivery metadata
    - Lists for location history
    - String keys with expiration for route caching
    """
    
    # Key prefixes for Redis
    CURRENT_LOCATIONS_KEY = "delivery:locations:current"
    LOCATION_HISTORY_KEY = "delivery:locations:history:{}"
    ROUTE_CACHE_KEY = "delivery:route:{}:{}"
    DELIVERY_META_KEY = "delivery:meta:{}"
    
    # Default expiration times
    ROUTE_CACHE_EXPIRY = 60 * 30  # 30 minutes
    LOCATION_HISTORY_MAX_SIZE = 100  # Max number of historical points to keep
    
    def __init__(self):
        """
        Initialize the Redis connection
        
        Connects to Redis using configuration from Django settings.
        Falls back to localhost if settings are not available.
        """
        try:
            redis_host = getattr(settings, 'REDIS_HOST', 'localhost')
            redis_port = getattr(settings, 'REDIS_PORT', 6379)
            redis_db = getattr(settings, 'REDIS_DB', 0)
            
            self.redis = redis.Redis(
                host=redis_host,
                port=redis_port,
                db=redis_db,
                decode_responses=True  # Automatically decode responses to strings
            )
            
            # Test connection
            self.redis.ping()
            logger.info(f"Connected to Redis at {redis_host}:{redis_port}/{redis_db}")
            
        except redis.ConnectionError as e:
            logger.error(f"Failed to connect to Redis: {str(e)}")
            self.redis = None
    
    def update_delivery_location(self, delivery_id: str, location: GeoPoint, 
                               driver_id: Optional[str] = None,
                               metadata: Optional[Dict[str, Any]] = None) -> bool:
        """
        Update the current location of a delivery
        
        This method:
        1. Adds the location to the geospatial index for current locations
        2. Adds the location to the delivery's location history
        3. Updates delivery metadata if provided
        
        Args:
            delivery_id: Unique identifier for the delivery
            location: Current geographic coordinates
            driver_id: Optional driver identifier
            metadata: Optional additional data to store with the location
            
        Returns:
            True if successful, False otherwise
        """
        if not self.redis:
            return False
            
        try:
            # Current timestamp
            timestamp = datetime.now().isoformat()
            
            # 1. Add to geospatial index
            self.redis.geoadd(
                self.CURRENT_LOCATIONS_KEY,
                longitude=location.longitude,
                latitude=location.latitude,
                member=delivery_id
            )
            
            # 2. Add to location history
            location_data = {
                "lat": location.latitude,
                "lng": location.longitude,
                "timestamp": timestamp,
                "driver_id": driver_id
            }
            
            # Add any additional metadata
            if metadata:
                location_data.update(metadata)
                
            # Add to the history list (newest first)
            history_key = self.LOCATION_HISTORY_KEY.format(delivery_id)
            self.redis.lpush(history_key, json.dumps(location_data))
            
            # Trim history to maximum size
            self.redis.ltrim(history_key, 0, self.LOCATION_HISTORY_MAX_SIZE - 1)
            
            # 3. Update delivery metadata if provided
            if metadata:
                meta_key = self.DELIVERY_META_KEY.format(delivery_id)
                self.redis.hmset(meta_key, metadata)
            
            return True
            
        except Exception as e:
            logger.error(f"Error updating location for delivery {delivery_id}: {str(e)}")
            return False
    
    def get_delivery_location(self, delivery_id: str) -> Optional[Dict[str, Any]]:
        """
        Get the current location of a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            
        Returns:
            Dictionary with location data or None if not found
        """
        if not self.redis:
            return None
            
        try:
            # Get coordinates from geospatial index
            pos = self.redis.geopos(self.CURRENT_LOCATIONS_KEY, delivery_id)
            
            if not pos or not pos[0]:
                return None
                
            # Get the most recent history entry for additional data
            history_key = self.LOCATION_HISTORY_KEY.format(delivery_id)
            latest = self.redis.lindex(history_key, 0)
            
            if latest:
                data = json.loads(latest)
                # Ensure coordinates are from the geospatial index (most accurate)
                data["lng"] = float(pos[0][0])
                data["lat"] = float(pos[0][1])
                return data
            else:
                # Return just the coordinates if no history
                return {
                    "lng": float(pos[0][0]),
                    "lat": float(pos[0][1])
                }
                
        except Exception as e:
            logger.error(f"Error getting location for delivery {delivery_id}: {str(e)}")
            return None
    
    def find_nearby_deliveries(self, location: GeoPoint, radius_km: float) -> List[Dict[str, Any]]:
        """
        Find deliveries within a specified radius of a location
        
        This method uses Redis' GEORADIUS command to efficiently find
        deliveries near a given point.
        
        Args:
            location: Center point to search from
            radius_km: Search radius in kilometers
            
        Returns:
            List of nearby deliveries with distance information
        """
        if not self.redis:
            return []
            
        try:
            # Find nearby deliveries using GEORADIUS
            nearby = self.redis.georadius(
                self.CURRENT_LOCATIONS_KEY,
                longitude=location.longitude,
                latitude=location.latitude,
                radius=radius_km,
                unit='km',
                withdist=True,  # Include distance in results
                withcoord=True,  # Include coordinates in results
                sort='ASC'       # Sort by distance (nearest first)
            )
            
            results = []
            for item in nearby:
                delivery_id, distance, coords = item
                
                # Get metadata if available
                meta_key = self.DELIVERY_META_KEY.format(delivery_id)
                metadata = self.redis.hgetall(meta_key) or {}
                
                # Build result object
                result = {
                    "delivery_id": delivery_id,
                    "distance_km": float(distance),
                    "location": {
                        "lng": float(coords[0]),
                        "lat": float(coords[1])
                    }
                }
                
                # Add metadata if available
                if metadata:
                    result.update(metadata)
                    
                results.append(result)
                
            return results
            
        except Exception as e:
            logger.error(f"Error finding nearby deliveries: {str(e)}")
            return []
    
    def cache_route(self, origin: GeoPoint, destination: GeoPoint, 
                  route_info: RouteInfo) -> bool:
        """
        Cache route information to reduce external API calls
        
        Args:
            origin: Starting point
            destination: Ending point
            route_info: Route information to cache
            
        Returns:
            True if successful, False otherwise
        """
        if not self.redis:
            return False
            
        try:
            # Create a key based on origin and destination
            cache_key = self.ROUTE_CACHE_KEY.format(
                f"{origin.latitude:.5f},{origin.longitude:.5f}",
                f"{destination.latitude:.5f},{destination.longitude:.5f}"
            )
            
            # Serialize route info
            route_data = {
                "distance_meters": route_info.distance_meters,
                "duration_seconds": route_info.duration_seconds,
                "polyline": route_info.polyline,
                "waypoints": [
                    {"lat": point.latitude, "lng": point.longitude}
                    for point in (route_info.waypoints or [])
                ]
            }
            
            # Store in Redis with expiration
            self.redis.setex(
                cache_key,
                self.ROUTE_CACHE_EXPIRY,
                json.dumps(route_data)
            )
            
            return True
            
        except Exception as e:
            logger.error(f"Error caching route: {str(e)}")
            return False
    
    def get_cached_route(self, origin: GeoPoint, 
                       destination: GeoPoint) -> Optional[Dict[str, Any]]:
        """
        Get cached route information if available
        
        Args:
            origin: Starting point
            destination: Ending point
            
        Returns:
            Cached route information or None if not found
        """
        if not self.redis:
            return None
            
        try:
            # Create a key based on origin and destination
            cache_key = self.ROUTE_CACHE_KEY.format(
                f"{origin.latitude:.5f},{origin.longitude:.5f}",
                f"{destination.latitude:.5f},{destination.longitude:.5f}"
            )
            
            # Get cached data
            cached = self.redis.get(cache_key)
            
            if cached:
                return json.loads(cached)
                
            return None
            
        except Exception as e:
            logger.error(f"Error getting cached route: {str(e)}")
            return None
    
    def get_location_history(self, delivery_id: str, 
                          limit: int = 20) -> List[Dict[str, Any]]:
        """
        Get location history for a delivery
        
        Args:
            delivery_id: Unique identifier for the delivery
            limit: Maximum number of history entries to return
            
        Returns:
            List of historical location points
        """
        if not self.redis:
            return []
            
        try:
            history_key = self.LOCATION_HISTORY_KEY.format(delivery_id)
            
            # Get history entries
            entries = self.redis.lrange(history_key, 0, limit - 1)
            
            # Parse JSON entries
            return [json.loads(entry) for entry in entries]
            
        except Exception as e:
            logger.error(f"Error getting location history for delivery {delivery_id}: {str(e)}")
            return []
