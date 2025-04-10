"""
Base handler for WebSocket message handling.

This module provides a base handler for processing WebSocket messages
with common functionality for all message types.
"""
import logging
from typing import Dict, Any, Optional

from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model

from ....infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)

# We'll lazy-load the User model to avoid issues with Django initialization


class BaseHandler:
    """
    Base handler for WebSocket message processing.
    
    This class provides common functionality for processing different types
    of WebSocket messages.
    """
    
    @property
    def User(self):
        """Lazy-load the User model to ensure Django is initialized."""
        return get_user_model()
    
    def __init__(self, consumer):
        """
        Initialize the handler with a reference to the consumer.
        
        Args:
            consumer: The WebSocket consumer that owns this handler
        """
        self.consumer = consumer
        self.user = consumer.user
        
    async def handle(self, content: Dict[str, Any]) -> None:
        """
        Handle a WebSocket message.
        
        This method should be overridden by subclasses to handle specific
        message types.
        
        Args:
            content: Message content from the client
        """
        raise NotImplementedError("Subclasses must implement handle()")
