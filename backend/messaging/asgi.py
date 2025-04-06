"""
ASGI configuration for the messaging app.

This module defines the ASGI application for the messaging app, which
integrates with Django Channels for WebSocket support.
"""
from django.urls import path

from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack

from .infrastructure.websocket.routing import websocket_urlpatterns
from .infrastructure.websocket.auth import JWTAuthMiddleware


# Define the ASGI application for the messaging app
application = ProtocolTypeRouter({
    # WebSocket handler
    'websocket': JWTAuthMiddleware(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})
