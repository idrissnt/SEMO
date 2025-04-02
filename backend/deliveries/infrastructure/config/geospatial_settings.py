"""
Configuration settings for geospatial functionality.

This module provides configuration settings for geospatial functionality,
including Google Maps API, Redis, and PostGIS. These settings can be imported
into the main Django settings file.
"""
from decouple import config

# Google Maps API settings
GOOGLE_MAPS_API_KEY = config('GOOGLE_MAPS_API_KEY', default='')

# Redis settings for real-time location tracking
REDIS_HOST = config('REDIS_HOST', default='localhost')
REDIS_PORT = config('REDIS_PORT', default=6379, cast=int)
REDIS_DB = config('REDIS_DB', default=0, cast=int)
REDIS_PASSWORD = config('REDIS_PASSWORD', default=None)

# PostGIS settings
POSTGIS_SRID = 4326  # WGS84 coordinate system

# Geospatial query settings
DEFAULT_SEARCH_RADIUS_KM = 5.0  # Default radius for proximity searches
MAX_SEARCH_RADIUS_KM = 50.0  # Maximum allowed radius for proximity searches

# Location update settings
MIN_LOCATION_UPDATE_INTERVAL_SECONDS = 10  # Minimum time between location updates
LOCATION_HISTORY_MAX_ENTRIES = 100  # Maximum number of location history entries to keep

# Route calculation settings
ROUTE_CACHE_EXPIRY_SECONDS = 1800  # 30 minutes
ROUTE_CALCULATION_TIMEOUT_SECONDS = 10  # Timeout for route calculation requests

# Geocoding settings
GEOCODING_CACHE_EXPIRY_SECONDS = 86400  # 24 hours
GEOCODING_TIMEOUT_SECONDS = 5  # Timeout for geocoding requests
