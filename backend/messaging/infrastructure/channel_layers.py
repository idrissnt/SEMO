"""
Channel layer configurations for the messaging system.

This module provides channel layer configurations for different environments,
including development and production setups.
"""
import os


def get_channel_layer_config(environment=None):
    """
    Get the appropriate channel layer configuration based on the environment.
    
    Args:
        environment: The environment to get the configuration for.
                    If None, it will be determined from the DJANGO_ENV environment variable.
    
    Returns:
        A dictionary with the channel layer configuration.
    """
    if environment is None:
        environment = os.environ.get('DJANGO_ENV', 'development')
    
    if environment == 'production':
        # Production configuration using Redis
        return {
            "default": {
                "BACKEND": "channels_redis.core.RedisChannelLayer",
                "CONFIG": {
                    "hosts": [os.environ.get('REDIS_URL', 'redis://localhost:6379/0')],
                    "capacity": 1500,  # Default is 100
                    "expiry": 60,  # Default is 60
                    "group_expiry": 86400,  # 1 day in seconds
                },
            },
        }
    elif environment == 'test':
        # Test configuration using in-memory channel layer
        return {
            "default": {
                "BACKEND": "channels.layers.InMemoryChannelLayer",
            },
        }
    else:
        # Development configuration using Redis
        return {
            "default": {
                "BACKEND": "channels_redis.core.RedisChannelLayer",
                "CONFIG": {
                    "hosts": [os.environ.get('REDIS_URL', 'redis://localhost:6379/0')],
                },
            },
        }


def get_redis_config(environment=None):
    """
    Get the Redis configuration for caching and other uses.
    
    Args:
        environment: The environment to get the configuration for.
                    If None, it will be determined from the DJANGO_ENV environment variable.
    
    Returns:
        A dictionary with the Redis configuration.
    """
    if environment is None:
        environment = os.environ.get('DJANGO_ENV', 'development')
    
    if environment == 'production':
        # Production configuration
        return {
            "default": {
                "BACKEND": "django_redis.cache.RedisCache",
                "LOCATION": os.environ.get('REDIS_URL', 'redis://localhost:6379/1'),
                "OPTIONS": {
                    "CLIENT_CLASS": "django_redis.client.DefaultClient",
                    "SOCKET_CONNECT_TIMEOUT": 5,  # seconds
                    "SOCKET_TIMEOUT": 5,  # seconds
                    "CONNECTION_POOL_KWARGS": {"max_connections": 100},
                    "COMPRESSOR": "django_redis.compressors.zlib.ZlibCompressor",
                    "IGNORE_EXCEPTIONS": True,
                }
            }
        }
    elif environment == 'test':
        # Test configuration using dummy cache
        return {
            "default": {
                "BACKEND": "django.core.cache.backends.dummy.DummyCache",
            }
        }
    else:
        # Development configuration
        return {
            "default": {
                "BACKEND": "django_redis.cache.RedisCache",
                "LOCATION": os.environ.get('REDIS_URL', 'redis://localhost:6379/1'),
                "OPTIONS": {
                    "CLIENT_CLASS": "django_redis.client.DefaultClient",
                }
            }
        }
