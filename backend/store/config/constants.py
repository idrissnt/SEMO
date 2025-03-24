# Cache settings
import decimal


CACHE_KEY_PREFIX = "store"
STATS_KEY_PREFIX = f"{CACHE_KEY_PREFIX}:stats"
GRID_KEY_PREFIX = f"{CACHE_KEY_PREFIX}:grid"
ADDRESS_KEY_PREFIX = f"{CACHE_KEY_PREFIX}:address"
BRAND_KEY_PREFIX = f"{CACHE_KEY_PREFIX}:brand"
LOCATION_KEY_PREFIX = f"{CACHE_KEY_PREFIX}:location"

# Coordinate precision for caching (in decimal places) 
# Users in the same area will share the same cache
# with 2 decimal places, Users within about 1.11 kilometers will share the same cache

# 2 decimal places ≈ 1.11 kilometers precision
# 3 decimal places ≈ 111 meters precision
# 4 decimal places ≈ 11 meters precision
# 5 decimal places ≈ 1.1 meters precision
COORDINATE_PRECISION = 2  # Adjust this value to control cache sharing area

# Cache timeouts (in seconds)
ADDRESS_CACHE_TIMEOUT = 86400  # 24 hours
STORES_CACHE_TIMEOUT = 3600  # 1 hour
GRID_CACHE_TIMEOUT = 604800  # 1 week
LOCATION_CACHE_TIMEOUT = 2592000  # 30 days
POPULAR_LOCATION_THRESHOLD = 5  # Number of hits to consider a location popular

# Grid precision for caching (in degrees)
GRID_PRECISION = 0.01  # Approximately 1km

# Default search radius (in km)
DEFAULT_SEARCH_RADIUS = 10

# Maximum number of results to return with Google Places API 
# for finding the nearest locations of stores brands
MAX_RESULTS_STORES_BRANDS_NEARBY = 10

# Cache timeout weights
COMPLEXITY_WEIGHT = 0.7
SIZE_WEIGHT = 0.3

# Cache timeout bounds
MIN_TIMEOUT = 300  # 5 minutes
MAX_TIMEOUT = 86400  # 24 hours
DEFAULT_TIMEOUT = 3600  # 1 hour
