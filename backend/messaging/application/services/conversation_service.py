"""
Conversation service for handling conversation-related business logic.

This module contains the ConversationService class, which implements the business logic
for creating, retrieving, and managing conversations.
"""
from typing import List, Optional, Dict, Any
import uuid

from ...domain.models import Conversation
from ...domain.repositories import ConversationRepository


class ConversationService:
    """
    Service for conversation-related business logic.
    
    This service encapsulates all business logic related to conversations, including
    creating, retrieving, and managing conversations. It uses the repository to
    access and manipulate data, but contains the business rules itself.
    """
    
    def __init__(self, conversation_repository: ConversationRepository):
        """
        Initialize the conversation service with required repositories.
        
        Args:
            conversation_repository: Repository for accessing conversations
        """
        self.conversation_repository = conversation_repository
    
    def create_conversation(
        self,
        participants: List[uuid.UUID],
        type: str = "direct",
        title: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> Conversation:
        """
        Create a new conversation.
        
        For direct conversations (between two users), this method will first check
        if a conversation already exists between the participants and return that
        instead of creating a duplicate.
        
        Args:
            participants: List of user IDs participating in the conversation
            type: Type of conversation (default: "direct")
            title: Optional title for the conversation
            metadata: Additional conversation metadata
            
        Returns:
            The created or existing conversation
            
        Raises:
            ValueError: If the conversation type is invalid or if the participants list
                       doesn't meet the requirements for the conversation type
        """
        # For direct conversations, check if one already exists between these users
        if type == "direct":
            if len(participants) != 2:
                raise ValueError("Direct conversations must have exactly 2 participants")
                
            existing = self.conversation_repository.get_direct_conversation(
                user_id1=participants[0],
                user_id2=participants[1]
            )
            
            if existing:
                return existing
        
        # Create a new conversation
        conversation = Conversation.create(
            participants=participants,
            type=type,
            title=title,
            metadata=metadata
        )
        
        return self.conversation_repository.save(conversation)
    
    def get_conversation(self, conversation_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get a conversation by its ID.
        
        Args:
            conversation_id: ID of the conversation to retrieve
            
        Returns:
            The conversation if found, None otherwise
        """
        return self.conversation_repository.get_by_id(conversation_id)
    
    def get_user_conversations(
        self,
        user_id: uuid.UUID,
        limit: int = 50,
        offset: int = 0
    ) -> List[Conversation]:
        """
        Get conversations for a specific user.
        
        This method retrieves conversations that a specific user is participating in,
        ordered by last_message_at in descending order (newest first).
        
        Args:
            user_id: ID of the user
            limit: Maximum number of conversations to return
            offset: Number of conversations to skip
            
        Returns:
            List of conversations the user is participating in
        """
        return self.conversation_repository.get_by_participant(
            user_id=user_id,
            limit=limit,
            offset=offset
        )
    
    def get_or_create_direct_conversation(
        self,
        user_id1: uuid.UUID,
        user_id2: uuid.UUID
    ) -> Conversation:
        """
        Get or create a direct conversation between two users.
        
        This method first checks if a direct conversation already exists between
        the two users. If it does, it returns that conversation. Otherwise, it
        creates a new direct conversation.
        
        Args:
            user_id1: ID of the first user
            user_id2: ID of the second user
            
        Returns:
            The existing or newly created direct conversation
        """
        existing = self.conversation_repository.get_direct_conversation(
            user_id1=user_id1,
            user_id2=user_id2
        )
        
        if existing:
            return existing
            
        conversation = Conversation.create(
            participants=[user_id1, user_id2],
            type="direct"
        )
        
        return self.conversation_repository.save(conversation)
    
    def add_participant(
        self,
        conversation_id: uuid.UUID,
        user_id: uuid.UUID,
        added_by_id: uuid.UUID
    ) -> Optional[Conversation]:
        """
        Add a participant to a conversation.
        
        This method adds a user to a conversation if the user adding them
        is already a participant and the conversation is not a direct conversation.
        
        Args:
            conversation_id: ID of the conversation
            user_id: ID of the user to add
            added_by_id: ID of the user adding the new participant
            
        Returns:
            The updated conversation if successful, None otherwise
            
        Raises:
            ValueError: If the conversation is a direct conversation or if the
                       user adding the participant is not a participant themselves
        """
        conversation = self.conversation_repository.get_by_id(conversation_id)
        if not conversation:
            return None
            
        # Check if the user adding the participant is a participant
        if added_by_id not in conversation.participants:
            raise ValueError("Only participants can add new participants")
            
        # Add the participant
        updated_conversation = conversation.add_participant(user_id)
        return self.conversation_repository.save(updated_conversation)
    
    def remove_participant(
        self,
        conversation_id: uuid.UUID,
        user_id: uuid.UUID,
        removed_by_id: uuid.UUID
    ) -> Optional[Conversation]:
        """
        Remove a participant from a conversation.
        
        This method removes a user from a conversation if the user removing them
        is already a participant and the conversation is not a direct conversation.
        Users can also remove themselves.
        
        Args:
            conversation_id: ID of the conversation
            user_id: ID of the user to remove
            removed_by_id: ID of the user removing the participant
            
        Returns:
            The updated conversation if successful, None otherwise
            
        Raises:
            ValueError: If the conversation is a direct conversation or if the
                       user removing the participant is not a participant themselves
                       and is not the user being removed
        """
        conversation = self.conversation_repository.get_by_id(conversation_id)
        if not conversation:
            return None
            
        # Check if the user removing the participant is a participant or is removing themselves
        if removed_by_id not in conversation.participants and removed_by_id != user_id:
            raise ValueError("Only participants can remove participants")
            
        # Remove the participant
        updated_conversation = conversation.remove_participant(user_id)
        return self.conversation_repository.save(updated_conversation)
    
    def update_conversation_title(
        self,
        conversation_id: uuid.UUID,
        title: str,
        user_id: uuid.UUID
    ) -> Optional[Conversation]:
        """
        Update the title of a conversation.
        
        This method updates the title of a conversation if the user is a participant.
        
        Args:
            conversation_id: ID of the conversation
            title: New title for the conversation
            user_id: ID of the user updating the title
            
        Returns:
            The updated conversation if successful, None otherwise
            
        Raises:
            ValueError: If the user is not a participant in the conversation
        """
        conversation = self.conversation_repository.get_by_id(conversation_id)
        if not conversation:
            return None
            
        # Check if the user is a participant
        if user_id not in conversation.participants:
            raise ValueError("Only participants can update the conversation title")
            
        # Update the title
        conversation.title = title
        return self.conversation_repository.save(conversation)
    
    def get_conversation_by_task(self, task_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get the conversation associated with a specific task.
        
        Args:
            task_id: ID of the task
            
        Returns:
            The task conversation if found, None otherwise
        """
        return self.conversation_repository.get_by_task(task_id)
