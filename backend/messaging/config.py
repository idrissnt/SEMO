"""
Configuration settings for the messaging system.

This module provides configuration settings and integration helpers
for the messaging system.
"""
import os
from .infrastructure.channel_layers import get_channel_layer_config, get_redis_config


class MessagingConfig:
    """
    Configuration class for the messaging system.
    
    This class provides methods to get configuration settings for the
    messaging system and to integrate it with a Django project.
    """
    
    @staticmethod
    def get_installed_apps():
        """
        Get the list of apps that should be added to INSTALLED_APPS.
        
        Returns:
            A list of app names to add to INSTALLED_APPS.
        """
        return [
            'channels',
            'messaging',
        ]
    
    @staticmethod
    def get_channel_layers(environment=None):
        """
        Get the channel layers configuration.
        
        Args:
            environment: The environment to get the configuration for.
        
        Returns:
            A dictionary with the channel layers configuration.
        """
        return get_channel_layer_config(environment)
    
    @staticmethod
    def get_caches(environment=None):
        """
        Get the cache configuration for Redis.
        
        Args:
            environment: The environment to get the configuration for.
        
        Returns:
            A dictionary with the cache configuration.
        """
        return get_redis_config(environment)
    
    @staticmethod
    def get_asgi_application():
        """
        Get the ASGI application for the messaging system.
        
        Returns:
            The path to the ASGI application.
        """
        return 'messaging.asgi.application'
    
    @staticmethod
    def get_websocket_url_patterns():
        """
        Get the WebSocket URL patterns for the messaging system.
        
        Returns:
            The WebSocket URL patterns.
        """
        from .infrastructure.websocket.routing import websocket_urlpatterns
        return websocket_urlpatterns
    
    @staticmethod
    def get_dependencies():
        """
        Get the list of dependencies required by the messaging system.
        
        Returns:
            A list of dependency strings in pip format.
        """
        return [
            'channels>=4.0.0',
            'channels-redis>=4.1.0',
            'django-redis>=5.2.0',
            'djangorestframework>=3.14.0',
            'PyJWT>=2.6.0',
        ]
    
    @staticmethod
    def configure_django_settings(settings_dict):
        """
        Configure Django settings for the messaging system.
        
        This method modifies the provided settings dictionary to include
        the necessary configuration for the messaging system.
        
        Args:
            settings_dict: The Django settings dictionary to modify.
        
        Returns:
            The modified settings dictionary.
        """
        environment = os.environ.get('DJANGO_ENV', 'development')
        
        # Add installed apps
        if 'INSTALLED_APPS' in settings_dict:
            for app in MessagingConfig.get_installed_apps():
                if app not in settings_dict['INSTALLED_APPS']:
                    settings_dict['INSTALLED_APPS'].append(app)
        
        # Configure ASGI application
        settings_dict['ASGI_APPLICATION'] = MessagingConfig.get_asgi_application()
        
        # Configure channel layers
        settings_dict['CHANNEL_LAYERS'] = MessagingConfig.get_channel_layers(environment)
        
        # Configure caches
        settings_dict['CACHES'] = MessagingConfig.get_caches(environment)
        
        # Configure WebSocket URL
        websocket_url = os.environ.get('WEBSOCKET_URL', 'ws://localhost:8000')
        settings_dict['WEBSOCKET_URL'] = websocket_url
        
        return settings_dict
