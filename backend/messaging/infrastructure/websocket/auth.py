"""
WebSocket authentication middleware.

This module provides middleware for authenticating WebSocket connections
using JWT tokens or session cookies.
"""
import logging
from urllib.parse import parse_qs
import jwt
from jwt.exceptions import InvalidTokenError, ExpiredSignatureError

from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from django.conf import settings
from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async

# Set up logging
logger = logging.getLogger(__name__)

User = get_user_model()


class JwtAuthMiddleware(BaseMiddleware):
    """
    JWT authentication middleware for WebSocket connections.
    
    This middleware authenticates WebSocket connections using JWT tokens
    provided in the query string or headers.
    """
    
    def __init__(self, inner):
        """
        Initialize the middleware.
        
        Args:
            inner: ASGI application to wrap
        """
        super().__init__(inner)
    
    async def __call__(self, scope, receive, send):
        """
        Process an ASGI connection.
        
        This method is called for each WebSocket connection. It extracts the
        JWT token from the query string or headers, validates it, and adds
        the authenticated user to the scope.
        
        Args:
            scope: ASGI connection scope
            receive: ASGI receive function
            send: ASGI send function
        """
        # Get the token from the query string
        query_string = scope.get("query_string", b"").decode()
        query_params = parse_qs(query_string)
        token = query_params.get("token", [None])[0]
        
        # If token not in query string, check headers
        if not token and "headers" in scope:
            headers = dict(scope["headers"])
            auth_header = headers.get(b"authorization", b"").decode()
            if auth_header.startswith("Bearer "):
                token = auth_header.split(" ")[1]
        
        # Default to anonymous user
        scope["user"] = AnonymousUser()
        
        # If token found, authenticate
        if token:
            try:
                # Decode the token
                payload = jwt.decode(
                    token,
                    settings.SECRET_KEY,
                    algorithms=["HS256"]
                )
                
                # Get the user ID from the payload
                user_id = payload.get("user_id")
                if user_id:
                    # Get the user from the database
                    user = await self.get_user(user_id)
                    if user:
                        # Add the user to the scope
                        scope["user"] = user
            except ExpiredSignatureError:
                logger.warning("Expired JWT token")
            except InvalidTokenError:
                logger.warning("Invalid JWT token")
        
        # Continue processing the connection
        return await super().__call__(scope, receive, send)
    
    @database_sync_to_async
    def get_user(self, user_id):
        """
        Get a user by ID.
        
        Args:
            user_id: ID of the user
            
        Returns:
            User object if found, None otherwise
        """
        try:
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            return None


# Convenience function for adding the middleware to the ASGI application
def JwtAuthMiddlewareStack(inner):
    """
    Add JWT authentication to a ASGI application.
    
    Args:
        inner: ASGI application
        
    Returns:
        ASGI application with JWT authentication
    """
    return JwtAuthMiddleware(inner)
