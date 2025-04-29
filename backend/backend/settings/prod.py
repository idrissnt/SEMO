"""Production settings for Django project.

These settings extend the base settings and add production-specific configurations.
Security and performance optimizations are the focus of this file.
"""
import os
from .base import *

# SECURITY WARNING: ensure DEBUG is False in production!
DEBUG = False

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY_PROD', default='django-insecure-production-key-for-testing-only')

# Restrict allowed hosts in production to those specified in environment variable
# Format should be: 'example.com,api.example.com,www.example.com'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

# Production WebSocket URL - used by frontend clients to connect to the WebSocket server
# In production, this should use secure WebSockets (wss://) and your domain name
WEBSOCKET_URL = os.environ.get('WEBSOCKET_URL', 'wss://api.yourdomain.com/ws')

# Database configuration - using environment variables
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME_PROD'),
        'USER': os.environ.get('DB_USER_PROD'),
        'PASSWORD': os.environ.get('DB_PASSWORD_PROD'),
        'HOST': os.environ.get('DB_HOST_PROD'),
        'PORT': os.environ.get('DB_PORT_PROD'),
        # Production database optimizations
        'CONN_MAX_AGE': 60,  # Keep connections alive for 60 seconds
        'OPTIONS': {
            'connect_timeout': 10,
        },
    }
}

# Security settings - HTTPS and security headers
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# CORS settings - restrict to specific origins in production
# Format should be: 'https://example.com,https://api.example.com'
CORS_ALLOWED_ORIGINS = os.environ.get('CORS_ALLOWED_ORIGINS_PROD', '').split(',')
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = False  # Ensure this is False in production
CORS_ALLOW_ALL_HEADERS = False  # More restrictive in production
CORS_ALLOW_METHODS = [
    "DELETE",
    "GET",
    "OPTIONS",
    "PATCH",
    "POST",
    "PUT",
]
# Optionally, specify allowed headers for extra security
# CORS_ALLOWED_HEADERS = [
#     'accept',
#     'accept-encoding',
#     'authorization',
#     'content-type',
#     'dnt',
#     'origin',
#     'user-agent',
#     'x-csrftoken',
#     'x-requested-with',
# ]

# Stripe settings
STRIPE_SECRET_KEY = os.environ.get('STRIPE_SECRET_KEY_PROD')
STRIPE_WEBHOOK_SECRET = os.environ.get('STRIPE_WEBHOOK_SECRET_PROD')

# Google Maps API
GOOGLE_MAPS_API_KEY = os.environ.get('GOOGLE_MAPS_API_KEY_PROD')

# SendGrid Configuration (for email delivery)
SENDGRID_API_KEY = os.environ.get('SENDGRID_API_KEY')
DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL', 'noreply@yourdomain.com')

# Configure email backend based on SendGrid availability
if SENDGRID_API_KEY:
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = 'smtp.sendgrid.net'
    EMAIL_PORT = 587
    EMAIL_USE_TLS = True
    EMAIL_HOST_USER = 'apikey'  # This is exactly the string 'apikey'
    EMAIL_HOST_PASSWORD = SENDGRID_API_KEY
else:
    # Fallback to console backend if SendGrid is not configured
    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
    print("WARNING: SendGrid not configured. Emails will be printed to console.")

# OVH SMS Configuration (preferred for France) for send messages via sms
OVH_APPLICATION_KEY = os.environ.get('OVH_APPLICATION_KEY')
OVH_APPLICATION_SECRET = os.environ.get('OVH_APPLICATION_SECRET')
OVH_CONSUMER_KEY = os.environ.get('OVH_CONSUMER_KEY')
OVH_SMS_SERVICE_NAME = os.environ.get('OVH_SMS_SERVICE_NAME')
OVH_SMS_SENDER = os.environ.get('OVH_SMS_SENDER')

# Verification Settings
VERIFICATION_CODE_EXPIRY_MINUTES = int(os.environ.get('VERIFICATION_CODE_EXPIRY_MINUTES', 15))

# Redis URL for production
# In production, this should point to a production Redis instance
# with proper authentication and security
REDIS_URL = os.environ.get('REDIS_URL_PROD')

# Celery broker URL for production
# In production, use a dedicated message broker with proper security
CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL_PROD')
# Uncomment to use Redis as message broker instead
# CELERY_BROKER_URL = os.environ.get('REDIS_BROKER_URL_PROD', f"{REDIS_URL}/0")

# Production optimizations for channel layers
# Override the channel layers configuration with production Redis URL and optimizations
CHANNEL_LAYERS['default']['CONFIG']['hosts'] = [f"{REDIS_URL}/0"]  # DB 0 for channels
CHANNEL_LAYERS['default']['CONFIG']['capacity'] = 1500  # Channel layer capacity
CHANNEL_LAYERS['default']['CONFIG']['expiry'] = 10  # Message expiry in seconds

# Production optimizations for Redis cache
# Override the Redis cache configuration with production Redis URL
CACHES['default']['LOCATION'] = f"{REDIS_URL}/1"  # DB 1 for caching

# Add production-specific cache optimizations
CACHES['default']['OPTIONS'].update({
    "SOCKET_CONNECT_TIMEOUT": 5,  # seconds
    "SOCKET_TIMEOUT": 5,  # seconds
    "CONNECTION_POOL_KWARGS": {"max_connections": 100},
    "COMPRESSOR": "django_redis.compressors.zlib.ZlibCompressor",
    "IGNORE_EXCEPTIONS": True,
})

# JWT token settings for production
# Use shorter token lifetimes for better security in production
from datetime import timedelta
SIMPLE_JWT = {
    # Production token lifetimes - shorter for better security
    # When the access token expires after 30 minutes, 
    # the app uses the refresh token to get a new access token
    # Because token rotation is enabled, the user also gets a new 
    # refresh token with a fresh 7-day expiration
    # This process repeats each time the access token expires
    # As long as the user uses the app at least once every 7 days, 
    # they'll keep getting new refresh tokens
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),    # 30 minutes in production
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),       # 7 days in production
    
    # Token rotation - when a refresh token is used, a new one is issued
    # This allows users to stay logged in as long as they're active
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    
    # Other JWT settings
    'UPDATE_LAST_LOGIN': False,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': os.environ.get('DJANGO_SECRET_KEY_PROD'),  # Uses the production SECRET_KEY
    'VERIFYING_KEY': None,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
}
