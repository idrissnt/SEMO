"""
Message service for handling message-related business logic.

This module contains the MessageService class, which implements the business logic
for creating, retrieving, and managing messages.
"""
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid

from ...domain.models import Message
from ...domain.repositories import MessageRepository, ConversationRepository


class MessageService:
    """
    Service for message-related business logic.
    
    This service encapsulates all business logic related to messages, including
    creating, retrieving, and managing messages. It uses the repositories to
    access and manipulate data, but contains the business rules itself.
    """
    
    def __init__(
        self,
        message_repository: MessageRepository,
        conversation_repository: ConversationRepository
    ):
        """
        Initialize the message service with required repositories.
        
        Args:
            message_repository: Repository for accessing messages
            conversation_repository: Repository for accessing conversations
        """
        self.message_repository = message_repository
        self.conversation_repository = conversation_repository
    
    def send_message(
        self,
        conversation_id: uuid.UUID,
        sender_id: uuid.UUID,
        content: str,
        content_type: str = "text",
        metadata: Optional[Dict[str, Any]] = None
    ) -> Message:
        """
        Send a new message in a conversation.
        
        This method creates a new message, saves it to the repository, and
        updates the conversation's last_message_at timestamp.
        
        Args:
            conversation_id: ID of the conversation
            sender_id: ID of the message sender
            content: Message content
            content_type: Type of content (default: "text")
            metadata: Additional message metadata
            
        Returns:
            The created message
            
        Raises:
            ValueError: If the conversation doesn't exist or the sender is not a participant
        """
        # Verify the conversation exists and the sender is a participant
        conversation = self.conversation_repository.get_by_id(conversation_id)
        if not conversation:
            raise ValueError(f"Conversation {conversation_id} not found")
        
        if sender_id not in conversation.participants:
            raise ValueError(f"User {sender_id} is not a participant in conversation {conversation_id}")
        
        # Create and save the message
        message = Message.create(
            conversation_id=conversation_id,
            sender_id=sender_id,
            content=content,
            content_type=content_type,
            metadata=metadata
        )
        saved_message = self.message_repository.create(message)
        
        # Update the conversation's last_message_at timestamp
        conversation.update_last_message_time(saved_message.sent_at)
        self.conversation_repository.update(conversation)
        
        return saved_message
    
    def get_message(self, message_id: uuid.UUID) -> Optional[Message]:
        """
        Get a message by its ID.
        
        Args:
            message_id: ID of the message to retrieve
            
        Returns:
            The message if found, None otherwise
        """
        return self.message_repository.get_by_id(message_id)
    
    def get_conversation_messages(
        self,
        conversation_id: uuid.UUID,
        limit: int = 50,
        before_message_id: Optional[uuid.UUID] = None
    ) -> Dict[str, Any]:
        """
        Get messages for a conversation with cursor-based pagination.
        
        This method retrieves messages for a specific conversation, ordered by sent_at
        in descending order (newest first). It supports cursor-based pagination
        using a message ID as the cursor.
        
        Args:
            conversation_id: ID of the conversation
            limit: Maximum number of messages to return
            before_message_id: If provided, only return messages sent before this message ID
            
        Returns:
            Dictionary containing:
            - messages: List of messages
            - next_cursor: ID of the oldest message returned, to use as before_message_id in the next call
            - has_more: Whether there are more messages to retrieve
        """
        messages = self.message_repository.get_by_conversation(
            conversation_id=conversation_id,
            limit=limit + 1,  # Request one extra to determine if there are more
            before_id=before_message_id
        )
        
        has_more = len(messages) > limit
        if has_more:
            messages = messages[:limit]  # Remove the extra message
        
        next_cursor = str(messages[-1].id) if messages and has_more else None
        
        return {
            "messages": messages,
            "next_cursor": next_cursor,
            "has_more": has_more
        }
    
    def mark_as_delivered(
        self,
        message_ids: List[uuid.UUID],
        delivered_at: Optional[datetime] = None
    ) -> int:
        """
        Mark messages as delivered.
        
        Args:
            message_ids: List of message IDs to mark as delivered
            delivered_at: Delivery timestamp (default: current time)
            
        Returns:
            Number of messages updated
        """
        return self.message_repository.mark_as_delivered(
            message_ids=message_ids,
            delivered_at=delivered_at
        )
    
    def mark_as_read(
        self,
        message_ids: List[uuid.UUID],
        user_id: uuid.UUID,
        read_at: Optional[datetime] = None
    ) -> int:
        """
        Mark messages as read by a specific user.
        
        This method will only mark messages as read if the user is a recipient
        (not the sender) and is a participant in the conversation.
        
        Args:
            message_ids: List of message IDs to mark as read
            user_id: ID of the user who read the messages
            read_at: Read timestamp (default: current time)
            
        Returns:
            Number of messages updated
        """
        # Verify the user is a participant in the conversations
        # and is not the sender of the messages
        valid_message_ids = []
        for message_id in message_ids:
            message = self.message_repository.get_by_id(message_id)
            if not message:
                continue
                
            conversation = self.conversation_repository.get_by_id(message.conversation_id)
            if not conversation or user_id not in conversation.participants:
                continue
                
            if message.sender_id != user_id:
                valid_message_ids.append(message_id)
        
        if not valid_message_ids:
            return 0
            
        return self.message_repository.mark_as_read(
            message_ids=valid_message_ids,
            user_id=user_id,
            read_at=read_at
        )
    
    def delete_message(self, message_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        """
        Delete a message.
        
        This method will only delete the message if the user is the sender.
        
        Args:
            message_id: ID of the message to delete
            user_id: ID of the user attempting to delete the message
            
        Returns:
            True if the message was deleted, False otherwise
            
        Raises:
            ValueError: If the user is not the sender of the message
        """
        message = self.message_repository.get_by_id(message_id)
        if not message:
            return False
            
        if message.sender_id != user_id:
            raise ValueError("Only the sender can delete a message")
            
        return self.message_repository.delete(message_id)
    
    # def get_unread_count(self, user_id: uuid.UUID, conversation_id: Optional[uuid.UUID] = None) -> int:
    #     """
    #     Get the count of unread messages for a user.
        
    #     Args:
    #         user_id: ID of the user
    #         conversation_id: If provided, only count unread messages in this conversation
            
    #     Returns:
    #         Number of unread messages
    #     """
    #     criteria = {
    #         "read_at": None,
    #         "sender_id__ne": user_id  # Not from the user
    #     }
        
    #     if conversation_id:
    #         criteria["conversation_id"] = conversation_id
    #     else:
    #         # Only count messages in conversations the user is part of
    #         conversations = self.conversation_repository.get_by_participant(user_id)
    #         conversation_ids = [conv.id for conv in conversations]
    #         if not conversation_ids:
    #             return 0
    #         criteria["conversation_id__in"] = conversation_ids
        
    #     messages = self.message_repository.find(criteria)
    #     return len(messages)
