"""
Message repository interface.

This module defines the interface for accessing and manipulating Message entities.
Following the repository pattern, this interface abstracts the data access logic
from the business logic.
"""
from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid

from ..models.entities.message import Message


class MessageRepository(ABC):
    """
    Interface for accessing and manipulating Message entities.
    
    This repository interface defines the contract for how Message entities
    are stored, retrieved, and manipulated. Concrete implementations will
    handle the actual data access logic (e.g., database queries).
    """
    
    @abstractmethod
    def create(self, message: Message) -> Message:
        """
        Create a new message in the repository.
        
        Args:
            message: The message to create
            
        Returns:
            The created message with any repository-generated fields updated
        """
        pass
    
    @abstractmethod
    def update(self, message: Message) -> Message:
        """
        Update an existing message in the repository.
        
        Args:
            message: The message to update
            
        Returns:
            The updated message with any repository-generated fields updated
        """
        pass
    
    @abstractmethod
    def get_by_id(self, message_id: uuid.UUID) -> Optional[Message]:
        """
        Get a message by its ID.
        
        Args:
            message_id: ID of the message to retrieve
            
        Returns:
            The message if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_conversation(self, conversation_id: uuid.UUID, 
                           limit: int = 50, before_id: Optional[uuid.UUID] = None) -> List[Message]:
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
        pass
    
    @abstractmethod
    def mark_as_delivered(self, message_ids: List[uuid.UUID], 
                         delivered_at: Optional[datetime] = None) -> int:
        """
        Mark messages as delivered.
        
        Args:
            message_ids: List of message IDs to mark as delivered
            delivered_at: Delivery timestamp (default: current time)
            
        Returns:
            Number of messages updated
        """
        pass
    
    @abstractmethod
    def mark_as_read(self, message_ids: List[uuid.UUID], 
                    user_id: uuid.UUID,
                    read_at: Optional[datetime] = None) -> int:
        """
        Mark messages as read by a specific user.
        
        Args:
            message_ids: List of message IDs to mark as read
            user_id: ID of the user who read the messages
            read_at: Read timestamp (default: current time)
            
        Returns:
            Number of messages updated
        """
        pass
    
    @abstractmethod
    def find(self, criteria: Dict[str, Any], 
            order_by: str = "-sent_at", 
            limit: int = 50, 
            offset: int = 0) -> List[Message]:
        """
        Find messages matching specific criteria.
        
        This is a flexible query method that allows searching for messages
        based on various criteria.
        
        Args:
            criteria: Dictionary of search criteria
            order_by: Field to order results by (prefix with - for descending)
            limit: Maximum number of results to return
            offset: Number of results to skip
            
        Returns:
            List of messages matching the criteria
        """
        pass
    
    @abstractmethod
    def delete(self, message_id: uuid.UUID) -> bool:
        """
        Delete a message.
        
        Args:
            message_id: ID of the message to delete
            
        Returns:
            True if the message was deleted, False otherwise
        """
        pass
