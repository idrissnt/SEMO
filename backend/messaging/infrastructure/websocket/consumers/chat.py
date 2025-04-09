"""
Chat WebSocket consumer for real-time messaging.

This module contains the WebSocket consumer that handles real-time chat messaging
using Django Channels.
"""
import uuid
import logging

from channels.db import database_sync_to_async

from .base import BaseConsumer
from ..handlers import MessageHandler, ReadReceiptHandler, TypingHandler, HistoryHandler
from ..events import ChatEventHandler
from ....infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)


class ChatConsumer(BaseConsumer):
    """
    WebSocket consumer for real-time chat.
    
    This consumer handles WebSocket connections for real-time chat, including
    sending and receiving messages, read receipts, and typing indicators.
    """
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Initialize handlers when the consumer is created
        self.event_handler = None  # Will be initialized after connection
        # Message handlers will be initialized on demand
    
    async def connect(self):
        """
        Handle WebSocket connection.
        
        This method is called when a client connects to the WebSocket.
        It authenticates the user, verifies they are a participant in the
        conversation, and adds them to the appropriate channel group.
        """
        # Call the base connect method for authentication
        await super().connect()
        
        # If the user is not authenticated, the connection has already been closed
        if not self.user.is_authenticated:
            return
        
        # Get the conversation ID from the URL route
        self.conversation_id = self.scope["url_route"]["kwargs"]["conversation_id"]
        try:
            self.conversation_id = uuid.UUID(self.conversation_id)
        except ValueError:
            # Reject the connection if the conversation ID is invalid
            await self.close(code=4002)
            return
        
        # Verify the user is a participant in the conversation
        is_participant = await self.verify_participant(self.user.id, self.conversation_id)
        if not is_participant:
            # Reject the connection if the user is not a participant
            await self.close(code=4003)
            return
        
        # Add the user to the conversation channel group.
        self.group_name = f"conversation_{self.conversation_id}"
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        
        # Initialize the event handler
        self.event_handler = ChatEventHandler(self)
        
        # Send a welcome message
        await self.send_json({
            "type": "connection_established",
            "data": {
                "conversation_id": str(self.conversation_id),
                "user_id": str(self.user.id)
            }
        })
        
        # Notify other participants that this user is online
        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "user_online",
                "user_id": str(self.user.id)
            }
        )
        
        # Mark the user as having read up to this point
        await self.update_last_read()
    
    async def disconnect(self, close_code):
        """
        Handle WebSocket disconnection.
        
        This method is called when a client disconnects from the WebSocket.
        It removes the user from the conversation group and notifies other
        participants that the user is offline.
        
        Args:
            close_code: WebSocket close code
        """
        # Skip if the connection was never fully established
        if not hasattr(self, "group_name"):
            return
        
        # Notify other participants that this user is offline
        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "user_offline",
                "user_id": str(self.user.id)
            }
        )
        
        # Remove the user from the conversation group
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )
    
    async def receive_json(self, content):
        """
        Handle incoming WebSocket messages.
        
        This method is called automatically when a client sends a message through the WebSocket.
        It processes different types of messages using the appropriate handlers.
        
        Args:
            content: JSON message content
        """
        # Get the message type
        message_type = content.get("type")
        
        # Use the appropriate handler based on message type
        if message_type == "message":
            handler = MessageHandler(self)
            await handler.handle(content)
        elif message_type == "read_receipt":
            handler = ReadReceiptHandler(self)
            await handler.handle(content)
        elif message_type == "typing":
            handler = TypingHandler(self)
            await handler.handle(content)
        elif message_type == "load_history":
            handler = HistoryHandler(self)
            await handler.handle(content)
        else:
            # Handle unknown message type using the base implementation
            await super().receive_json(content)
    
    # Channel layer event handlers - delegate to the event handler
    
    async def chat_message(self, event):
        # Called automatically when a "chat_message" event is received from Redis
        await self.event_handler.dispatch("chat_message", event)
    
    async def read_receipt(self, event):
        await self.event_handler.dispatch("read_receipt", event)
    
    async def typing_indicator(self, event):
        await self.event_handler.dispatch("typing_indicator", event)
    
    async def user_online(self, event):
        await self.event_handler.dispatch("user_online", event)
    
    async def user_offline(self, event):
        await self.event_handler.dispatch("user_offline", event)
    
    async def message_updated(self, event):
        await self.event_handler.dispatch("message_updated", event)
    
    async def message_deleted(self, event):
        await self.event_handler.dispatch("message_deleted", event)
    
    async def conversation_updated(self, event):
        await self.event_handler.dispatch("conversation_updated", event)
    
    # Database access methods
    # These methods use database_sync_to_async to avoid blocking the event loop
    
    @database_sync_to_async
    def verify_participant(self, user_id: int, conversation_id: uuid.UUID) -> bool:
        """
        Verify that a user is a participant in a conversation.
        
        Args:
            user_id: ID of the user
            conversation_id: ID of the conversation
            
        Returns:
            True if the user is a participant, False otherwise
        """
        conversation_service = ServiceFactory.get_conversation_service()
        conversation = conversation_service.get_conversation(conversation_id)
        
        if not conversation:
            return False
        
        return uuid.UUID(str(user_id)) in conversation.participants
