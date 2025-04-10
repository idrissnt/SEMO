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
from django.conf import settings
from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async

# Import from the_user_app for token blacklist checking and validation
from the_user_app.infrastructure.factory import UserFactory

from rest_framework_simplejwt.tokens import UntypedToken
from rest_framework_simplejwt.exceptions import TokenError

# Set up logging
logger = logging.getLogger(__name__)

# We'll lazy-load the User model and AnonymousUser to avoid issues with Django initialization


class JwtAuthMiddleware(BaseMiddleware):
    """
    JWT authentication middleware for WebSocket connections.
    
    This middleware authenticates WebSocket connections using JWT tokens
    provided in the query string or headers.
    """
    
    @property
    def User(self):
        """Lazy-load the User model to ensure Django is initialized."""
        return get_user_model()
        
    @property
    def AnonymousUser(self):
        """Lazy-load the AnonymousUser class to ensure Django is initialized."""
        from django.contrib.auth.models import AnonymousUser
        return AnonymousUser
    
    async def __call__(self, scope, receive, send):
        """
        Process the WebSocket connection.
        
        This method extracts the JWT token from the query string or headers, validates it, and adds
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
        scope["user"] = self.AnonymousUser()
        
        # If token found, authenticate
        if token:
            # Check if token is blacklisted
            is_blacklisted = await self.check_token_blacklisted(token)
            if is_blacklisted:
                logger.warning("Blacklisted JWT token")
            else:
                try:
                    # Use Simple JWT's UntypedToken for validation
                    # This ensures we use the same validation mechanism as the_user_app
                    token_obj = UntypedToken(token)
                    payload = token_obj.payload
                    
                    # Get the user ID from the payload
                    user_id = payload.get("user_id")
                    if user_id:
                        # Get the user from the database
                        user = await self.get_user(user_id)
                        if user:
                            # Add the user to the scope
                            scope["user"] = user
                            # Store token in scope for potential future validation
                            scope["auth_token"] = token
                except ExpiredSignatureError:
                    logger.warning("Expired JWT token")
                except InvalidTokenError:
                    logger.warning("Invalid JWT token")
                except TokenError:
                    logger.warning("Invalid token format")
        
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
            return self.User.objects.get(id=user_id)
        except self.User.DoesNotExist:
            return None
    
    @database_sync_to_async
    def check_token_blacklisted(self, token):
        """
        Check if a token is blacklisted using the_user_app's auth repository.
        
        Args:
            token: JWT token to check
            
        Returns:
            True if token is blacklisted, False otherwise
        """
        try:
            # Get auth repository from the_user_app
            auth_repository = UserFactory.create_auth_repository()
            return auth_repository.is_token_blacklisted(token)
        except Exception as e:
            logger.error(f"Error checking token blacklist: {str(e)}")
            # If there's an error checking the blacklist, assume the token is invalid
            return True


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
