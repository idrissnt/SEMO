"""
History handler for WebSocket message history.

This module provides a handler for retrieving message history
for conversations.
"""
import logging
import uuid
from typing import Dict, Any, List, Optional

from channels.db import database_sync_to_async

from .base import BaseHandler
from ....infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)


class HistoryHandler(BaseHandler):
    """
    Handler for message history operations.
    
    This handler processes requests to load message history and sends
    the history to the client.
    """
    
    async def handle(self, content: Dict[str, Any]) -> None:
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
                conversation_id=self.consumer.conversation_id,
                limit=limit,
                before_id=before_uuid
            )
            
            # Send the history to the client
            await self.consumer.send_json({
                "type": "message_history",
                "data": history
            })
        except Exception as e:
            logger.exception("Error loading message history")
            await self.consumer.send_json({
                "type": "error",
                "data": {
                    "message": f"Error loading message history: {str(e)}"
                }
            })
    
    @database_sync_to_async
    def get_message_history(self, conversation_id: uuid.UUID, limit: int = 50, 
                           before_id: Optional[uuid.UUID] = None) -> List[Dict[str, Any]]:
        """
        Get message history for a conversation.
        
        Args:
            conversation_id: ID of the conversation
            limit: Maximum number of messages to return
            before_id: Only return messages before this ID
            
        Returns:
            List of serialized messages
        """
        message_service = ServiceFactory.get_message_service()
        messages = message_service.get_conversation_messages(
            conversation_id=conversation_id,
            limit=limit,
            before_id=before_id
        )
        
        return [self.consumer.serialize_message(msg) for msg in messages]
