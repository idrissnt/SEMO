"""
Base WebSocket consumer for messaging.

This module provides a base WebSocket consumer with common functionality
for all messaging WebSocket consumers.
"""
import logging
from typing import Dict, Any

from channels.generic.websocket import AsyncJsonWebsocketConsumer
from django.contrib.auth import get_user_model

# Set up logging
logger = logging.getLogger(__name__)

User = get_user_model()


class BaseConsumer(AsyncJsonWebsocketConsumer):
    """
    Base WebSocket consumer with common functionality.
    
    This consumer provides common functionality for all messaging WebSocket
    consumers, including authentication, serialization, and database access.
    """
    
    async def connect(self):
        """
        Handle WebSocket connection.
        
        This method is called when a client connects to the WebSocket.
        It authenticates the user and performs basic connection setup.
        """
        # Get the user from the scope (set by authentication middleware)
        self.user = self.scope["user"]
        if not self.user.is_authenticated:
            # Reject the connection if the user is not authenticated
            await self.close(code=4001)
            return
        
        # Accept the connection by default, subclasses may override this behavior
        await self.accept()
    
    async def disconnect(self, close_code):
        """
        Handle WebSocket disconnection.
        
        This method is called when a client disconnects from the WebSocket.
        Subclasses should override this to handle specific disconnection logic.
        
        Args:
            close_code: WebSocket close code
        """
        pass
    
    async def receive_json(self, content):
        """
        Handle incoming WebSocket messages.
        
        This method is called when a client sends a message through the WebSocket.
        Subclasses should override this to handle specific message types.
        
        Args:
            content: JSON message content
        """
        # Get the message type
        message_type = content.get("type")
        
        # Handle unknown message type
        logger.warning(f"Unknown message type: {message_type}")
        await self.send_json({
            "type": "error",
            "data": {
                "message": f"Unknown message type: {message_type}"
            }
        })
    
    def serialize_message(self, message) -> Dict[str, Any]:
        """
        Serialize a message for sending over WebSocket.
        
        Args:
            message: Message object
            
        Returns:
            Serialized message dictionary
        """
        from ..serializers import MessageSerializer
        return MessageSerializer(message).data
