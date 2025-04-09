"""
Conversation entity for the messaging system.

This module defines the Conversation entity, which represents a chat room
or conversation thread between two or more users.
"""
from datetime import datetime
from typing import List, Optional, Dict, Any
import uuid

from pydantic import BaseModel, Field


class Conversation(BaseModel):
    """
    Conversation entity representing a chat room between users.
    
    A conversation is a container for messages between two or more users.
    It tracks participants, conversation metadata, and provides context for messages.
    
    Attributes:
        id: Unique identifier for the conversation
        type: Type of conversation (direct, group, task-related, etc.)
        participants: List of user IDs participating in the conversation
        title: Optional title for the conversation (mainly for group chats)
        created_at: When the conversation was created
        last_message_at: When the last message was sent
        metadata: Additional data (e.g., task_id for task-related conversations)
    """
    id: uuid.UUID
    type: str  # direct, group, task
    participants: List[uuid.UUID]
    created_at: datetime
    last_message_at: Optional[datetime] = None
    title: Optional[str] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)

    # for task we will return ;
    # the task title, image, price, and id

    @classmethod
    def create(cls, participants: List[uuid.UUID], type: str = "task", 
               title: Optional[str] = None, metadata: Optional[Dict[str, Any]] = None) -> 'Conversation':
        """
        Factory method to create a new conversation.
        
        This is the preferred way to create new Conversation instances as it
        handles generating IDs and setting the current timestamp.
        
        Args:
            participants: List of user IDs participating in the conversation
            type: Type of conversation (default: "task")
            title: Optional title for the conversation
            metadata: Additional conversation metadata
            
        Returns:
            A new Conversation instance
        """
        return cls(
            id=uuid.uuid4(),
            type=type,
            participants=participants,
            created_at=datetime.now(),
            title=title,
            metadata=metadata or {}
        )
    
    def update_last_message_time(self, timestamp: Optional[datetime] = None) -> 'Conversation':
        """
        Update the last_message_at timestamp.
        
        Args:
            timestamp: Timestamp to set (default: current time)
            
        Returns:
            Self with updated last_message_at timestamp
        """
        self.last_message_at = timestamp or datetime.now()
        return self
    
    def add_participant(self, user_id: uuid.UUID) -> 'Conversation':
        """
        Add a participant to the conversation.
        
        Args:
            user_id: ID of the user to add
            
        Returns:
            Self with updated participants list
        """
        if user_id not in self.participants:
            self.participants.append(user_id)
        return self
    
    def remove_participant(self, user_id: uuid.UUID) -> 'Conversation':
        """
        Remove a participant from the conversation.
        
        Args:
            user_id: ID of the user to remove
            
        Returns:
            Self with updated participants list
        """
        if len(self.participants) <= 2:
            raise ValueError("Cannot remove participant: conversation needs at least 2 participants")
            
        if user_id in self.participants:
            self.participants.remove(user_id)
        return self
