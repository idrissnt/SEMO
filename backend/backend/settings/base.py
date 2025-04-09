"""
Base settings for Django project.

This module contains the base settings that are common to all environments.
Environment-specific settings should be defined in development.py, production.py, etc.
"""
import os
from pathlib import Path
from datetime import timedelta

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.0/howto/deployment/checklist/

# Application definition
# Import MessagingConfig for WebSocket configuration
from messaging.config import MessagingConfig

# Base INSTALLED_APPS before adding messaging-specific apps
BASE_INSTALLED_APPS = [
    'django.contrib.gis',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'drf_spectacular',
    'django_ltree',
    'imagekit',
    # 'channels' is added by MessagingConfig.get_installed_apps()
    
    # Celery apps
    'django_celery_results',
    'django_celery_beat',
    
    # Local apps
    'the_user_app',
    'store',
    'orders',
    'payments',
    'cart',
    'deliveries',
    'tasks',
    
]

# DEBUG setting should be overridden in environment-specific settings
# DEBUG = False  # Default to False for security

# Django Channels configuration for WebSockets
ASGI_APPLICATION = 'backend.asgi.application'

# Channel layers configuration - basic structure
# Environment-specific files will override with their own REDIS_URL
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": ["redis://localhost:6379/0"],  # Default for local development
            # Will be overridden in environment-specific settings
        },
    }
}

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'backend.wsgi.application'

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, 'static'),
]

# Media files (Uploaded files)
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom User Model
AUTH_USER_MODEL = 'the_user_app.CustomUserModel'  # This refers to the model imported in models.py

# REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'EXCEPTION_HANDLER': 'the_user_app.interfaces.api.exceptions.custom_exception_handler',
}

# API Documentation settings
SPECTACULAR_SETTINGS = {
    'TITLE': 'Your API',
    'DESCRIPTION': 'Your API description',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}

# Logging Configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR, 'debug.log'),
            'formatter': 'verbose',
        },
    },
    'loggers': {
        '': {
            'handlers': ['file'],
            'level': 'DEBUG',
            'propagate': True,
        },
    },
}

# Redis cache configuration (using database 1)
# Base structure - will be overridden with environment-specific REDIS_URL in dev/prod settings
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://localhost:6379/1",  # Default for local development, DB 1 for caching
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PARSER_CLASS": "redis.connection.HiredisParser",  # Faster parser
        },
        "KEY_PREFIX": "django_cache"  # Prefix for cache keys
    }
}

# Use Redis as the session backend for better performance
SESSION_ENGINE = "django.contrib.sessions.backends.cache"
SESSION_CACHE_ALIAS = "default"

# Celery Configuration - common settings
CELERY_RESULT_BACKEND = 'django-db'
CELERY_ACCEPT_CONTENT = ['application/json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = 'UTC'

# Celery Beat Schedule
CELERY_BEAT_SCHEDULE = {}

# Note: CELERY_BROKER_URL should be defined in environment-specific settings

# -------------------------------------------------------------------------
# Django Channels Configuration
# -------------------------------------------------------------------------

# Django Channels needs ASGI_APPLICATION setting
# This tells Django which ASGI application to use for handling WebSocket connections
ASGI_APPLICATION = 'backend.asgi.application'

# -------------------------------------------------------------------------
# Messaging Configuration
# -------------------------------------------------------------------------

# Add messaging-specific apps to INSTALLED_APPS
INSTALLED_APPS = BASE_INSTALLED_APPS.copy()

# Configure the messaging system using MessagingConfig
# This will add required apps and set WebSocket URL
settings_dict = locals()
MessagingConfig.configure_django_settings(settings_dict)

# WebSocket URL (base default for development)
# This will be overridden in environment-specific settings (development.py, production.py)
# Used by frontend clients to connect to the WebSocket server
WEBSOCKET_URL = 'ws://localhost:8000'