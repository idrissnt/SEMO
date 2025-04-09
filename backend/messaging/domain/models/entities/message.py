"""
Message entity for the messaging system.

This module defines the Message entity, which represents a single message
in a conversation between users.
"""
from datetime import datetime
from typing import Optional, Dict, Any
import uuid

from pydantic import BaseModel, Field


class Message(BaseModel):
    """
    Message entity representing a single message in a conversation.
    
    A message is the core entity of the messaging system. It contains the actual content
    sent by a user, along with metadata about when it was sent, delivered, and read.
    
    Attributes:
        id: Unique identifier for the message
        conversation_id: ID of the conversation this message belongs to
        sender_id: ID of the user who sent the message
        content: The actual message content
        content_type: Type of content (text, image, file, etc.)
        sent_at: When the message was sent
        delivered_at: When the message was delivered to the recipient(s)
        read_at: When the message was read by the recipient(s)
        metadata: Additional data for special message types (attachments, locations, etc.)
    """
    id: uuid.UUID
    conversation_id: uuid.UUID
    sender_id: uuid.UUID
    content: str
    content_type: str  # text, image, file, etc.
    sent_at: datetime
    delivered_at: Optional[datetime] = None
    read_at: Optional[datetime] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)
    
    @classmethod
    def create(cls, conversation_id: uuid.UUID, sender_id: uuid.UUID, 
               content: str, content_type: str = "text", 
               metadata: Optional[Dict[str, Any]] = None) -> 'Message':
        """
        Factory method to create a new message.
        
        This is the preferred way to create new Message instances as it
        handles generating IDs and setting the current timestamp.
        
        Args:
            conversation_id: ID of the conversation
            sender_id: ID of the sender
            content: Message content
            content_type: Type of content (default: "text")
            metadata: Additional message metadata
            
        Returns:
            A new Message instance
        """
        return cls(
            id=uuid.uuid4(),
            conversation_id=conversation_id,
            sender_id=sender_id,
            content=content,
            content_type=content_type,
            sent_at=datetime.now(),
            metadata=metadata or {}
        )
    
    def mark_delivered(self) -> 'Message':
        """
        Mark the message as delivered.
        
        Returns:
            A new Message instance with updated delivered_at timestamp
        """
        # Create a new instance with updated delivered_at (Pydantic models are immutable)
        return self.model_copy(update={"delivered_at": datetime.now()})
    
    def mark_read(self) -> 'Message':
        """
        Mark the message as read.
        
        Returns:
            A new Message instance with updated read_at timestamp
        """
        # Create a new instance with updated read_at (Pydantic models are immutable)
        return self.model_copy(update={"read_at": datetime.now()})
