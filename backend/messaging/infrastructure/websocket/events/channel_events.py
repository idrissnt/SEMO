"""
Channel events for WebSocket communication.

This module contains handlers for channel layer events that are broadcast
to WebSocket consumers.
"""
import logging
from typing import Dict, Any, Protocol

# Set up logging
logger = logging.getLogger(__name__)


class ChannelEventConsumer(Protocol):
    """Protocol defining the interface for a consumer that handles channel events."""
    
    async def send_json(self, content: Dict[str, Any]) -> None:
        """Send JSON content to the client."""
        ...


class ChannelEventHandler:
    """
    Base class for handling channel layer events.
    
    This class provides a common interface for handling events that are
    broadcast through the channel layer.
    """
    
    def __init__(self, consumer: ChannelEventConsumer):
        """
        Initialize the handler with a reference to the consumer.
        
        Args:
            consumer: The WebSocket consumer that owns this handler
        """
        self.consumer = consumer
    
    async def dispatch(self, event_type: str, event: Dict[str, Any]) -> None:
        """
        Dispatch an event to the appropriate handler method.
        
        Args:
            event_type: Type of the event
            event: Event data
        """
        handler = getattr(self, f"handle_{event_type}", None)
        if handler:
            await handler(event)
        else:
            logger.warning(f"No handler for event type: {event_type}")


class ChatEventHandler(ChannelEventHandler):
    """
    Handler for chat-related channel layer events.
    
    This handler processes events related to chat messages, read receipts,
    typing indicators, and user presence.
    """
    
    async def handle_chat_message(self, event: Dict[str, Any]) -> None:
        """
        Handle chat message events from the channel layer.
        
        This method is called when a message is broadcast to the conversation group.
        It sends the message to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the message to the client
        await self.consumer.send_json({
            "type": "message",
            "data": event["message"]
        })
    
    async def handle_read_receipt(self, event: Dict[str, Any]) -> None:
        """
        Handle read receipt events from the channel layer.
        
        This method is called when a read receipt is broadcast to the conversation group.
        It sends the read receipt to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the read receipt to the client
        await self.consumer.send_json({
            "type": "read_receipt",
            "data": {
                "user_id": event["user_id"],
                "message_ids": event["message_ids"]
            }
        })
    
    async def handle_typing_indicator(self, event: Dict[str, Any]) -> None:
        """
        Handle typing indicator events from the channel layer.
        
        This method is called when a typing indicator is broadcast to the conversation group.
        It sends the typing indicator to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the typing indicator to the client
        await self.consumer.send_json({
            "type": "typing_indicator",
            "data": {
                "user_id": event["user_id"],
                "is_typing": event["is_typing"]
            }
        })
    
    async def handle_user_online(self, event: Dict[str, Any]) -> None:
        """
        Handle user online events from the channel layer.
        
        This method is called when a user connects to the conversation.
        It sends a notification to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the user online notification to the client
        await self.consumer.send_json({
            "type": "user_online",
            "data": {
                "user_id": event["user_id"]
            }
        })
    
    async def handle_user_offline(self, event: Dict[str, Any]) -> None:
        """
        Handle user offline events from the channel layer.
        
        This method is called when a user disconnects from the conversation.
        It sends a notification to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the user offline notification to the client
        await self.consumer.send_json({
            "type": "user_offline",
            "data": {
                "user_id": event["user_id"]
            }
        })
    
    async def handle_message_updated(self, event: Dict[str, Any]) -> None:
        """
        Handle message updated events from the channel layer.
        
        This method is called when a message is updated.
        It sends the updated message to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the updated message to the client
        await self.consumer.send_json({
            "type": "message_updated",
            "data": event["message"]
        })
    
    async def handle_message_deleted(self, event: Dict[str, Any]) -> None:
        """
        Handle message deleted events from the channel layer.
        
        This method is called when a message is deleted.
        It sends a notification to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the message deletion notification to the client
        await self.consumer.send_json({
            "type": "message_deleted",
            "data": {
                "message_id": event["message_id"]
            }
        })
    
    async def handle_conversation_updated(self, event: Dict[str, Any]) -> None:
        """
        Handle conversation updated events from the channel layer.
        
        This method is called when a conversation is updated.
        It sends the updated conversation to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the updated conversation to the client
        await self.consumer.send_json({
            "type": "conversation_updated",
            "data": event["conversation"]
        })
