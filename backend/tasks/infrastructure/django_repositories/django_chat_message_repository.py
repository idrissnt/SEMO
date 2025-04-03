"""
Django implementation of the ChatMessageRepository interface.
"""
from typing import List, Optional
import uuid
from datetime import datetime

from ...domain.repositories.application.chat_message_repository import ChatMessageRepository
from ...domain.models.entities.chat_message import ChatMessage
from ..django_models.application.chat_message import ChatMessageModel


class DjangoChatMessageRepository(ChatMessageRepository):
    """Django ORM implementation of the ChatMessageRepository interface"""
    
    def get_by_id(self, message_id: uuid.UUID) -> Optional[ChatMessage]:
        """Get message by ID
        
        Args:
            message_id: UUID of the message
            
        Returns:
            ChatMessage object if found, None otherwise
        """
        try:
            message_model = ChatMessageModel.objects.get(id=message_id)
            return self._to_entity(message_model)
        except ChatMessageModel.DoesNotExist:
            return None
    
    def get_by_application_id(self, application_id: uuid.UUID) -> List[ChatMessage]:
        """Get all messages for a task application
        
        Args:
            application_id: UUID of the task application
            
        Returns:
            List of ChatMessage objects
        """
        message_models = ChatMessageModel.objects.filter(application_id=application_id).order_by('created_at')
        return [self._to_entity(message_model) for message_model in message_models]
    
    def get_by_sender_id(self, sender_id: uuid.UUID) -> List[ChatMessage]:
        """Get all messages sent by a user
        
        Args:
            sender_id: UUID of the sender
            
        Returns:
            List of ChatMessage objects
        """
        message_models = ChatMessageModel.objects.filter(sender_id=sender_id).order_by('-created_at')
        return [self._to_entity(message_model) for message_model in message_models]
    
    def create(self, application_id: uuid.UUID, sender_id: uuid.UUID, content: str) -> ChatMessage:
        """Create a new chat message
        
        Args:
            application_id: UUID of the task application
            sender_id: UUID of the sender
            content: Message content
            
        Returns:
            Created ChatMessage object
        """
        message_model = ChatMessageModel.objects.create(
            application_id=application_id,
            sender_id=sender_id,
            content=content
        )
        return self._to_entity(message_model)
    
    def delete(self, message_id: uuid.UUID) -> bool:
        """Delete a chat message
        
        Args:
            message_id: UUID of the message to delete
            
        Returns:
            True if deleted, False otherwise
        """
        try:
            message_model = ChatMessageModel.objects.get(id=message_id)
            message_model.delete()
            return True
        except ChatMessageModel.DoesNotExist:
            return False
    
    def _to_entity(self, message_model: ChatMessageModel) -> ChatMessage:
        """Convert Django ORM model to domain entity
        
        Args:
            message_model: Django ORM model
            
        Returns:
            ChatMessage domain entity
        """
        return ChatMessage(
            id=message_model.id,
            application_id=message_model.application_id,
            sender_id=message_model.sender_id,
            content=message_model.content,
            created_at=message_model.created_at
        )
