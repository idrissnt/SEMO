"""
Task conversation service for integrating messaging with the task system.

This module contains the TaskConversationService class, which implements the business logic
for creating and managing conversations related to tasks.
"""
from typing import Optional, Dict, Any
import uuid

from ...domain.models import Conversation
from ...domain.repositories import ConversationRepository
from .conversation_service import ConversationService


class TaskConversationService:
    """
    Service for task-related conversation business logic.
    
    This service integrates the messaging system with the task management system,
    providing methods for creating and managing conversations related to tasks.
    """
    
    def __init__(
        self,
        conversation_service: ConversationService,
        conversation_repository: ConversationRepository
    ):
        """
        Initialize the task conversation service with required services and repositories.
        
        Args:
            conversation_service: Service for conversation operations
            conversation_repository: Repository for accessing conversations
        """
        self.conversation_service = conversation_service
        self.conversation_repository = conversation_repository
    
    def create_task_conversation(
        self,
        task_id: uuid.UUID,
        requester_id: uuid.UUID,
        performer_id: uuid.UUID,
        task_title: Optional[str] = None
    ) -> Conversation:
        """
        Create a conversation for a specific task.
        
        This method creates a conversation specifically for a task, including
        both the task requester and performer as participants.
        
        Args:
            task_id: ID of the task
            requester_id: ID of the task requester
            performer_id: ID of the task performer
            task_title: Title of the task (used for the conversation title)
            
        Returns:
            The created task conversation
        """
        # Check if a conversation already exists for this task
        existing = self.conversation_repository.get_by_task(task_id)
        if existing:
            return existing
        
        # Create a title for the conversation
        title = f"Task Discussion"
        if task_title:
            title = f"Task: {task_title}"
        
        # Create the conversation
        conversation = self.conversation_service.create_conversation(
            participants=[requester_id, performer_id],
            type="task",
            title=title,
            metadata={
                "task_id": str(task_id),
                "requester_id": str(requester_id),
                "performer_id": str(performer_id)
            }
        )
        
        return conversation
    
    def get_task_conversation(self, task_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get the conversation for a specific task.
        
        Args:
            task_id: ID of the task
            
        Returns:
            The task conversation if found, None otherwise
        """
        return self.conversation_repository.get_by_task(task_id)
    
    def add_task_participant(
        self,
        task_id: uuid.UUID,
        user_id: uuid.UUID,
        added_by_id: uuid.UUID
    ) -> Optional[Conversation]:
        """
        Add a participant to a task conversation.
        
        This method adds a user to a task conversation if the user adding them
        is already a participant.
        
        Args:
            task_id: ID of the task
            user_id: ID of the user to add
            added_by_id: ID of the user adding the new participant
            
        Returns:
            The updated conversation if successful, None otherwise
            
        Raises:
            ValueError: If the conversation doesn't exist or if the user adding
                       the participant is not a participant themselves
        """
        conversation = self.conversation_repository.get_by_task(task_id)
        if not conversation:
            return None
        
        return self.conversation_service.add_participant(
            conversation_id=conversation.id,
            user_id=user_id,
            added_by_id=added_by_id
        )
    
    def notify_task_status_change(
        self,
        task_id: uuid.UUID,
        status: str,
        updated_by_id: uuid.UUID
    ) -> Optional[Dict[str, Any]]:
        """
        Send a system message about a task status change.
        
        This method sends a system message to the task conversation when
        the task status changes.
        
        Args:
            task_id: ID of the task
            status: New status of the task
            updated_by_id: ID of the user who updated the status
            
        Returns:
            Dictionary with information about the sent message, or None if
            no conversation exists for the task
        """
        # This would typically call the MessageService to send a system message
        # For now, we'll just return information about what would be sent
        conversation = self.conversation_repository.get_by_task(task_id)
        if not conversation:
            return None
        
        return {
            "conversation_id": str(conversation.id),
            "content": f"Task status changed to: {status}",
            "content_type": "system",
            "metadata": {
                "task_id": str(task_id),
                "status": status,
                "updated_by_id": str(updated_by_id)
            }
        }
