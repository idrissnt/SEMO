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
    def get_websocket_url_patterns():
        """
        Get the WebSocket URL patterns for the messaging system.
        
        Returns:
            The WebSocket URL patterns.
        """
        from .infrastructure.websocket.routing import websocket_urlpatterns
        return websocket_urlpatterns
    
