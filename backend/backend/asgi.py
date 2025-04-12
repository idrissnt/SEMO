import os
import django
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings.dev')
django.setup()

# Create the basic Django ASGI app
django_asgi_app = get_asgi_application()

# Defer websocket routing setup
def application(scope):
    if scope["type"] == "http":
        return django_asgi_app

    elif scope["type"] == "websocket":
        # Lazy imports here!
        from channels.routing import URLRouter
        from messaging.config import MessagingConfig
        from messaging.infrastructure.websocket.middleware.auth import JwtAuthMiddlewareStack

        return JwtAuthMiddlewareStack(
            URLRouter(MessagingConfig.get_websocket_url_patterns())
        )

    else:
        raise ValueError(f"Unsupported scope type: {scope['type']}")
