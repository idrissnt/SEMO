"""
WebSocket routing configuration.

This module defines the WebSocket URL patterns for the messaging system.
"""
from django.urls import re_path

from . import consumers

# WebSocket URL patterns
websocket_urlpatterns = [
    # Pattern for conversation WebSockets
    # Example: ws://example.com/ws/messaging/conversations/123e4567-e89b-12d3-a456-426614174000/
    re_path(
        r"ws/messaging/conversations/(?P<conversation_id>[0-9a-f-]+)/$",
        consumers.ChatConsumer.as_asgi()
    ),
]
