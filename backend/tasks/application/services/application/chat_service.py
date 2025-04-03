"""
Application service for chat message-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

from ....domain.models.entities.chat_message import ChatMessage
from ....domain.repositories.application.chat_message_repository import ChatMessageRepository
from ....domain.repositories.application.application_repository import TaskApplicationRepository


class ChatService:
    """Application service for chat message-related operations"""
    
    def __init__(
        self,
        chat_message_repository: ChatMessageRepository,
        task_application_repository: TaskApplicationRepository
    ):
        self.chat_message_repository = chat_message_repository
        self.task_application_repository = task_application_repository
    
    def get_message(self, message_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get message by ID
        
        Args:
            message_id: UUID of the message
            
        Returns:
            Dictionary with message information if found, None otherwise
        """
        message = self.chat_message_repository.get_by_id(message_id)
        if message:
            return self._message_to_dict(message)
        return None
    
    def get_messages_by_application(self, application_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all messages for a task application
        
        Args:
            application_id: UUID of the task application
            
        Returns:
            List of dictionaries with message information
        """
        # Check if chat is enabled for this application
        application = self.task_application_repository.get_by_id(application_id)
        if not application or not application.chat_enabled:
            return []
        
        messages = self.chat_message_repository.get_by_application_id(application_id)
        return [self._message_to_dict(message) for message in messages]
    
    def get_unread_messages(self, user_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all unread messages for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of dictionaries with message information
        """
        messages = self.chat_message_repository.get_unread_by_user(user_id)
        return [self._message_to_dict(message) for message in messages]
    
    def send_message(self, message_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Send a new message
        
        Args:
            message_data: Dictionary with message data
            
        Returns:
            Dictionary with created message information if successful, None otherwise
        """
        # Extract required fields
        application_id = uuid.UUID(message_data['task_application_id'])
        sender_id = uuid.UUID(message_data['sender_id'])
        content = message_data['content']
        
        # Check if chat is enabled for this application
        application = self.task_application_repository.get_by_id(application_id)
        if not application or not application.chat_enabled:
            return None
        
        # Create message
        message = ChatMessage(
            task_application_id=application_id,
            sender_id=sender_id,
            content=content
        )
        
        # Save message
        created_message = self.chat_message_repository.create(message)
        return self._message_to_dict(created_message)
    
    def mark_as_read(self, message_id: uuid.UUID) -> bool:
        """Mark a message as read
        
        Args:
            message_id: UUID of the message to mark as read
            
        Returns:
            True if successful, False otherwise
        """
        return self.chat_message_repository.mark_as_read(message_id)
    
    def _message_to_dict(self, message: ChatMessage) -> Dict[str, Any]:
        """Convert ChatMessage object to dictionary
        
        Args:
            message: ChatMessage object
            
        Returns:
            Dictionary with message information
        """
        return {
            'id': str(message.id),
            'task_application_id': str(message.task_application_id),
            'sender_id': str(message.sender_id),
            'content': message.content,
            'read': message.read,
            'created_at': message.created_at.isoformat()
        }
