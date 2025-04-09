"""
Configuration settings for the messaging system.

This module provides configuration settings and integration helpers
for the messaging system.
"""
import os

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
    def get_asgi_application():
        """
        Get the ASGI application for the messaging system.
        
        Returns:
            The path to the ASGI application.
        """
        return 'backend.asgi.application'
    
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
        
        # Add installed apps
        if 'INSTALLED_APPS' in settings_dict:
            for app in MessagingConfig.get_installed_apps():
                if app not in settings_dict['INSTALLED_APPS']:
                    settings_dict['INSTALLED_APPS'].append(app)
        
        # Configure ASGI application
        settings_dict['ASGI_APPLICATION'] = MessagingConfig.get_asgi_application()
        
        # Configure WebSocket URL
        websocket_url = os.environ.get('WEBSOCKET_URL', 'ws://localhost:8000')
        settings_dict['WEBSOCKET_URL'] = websocket_url
        
        return settings_dict
