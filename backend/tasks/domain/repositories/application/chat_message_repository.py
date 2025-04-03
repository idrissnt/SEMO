"""
Repository interface for ChatMessage domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from datetime import datetime

from ...models.entities.chat_message import ChatMessage


class ChatMessageRepository(ABC):
    """Repository interface for ChatMessage domain model"""
    
    @abstractmethod
    def get_by_id(self, message_id: uuid.UUID) -> Optional[ChatMessage]:
        """Get message by ID
        
        Args:
            message_id: UUID of the message
            
        Returns:
            ChatMessage object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_application_id(self, application_id: uuid.UUID) -> List[ChatMessage]:
        """Get all messages for a task application
        
        Args:
            application_id: UUID of the task application
            
        Returns:
            List of ChatMessage objects
        """
        pass
    
    @abstractmethod
    def get_unread_by_user(self, user_id: uuid.UUID) -> List[ChatMessage]:
        """Get all unread messages for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of ChatMessage objects
        """
        pass
    
    @abstractmethod
    def create(self, message: ChatMessage) -> ChatMessage:
        """Create a new message
        
        Args:
            message: ChatMessage object to create
            
        Returns:
            Created ChatMessage object
        """
        pass
    
    @abstractmethod
    def mark_as_read(self, message_id: uuid.UUID) -> bool:
        """Mark a message as read
        
        Args:
            message_id: UUID of the message to mark as read
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def delete(self, message_id: uuid.UUID) -> bool:
        """Delete a message
        
        Args:
            message_id: UUID of the message to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
