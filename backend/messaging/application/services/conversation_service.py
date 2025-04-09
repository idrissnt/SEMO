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
