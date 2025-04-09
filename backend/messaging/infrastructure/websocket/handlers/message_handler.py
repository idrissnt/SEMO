"""
Message handler for WebSocket chat messages.

This module provides handlers for processing chat-related WebSocket messages
such as new messages, read receipts, and typing indicators.
"""
import logging
import uuid
from typing import Dict, Any, List

from channels.db import database_sync_to_async

from .base import BaseHandler
from ....infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)


class MessageHandler(BaseHandler):
    """
    Handler for chat message operations.
    
    This handler processes new messages sent by clients and broadcasts
    them to all participants in the conversation.
    """
    
    async def handle(self, content: Dict[str, Any]) -> None:
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
            await self.consumer.send_json({
                "type": "error",
                "data": {
                    "message": "Message content cannot be empty"
                }
            })
            return
        
        try:
            # Create the message
            message = await self.create_message(
                conversation_id=self.consumer.conversation_id,
                sender_id=self.user.id,
                content=message_content,
                content_type=content_type,
                metadata=metadata
            )
            
            # Broadcast the message to all participants
            await self.consumer.channel_layer.group_send(
                self.consumer.group_name,
                {
                    "type": "chat_message",
                    "message": self.consumer.serialize_message(message)
                }
            )
        except Exception as e:
            logger.exception("Error creating message")
            await self.consumer.send_json({
                "type": "error",
                "data": {
                    "message": f"Error creating message: {str(e)}"
                }
            })
    
    @database_sync_to_async
    def create_message(self, conversation_id: uuid.UUID, sender_id: int, 
                      content: str, content_type: str = "text",
                      metadata: Dict[str, Any] = None) -> Any:
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


class ReadReceiptHandler(BaseHandler):
    """
    Handler for read receipt operations.
    
    This handler processes read receipts sent by clients and broadcasts
    them to all participants in the conversation.
    """
    
    async def handle(self, content: Dict[str, Any]) -> None:
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
            await self.consumer.channel_layer.group_send(
                self.consumer.group_name,
                {
                    "type": "read_receipt",
                    "user_id": str(self.user.id),
                    "message_ids": message_ids
                }
            )
        except Exception as e:
            logger.exception("Error processing read receipt")
            await self.consumer.send_json({
                "type": "error",
                "data": {
                    "message": f"Error processing read receipt: {str(e)}"
                }
            })
    
    @database_sync_to_async
    def mark_messages_read(self, message_ids: List[uuid.UUID], user_id: int) -> int:
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
        """
        conversation_service = ServiceFactory.get_conversation_service()
        conversation_service.update_last_read(
            conversation_id=self.consumer.conversation_id,
            user_id=uuid.UUID(str(self.user.id))
        )


class TypingHandler(BaseHandler):
    """
    Handler for typing indicator operations.
    
    This handler processes typing indicators sent by clients and broadcasts
    them to all participants in the conversation.
    """
    
    async def handle(self, content: Dict[str, Any]) -> None:
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
        await self.consumer.channel_layer.group_send(
            self.consumer.group_name,
            {
                "type": "typing_indicator",
                "user_id": str(self.user.id),
                "is_typing": is_typing
            }
        )
