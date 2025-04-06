"""
WebSocket consumers for real-time messaging.

This module contains the WebSocket consumers that handle real-time messaging
using Django Channels.
"""
import json
import uuid
import logging
from typing import Dict, Any, Optional

from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model

from ..factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)


class ChatConsumer(AsyncJsonWebsocketConsumer):
    """
    WebSocket consumer for real-time chat.
    
    This consumer handles WebSocket connections for real-time chat, including
    sending and receiving messages, read receipts, and typing indicators.
    """
    
    async def connect(self):
        """
        Handle WebSocket connection.
        
        This method is called when a client connects to the WebSocket.
        It authenticates the user, verifies they are a participant in the
        conversation, and adds them to the appropriate channel group.
        """
        # Get the user from the scope (set by authentication middleware)
        self.user = self.scope["user"]
        if not self.user.is_authenticated:
            # Reject the connection if the user is not authenticated
            await self.close(code=4001)
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
        
        # Add the user to the conversation group
        self.group_name = f"conversation_{self.conversation_id}"
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        
        # Accept the connection
        await self.accept()
        
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
        
        This method is called when a client sends a message through the WebSocket.
        It processes different types of messages (text messages, read receipts,
        typing indicators) and broadcasts them to other participants.
        
        Args:
            content: JSON message content
        """
        # Get the message type
        message_type = content.get("type")
        
        if message_type == "message":
            # Handle new message
            await self.handle_new_message(content)
        elif message_type == "read_receipt":
            # Handle read receipt
            await self.handle_read_receipt(content)
        elif message_type == "typing":
            # Handle typing indicator
            await self.handle_typing_indicator(content)
        elif message_type == "load_history":
            # Handle request to load message history
            await self.handle_load_history(content)
        else:
            # Handle unknown message type
            logger.warning(f"Unknown message type: {message_type}")
            await self.send_json({
                "type": "error",
                "data": {
                    "message": f"Unknown message type: {message_type}"
                }
            })
    
    async def handle_new_message(self, content):
        """
        Handle a new message from the client.
        
        This method processes a new message, saves it to the database,
        and broadcasts it to all participants in the conversation.
        
        Args:
            content: Message content from the client
        """
        # Extract message data
        message_content = content.get("content", "").strip()
        content_type = content.get("content_type", "text")
        metadata = content.get("metadata", {})
        
        # Validate message content
        if not message_content:
            await self.send_json({
                "type": "error",
                "data": {
                    "message": "Message content cannot be empty"
                }
            })
            return
        
        try:
            # Create the message
            message = await self.create_message(
                conversation_id=self.conversation_id,
                sender_id=self.user.id,
                content=message_content,
                content_type=content_type,
                metadata=metadata
            )
            
            # Broadcast the message to all participants
            await self.channel_layer.group_send(
                self.group_name,
                {
                    "type": "chat_message",
                    "message": self.serialize_message(message)
                }
            )
        except Exception as e:
            logger.exception("Error creating message")
            await self.send_json({
                "type": "error",
                "data": {
                    "message": f"Error creating message: {str(e)}"
                }
            })
    
    async def handle_read_receipt(self, content):
        """
        Handle a read receipt from the client.
        
        This method processes a read receipt, updates the database,
        and broadcasts it to all participants in the conversation.
        
        Args:
            content: Read receipt content from the client
        """
        # Extract message IDs
        message_ids = content.get("message_ids", [])
        
        if not message_ids:
            return
        
        try:
            # Convert string IDs to UUID objects
            uuid_message_ids = [uuid.UUID(mid) for mid in message_ids]
            
            # Mark messages as read
            updated = await self.mark_messages_read(
                message_ids=uuid_message_ids,
                user_id=self.user.id
            )
            
            # Update the user's last read timestamp
            await self.update_last_read()
            
            # Broadcast the read receipt to all participants
            await self.channel_layer.group_send(
                self.group_name,
                {
                    "type": "read_receipt",
                    "user_id": str(self.user.id),
                    "message_ids": message_ids
                }
            )
        except Exception as e:
            logger.exception("Error processing read receipt")
            await self.send_json({
                "type": "error",
                "data": {
                    "message": f"Error processing read receipt: {str(e)}"
                }
            })
    
    async def handle_typing_indicator(self, content):
        """
        Handle a typing indicator from the client.
        
        This method processes a typing indicator and broadcasts it to all
        participants in the conversation.
        
        Args:
            content: Typing indicator content from the client
        """
        # Extract typing status
        is_typing = content.get("is_typing", False)
        
        # Broadcast the typing indicator to all participants
        await self.channel_layer.group_send(
            self.group_name,
            {
                "type": "typing_indicator",
                "user_id": str(self.user.id),
                "is_typing": is_typing
            }
        )
    
    async def handle_load_history(self, content):
        """
        Handle a request to load message history.
        
        This method retrieves message history for the conversation and sends
        it to the client.
        
        Args:
            content: Load history request content from the client
        """
        # Extract pagination parameters
        limit = min(int(content.get("limit", 50)), 100)  # Cap at 100 messages
        before_id = content.get("before_id")
        
        try:
            # Convert before_id to UUID if provided
            before_uuid = uuid.UUID(before_id) if before_id else None
            
            # Get message history
            history = await self.get_message_history(
                conversation_id=self.conversation_id,
                limit=limit,
                before_id=before_uuid
            )
            
            # Send the history to the client
            await self.send_json({
                "type": "message_history",
                "data": history
            })
        except Exception as e:
            logger.exception("Error loading message history")
            await self.send_json({
                "type": "error",
                "data": {
                    "message": f"Error loading message history: {str(e)}"
                }
            })
    
    async def chat_message(self, event):
        """
        Handle chat message events from the channel layer.
        
        This method is called when a message is broadcast to the conversation group.
        It sends the message to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the message to the client
        await self.send_json({
            "type": "message",
            "data": event["message"]
        })
    
    async def read_receipt(self, event):
        """
        Handle read receipt events from the channel layer.
        
        This method is called when a read receipt is broadcast to the conversation group.
        It sends the read receipt to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the read receipt to the client
        await self.send_json({
            "type": "read_receipt",
            "data": {
                "user_id": event["user_id"],
                "message_ids": event["message_ids"]
            }
        })
    
    async def typing_indicator(self, event):
        """
        Handle typing indicator events from the channel layer.
        
        This method is called when a typing indicator is broadcast to the conversation group.
        It sends the typing indicator to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the typing indicator to the client
        await self.send_json({
            "type": "typing_indicator",
            "data": {
                "user_id": event["user_id"],
                "is_typing": event["is_typing"]
            }
        })
    
    async def user_online(self, event):
        """
        Handle user online events from the channel layer.
        
        This method is called when a user connects to the conversation.
        It sends a notification to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the user online notification to the client
        await self.send_json({
            "type": "user_online",
            "data": {
                "user_id": event["user_id"]
            }
        })
    
    async def user_offline(self, event):
        """
        Handle user offline events from the channel layer.
        
        This method is called when a user disconnects from the conversation.
        It sends a notification to the client.
        
        Args:
            event: Channel layer event
        """
        # Send the user offline notification to the client
        await self.send_json({
            "type": "user_offline",
            "data": {
                "user_id": event["user_id"]
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
        return {
            "id": str(message.id),
            "conversation_id": str(message.conversation_id),
            "sender_id": str(message.sender_id),
            "content": message.content,
            "content_type": message.content_type,
            "sent_at": message.sent_at.isoformat(),
            "delivered_at": message.delivered_at.isoformat() if message.delivered_at else None,
            "read_at": message.read_at.isoformat() if message.read_at else None,
            "metadata": message.metadata
        }
    
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
    
    @database_sync_to_async
    def create_message(self, conversation_id: uuid.UUID, sender_id: int, 
                      content: str, content_type: str = "text",
                      metadata: Optional[Dict[str, Any]] = None) -> Any:
        """
        Create a new message.
        
        Args:
            conversation_id: ID of the conversation
            sender_id: ID of the sender
            content: Message content
            content_type: Type of content
            metadata: Additional message metadata
            
        Returns:
            The created message
        """
        message_service = ServiceFactory.get_message_service()
        return message_service.send_message(
            conversation_id=conversation_id,
            sender_id=uuid.UUID(str(sender_id)),
            content=content,
            content_type=content_type,
            metadata=metadata
        )
    
    @database_sync_to_async
    def mark_messages_read(self, message_ids: list, user_id: int) -> int:
        """
        Mark messages as read.
        
        Args:
            message_ids: List of message IDs
            user_id: ID of the user who read the messages
            
        Returns:
            Number of messages updated
        """
        message_service = ServiceFactory.get_message_service()
        return message_service.mark_as_read(
            message_ids=message_ids,
            user_id=uuid.UUID(str(user_id))
        )
    
    @database_sync_to_async
    def update_last_read(self) -> None:
        """
        Update the user's last read timestamp for the conversation.
        
        This method updates the ConversationParticipantModel to track when
        the user last read the conversation.
        """
        from ..django_models import ConversationParticipantModel
        from django.utils import timezone
        
        # Update the last_read_at timestamp
        ConversationParticipantModel.objects.filter(
            conversation_id=self.conversation_id,
            user_id=self.user.id
        ).update(last_read_at=timezone.now())
    
    @database_sync_to_async
    def get_message_history(self, conversation_id: uuid.UUID, 
                           limit: int = 50,
                           before_id: Optional[uuid.UUID] = None) -> Dict[str, Any]:
        """
        Get message history for a conversation.
        
        Args:
            conversation_id: ID of the conversation
            limit: Maximum number of messages to return
            before_id: If provided, only return messages sent before this message ID
            
        Returns:
            Dictionary containing messages and pagination info
        """
        message_service = ServiceFactory.get_message_service()
        result = message_service.get_conversation_messages(
            conversation_id=conversation_id,
            limit=limit,
            before_message_id=before_id
        )
        
        # Serialize the messages
        serialized_messages = [self.serialize_message(m) for m in result["messages"]]
        
        return {
            "messages": serialized_messages,
            "next_cursor": result["next_cursor"],
            "has_more": result["has_more"]
        }
