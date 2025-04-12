"""Development settings for Django project.

These settings extend the base settings and add development-specific configurations.
"""
from .base import *
from decouple import config  # Install python-decouple first: pip install python-decouple

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config('DJANGO_SECRET_KEY_DEV', default='django-insecure-development-key-for-testing-only')

# Development server and mobile testing hosts
ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '10.0.2.2',      # Android emulator
    '172.20.10.5',   # Physical device IP
    '172.20.10.10',  # Physical device IP
    '192.168.187.184',  # Physical device IP
]

# Development WebSocket URL - used by frontend clients to connect to the WebSocket server
# Override the base setting with development-specific URL
WEBSOCKET_URL = 'ws://localhost:8000/ws'

# Database configuration - using environment variables from .env file
DATABASES = {
    'default': {
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'NAME': config('DB_NAME_DEV'),
        'USER': config('DB_USER_DEV'),
        'PASSWORD': config('DB_PASSWORD_DEV'),
        'HOST': config('DB_HOST_DEV'),
        'PORT': config('DB_PORT_DEV'),
    }
}

# CORS settings for development
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = True  # Only for development!
CORS_ALLOW_ALL_HEADERS = True
CORS_ALLOW_METHODS = [
    "DELETE",
    "GET",
    "OPTIONS",
    "PATCH",
    "POST",
    "PUT",
]

# For specific origins (if we disable CORS_ALLOW_ALL_ORIGINS)
# CORS_ALLOWED_ORIGINS = [
#     "http://192.168.187.184:8000",  # Physical device
#     "http://172.20.10.5:8000",     # Physical device
#     "http://localhost:8000",       # Local development
#     "http://127.0.0.1:8000",       # Local development alternative
# ]

# Stripe settings
STRIPE_SECRET_KEY = config('STRIPE_SECRET_KEY_DEV', default='sk_test_your_test_key_here')
STRIPE_WEBHOOK_SECRET = config('STRIPE_WEBHOOK_SECRET_DEV', default='whsec_your_webhook_secret_here')

# Google Maps API
GOOGLE_MAPS_API_KEY = config('GOOGLE_MAPS_API_KEY_DEV')

# Redis URL for development
# This will be used for caching, channels, and sessions
REDIS_URL = config('REDIS_URL_DEV', default='redis://localhost:6379')

# Override channel layers configuration with development Redis URL
CHANNEL_LAYERS['default']['CONFIG']['hosts'] = [f"{REDIS_URL}/0"]  # DB 0 for channels

# Override Redis cache configuration with development Redis URL
CACHES['default']['LOCATION'] = f"{REDIS_URL}/1"  # DB 1 for caching

# Celery broker URL for development
# Using RabbitMQ by default, but can be configured to use Redis
CELERY_BROKER_URL = config('CELERY_BROKER_URL_DEV', default='amqp://guest:guest@localhost:5672//')
# Uncomment to use Redis as message broker instead
# CELERY_BROKER_URL = config('REDIS_BROKER_URL_DEV', default=f"{REDIS_URL}/0")

# JWT token settings for development
# Use longer token lifetimes for easier development and testing
from datetime import timedelta
SIMPLE_JWT = {
    # Development token lifetimes - longer for easier testing
    # When the access token expires after 24 hours, 
    # the app uses the refresh token to get a new access token
    # Because token rotation is enabled, the user also gets a new 
    # refresh token with a fresh 30-day expiration
    # This process repeats each time the access token expires
    # As long as the user uses the app at least once every 30 days, 
    # they'll keep getting new refresh tokens
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=24),    # 24 hours for development
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),    # 30 days for development
    
    # Token rotation - when a refresh token is used, a new one is issued
    # This allows users to stay logged in as long as they're active
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    
    # Other JWT settings
    'UPDATE_LAST_LOGIN': False,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': config('DJANGO_SECRET_KEY_DEV'),  # Uses the development SECRET_KEY
    'VERIFYING_KEY': None,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
}

# AWS S3 Configuration
# Core AWS credentials and bucket settings
AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID_DEV')
AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY_DEV')
AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME_DEV')
AWS_S3_REGION_NAME = config('AWS_S3_REGION_NAME_DEV')
AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.{AWS_S3_REGION_NAME}.amazonaws.com'

# Security and access settings
# Disable ACLs since the bucket has Object Ownership set to 'Bucket owner enforced'
AWS_DEFAULT_ACL = None  # Don't set ACL on the files
AWS_BUCKET_ACL = None  # Don't set ACL on the bucket
AWS_QUERYSTRING_AUTH = False  # Disables signed URLs for cleaner URLs in mobile app

# File handling settings
AWS_S3_OVERWRITE = True  # Whether to overwrite files with the same name

# Cache settings - optimized for mobile apps
# Using 30 days cache to reduce bandwidth usage and improve mobile app performance
AWS_S3_OBJECT_PARAMETERS = {
    'CacheControl': 'max-age=2592000',  # 30 days in seconds
}

# Using custom storage backend for better organization following DDD principles
# This separates the storage concerns and puts media files in a dedicated location
DEFAULT_FILE_STORAGE = 'backend.settings.storage_backends.MediaStorage'
# previously : # DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

# CloudFront configuration
# For development, we'll continue using the direct S3 URL
# In production, this should be our CloudFront domain
CLOUDFRONT_DOMAIN = config('CLOUDFRONT_DOMAIN', default=AWS_S3_CUSTOM_DOMAIN)

# Media URL for accessing uploaded files
# In development, this uses the S3 URL directly
# In production, this will use CloudFront
# for production # MEDIA_URL = f'https://{CLOUDFRONT_DOMAIN}/media/'
MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/media/'


# Local fallback for development
if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
    print("WARNING: AWS credentials not found. S3 file storage will not work.")
    # In this case, you might want to set up local file storage as fallback
