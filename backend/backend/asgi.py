"""
ASGI config for backend project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter

# Import the messaging app's WebSocket configuration
from messaging.config import MessagingConfig
from messaging.infrastructure.websocket.middleware.auth import JwtAuthMiddlewareStack

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

# Configure the ASGI application with both HTTP and WebSocket support
application = ProtocolTypeRouter({
    # HTTP handler
    'http': get_asgi_application(),
    
    # WebSocket handler
    'websocket': JwtAuthMiddlewareStack(
        URLRouter(
            MessagingConfig.get_websocket_url_patterns()
        )
    ),
})
