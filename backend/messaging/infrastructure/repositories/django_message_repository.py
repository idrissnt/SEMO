"""
Django implementation of the MessageRepository.

This module provides a Django ORM implementation of the MessageRepository interface.
"""
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid

from django.utils import timezone

from domain import (Message, MessageRepository)
from django_models import MessageModel


class DjangoMessageRepository(MessageRepository):
    """
    Django ORM implementation of the MessageRepository interface.
    
    This class implements the MessageRepository interface using Django's ORM
    to interact with the database.
    """
    
    def create(self, message: Message) -> Message:
        """
        Create a new message in the database.
        
        Args:
            message: The message to create
            
        Returns:
            The created message with any repository-generated fields updated
        """
        # Create new message
        message_model = MessageModel.objects.create(
            id=message.id,
            conversation_id=message.conversation_id,
            sender_id=message.sender_id,
            content=message.content,
            content_type=message.content_type,
            sent_at=message.sent_at,
            delivered_at=message.delivered_at,
            read_at=message.read_at,
            metadata=message.metadata
        )
        
        # Convert back to domain entity
        return self._to_domain_entity(message_model)
    
    def update(self, message: Message) -> Message:
        """
        Update an existing message in the database.
        
        Args:
            message: The message to update
            
        Returns:
            The updated message with any repository-generated fields updated
        """
        # Check if the message exists
        try:
            message_model = MessageModel.objects.get(id=message.id)
            # Update existing message
            message_model.content = message.content
            message_model.content_type = message.content_type
            message_model.delivered_at = message.delivered_at
            message_model.read_at = message.read_at
            message_model.metadata = message.metadata
            message_model.save()
            return self._to_domain_entity(message_model)
        except MessageModel.DoesNotExist:
            return None
    
    def get_by_id(self, message_id: uuid.UUID) -> Optional[Message]:
        """
        Get a message by its ID.
        
        Args:
            message_id: ID of the message to retrieve
            
        Returns:
            The message if found, None otherwise
        """
        try:
            message_model = MessageModel.objects.get(id=message_id)
            return self._to_domain_entity(message_model)
        except MessageModel.DoesNotExist:
            return None
    
    def get_by_conversation(
        self,
        conversation_id: uuid.UUID,
        limit: int = 50,
        before_id: Optional[uuid.UUID] = None
    ) -> List[Message]:
        """
        Get messages for a conversation with cursor-based pagination.
        
        This method retrieves messages for a specific conversation, ordered by sent_at
        in descending order (newest first). It supports cursor-based pagination
        using a message ID as the cursor.
        
        Args:
            conversation_id: ID of the conversation
            limit: Maximum number of messages to return
            before_id: If provided, only return messages sent before this message ID
            
        Returns:
            List of messages matching the criteria
        """
        query = MessageModel.objects.filter(conversation_id=conversation_id)
        
        if before_id:
            try:
                # Get the message to use as the cursor
                cursor_message = MessageModel.objects.get(id=before_id)
                # Filter messages sent before the cursor message (lt = less than)
                query = query.filter(sent_at__lt=cursor_message.sent_at)
            except MessageModel.DoesNotExist:
                pass
        
        # Order by sent_at descending and limit the results
        messages = query.order_by('-sent_at')[:limit]
        
        # Convert to domain entities
        return [self._to_domain_entity(m) for m in messages]
    
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
        if not message_ids:
            return 0
            
        if delivered_at is None:
            delivered_at = timezone.now()
            
        # Update the messages
        updated = MessageModel.objects.filter(
            id__in=message_ids,
            delivered_at__isnull=True  # Only update if not already delivered
        ).update(delivered_at=delivered_at)
        
        return updated
    
    def mark_as_read(
        self,
        message_ids: List[uuid.UUID],
        user_id: uuid.UUID,
        read_at: Optional[datetime] = None
    ) -> int:
        """
        Mark messages as read by a specific user.
        
        Args:
            message_ids: List of message IDs to mark as read
            user_id: ID of the user who read the messages
            read_at: Read timestamp (default: current time)
            
        Returns:
            Number of messages updated
        """
        if not message_ids:
            return 0
            
        if read_at is None:
            read_at = timezone.now()
            
        # Update the messages
        # Note: In a more complex system, we might track read status per user
        # rather than a single read_at timestamp
        updated = MessageModel.objects.filter(
            id__in=message_ids,
            read_at__isnull=True  # Only update if not already read
        ).update(read_at=read_at)
        
        return updated
    
    def delete(self, message_id: uuid.UUID) -> bool:
        """
        Delete a message.
        
        Args:
            message_id: ID of the message to delete
            
        Returns:
            True if the message was deleted, False otherwise
        """
        try:
            message = MessageModel.objects.get(id=message_id)
            message.delete()
            return True
        except MessageModel.DoesNotExist:
            return False
    
    def _to_domain_entity(self, model: MessageModel) -> Message:
        """
        Convert a Django model instance to a domain entity.
        
        Args:
            model: Django model instance
            
        Returns:
            Domain entity
        """
        return Message(
            id=model.id,
            conversation_id=model.conversation.id,
            sender_id=model.sender.id,
            content=model.content,
            content_type=model.content_type,
            sent_at=model.sent_at,
            delivered_at=model.delivered_at,
            read_at=model.read_at,
            metadata=model.metadata
        )
