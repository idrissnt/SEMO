"""
Conversation repository interface.

This module defines the interface for accessing and manipulating Conversation entities.
Following the repository pattern, this interface abstracts the data access logic
from the business logic.
"""
from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
import uuid

from ..models import Conversation


class ConversationRepository(ABC):
    """
    Interface for accessing and manipulating Conversation entities.
    
    This repository interface defines the contract for how Conversation entities
    are stored, retrieved, and manipulated. Concrete implementations will
    handle the actual data access logic (e.g., database queries).
    """

    @abstractmethod
    def create(self, conversation: Conversation) -> Conversation:
        """
        Create a new conversation in the database.
        
        Args:
            conversation: The conversation to save
            
        Returns:
            The created conversation with any repository-generated fields updated
        """
        pass
    
    @abstractmethod
    def update(self, conversation: Conversation) -> Conversation:
        """
        Update an existing conversation in the database.
        
        This method updates an existing conversation with the provided details.
        
        Args:
            conversation: The conversation to save
            
        Returns:
            The saved conversation with any repository-generated fields updated
        """
        pass
    
    @abstractmethod
    def get_by_id(self, conversation_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get a conversation by its ID.
        
        Args:
            conversation_id: ID of the conversation to retrieve
            
        Returns:
            The conversation if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_participant(self, user_id: uuid.UUID, 
                          limit: int = 50, 
                          offset: int = 0) -> List[Conversation]:
        """
        Get conversations for a specific participant.
        
        This method retrieves conversations that a specific user is participating in,
        ordered by last_message_at in descending order (newest first).
        
        Args:
            user_id: ID of the participant
            limit: Maximum number of conversations to return
            offset: Number of conversations to skip
            
        Returns:
            List of conversations the user is participating in
        """
        pass
    
    @abstractmethod
    def get_by_task(self, task_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get the conversation associated with a specific task.
        
        Args:
            task_id: ID of the task
            
        Returns:
            The task conversation if found, None otherwise
        """
        pass
    
    @abstractmethod
    def delete(self, conversation_id: uuid.UUID) -> bool:
        """
        Delete a conversation.
        
        Args:
            conversation_id: ID of the conversation to delete
            
        Returns:
            True if the conversation was deleted, False otherwise
        """
        pass
