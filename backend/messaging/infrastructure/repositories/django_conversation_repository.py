"""
Django implementation of the ConversationRepository.

This module provides a Django ORM implementation of the ConversationRepository interface.
"""
from typing import List, Optional, Dict, Any
import uuid

from django.utils import timezone

from ...domain import (Conversation, ConversationRepository)
from ..django_models import ConversationModel, ConversationParticipantModel


class DjangoConversationRepository(ConversationRepository):
    """
    Django ORM implementation of the ConversationRepository interface.
    
    This class implements the ConversationRepository interface using Django's ORM
    to interact with the database.
    """
    
    def create(self, conversation: Conversation) -> Conversation:
        """
        Create a new conversation in the database
        """
        conversation_dict = conversation.model_dump()
        conversation_model = ConversationModel.objects.create(
                id=conversation_dict['id'],
                type=conversation_dict['type'],
                title=conversation_dict['title'],
                created_at=conversation_dict['created_at'],
                last_message_at=conversation_dict['last_message_at'],
                metadata=conversation_dict['metadata']
            )
            
        # Add participants
        self._add_participants(conversation_model, conversation.participants)
            
        # Convert back to domain entity
        return self._to_domain_entity(conversation_model)   

    def update(self, conversation: Conversation) -> Conversation:
        """
        Update an existing conversation in the database.
        """
        # Check if the conversation already exists
        try:
            conversation_model = ConversationModel.objects.get(id=conversation.id)
            # Update existing conversation
            conversation_dict = conversation.model_dump()
            conversation_model.type = conversation_dict['type']
            conversation_model.title = conversation_dict['title']
            conversation_model.last_message_at = conversation_dict['last_message_at']
            conversation_model.metadata = conversation_dict['metadata']
            conversation_model.save()
            
            # Update participants (this is more complex)
            self._update_participants(conversation_model, conversation.participants)
            return self._to_domain_entity(conversation_model)
        except ConversationModel.DoesNotExist:  
            return None

    def get_by_id(self, conversation_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get a conversation by its ID.
        
        Args:
            conversation_id: ID of the conversation to retrieve
            
        Returns:
            The conversation if found, None otherwise
        """
        try:
            conversation_model = ConversationModel.objects.get(id=conversation_id)
            return self._to_domain_entity(conversation_model)
        except ConversationModel.DoesNotExist:
            return None
    
    def get_by_participant(
        self,
        user_id: uuid.UUID,
        limit: int = 50,
        offset: int = 0
    ) -> List[Conversation]:
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
        # Get conversations where the user is a participant
        conversations = ConversationModel.objects.filter(
            participants__id=user_id
        ).order_by('-last_message_at', '-created_at')[offset:offset + limit]
        
        # Convert to domain entities
        return [self._to_domain_entity(c) for c in conversations]
    
    def get_by_task(self, task_id: uuid.UUID) -> Optional[Conversation]:
        """
        Get the conversation associated with a specific task.
        
        Args:
            task_id: ID of the task
            
        Returns:
            The task conversation if found, None otherwise
        """
        # Find conversations with the task_id in metadata
        try:
            conversation = ConversationModel.objects.get(
                type='task',
                metadata__task_id=str(task_id)
            )
            return self._to_domain_entity(conversation)
        except ConversationModel.DoesNotExist:
            return None
        except ConversationModel.MultipleObjectsReturned:
            # If multiple conversations exist for the same task (shouldn't happen),
            # return the most recent one
            conversation = ConversationModel.objects.filter(
                type='task',
                metadata__task_id=str(task_id)
            ).order_by('-created_at').first()
            return self._to_domain_entity(conversation)
    
    def find(
        self,
        criteria: Dict[str, Any],
        order_by: str = "-last_message_at",
        limit: int = 50,
        offset: int = 0
    ) -> List[Conversation]:
        """
        Find conversations matching specific criteria.
        
        This is a flexible query method that allows searching for conversations
        based on various criteria.
        
        Args:
            criteria: Dictionary of search criteria
            order_by: Field to order results by (prefix with - for descending)
            limit: Maximum number of results to return
            offset: Number of results to skip
            
        Returns:
            List of conversations matching the criteria
        """
        # Start with all conversations
        query = ConversationModel.objects.all()
        
        # Apply filters based on criteria
        for key, value in criteria.items():
            if key == 'participant_id':
                # Special case for filtering by participant
                query = query.filter(participants__id=value)
            elif key.endswith('__in'):
                # Special case for "in" comparison
                field = key.replace('__in', '')
                query = query.filter(**{field + '__in': value})
            else:
                query = query.filter(**{key: value})
        
        # Apply ordering, limit, and offset
        conversations = query.order_by(order_by)[offset:offset + limit]
        
        # Convert to domain entities
        return [self._to_domain_entity(c) for c in conversations]
    
    def delete(self, conversation_id: uuid.UUID) -> bool:
        """
        Delete a conversation.
        
        Args:
            conversation_id: ID of the conversation to delete
            
        Returns:
            True if the conversation was deleted, False otherwise
        """
        try:
            conversation = ConversationModel.objects.get(id=conversation_id)
            conversation.delete()
            return True
        except ConversationModel.DoesNotExist:
            return False
    
    def _to_domain_entity(self, model: ConversationModel) -> Conversation:
        """
        Convert a Django model instance to a domain entity.
        
        Args:
            model: Django model instance
            
        Returns:
            Domain entity
        """
        # Get participant IDs
        participant_ids = [
            uuid.UUID(str(p.id)) for p in model.participants.all()
        ]
        
        return Conversation(
            id=model.id,
            type=model.type,
            participants=participant_ids,
            created_at=model.created_at,
            last_message_at=model.last_message_at,
            title=model.title,
            metadata=model.metadata or {}
        )
    
    def _add_participants(self, conversation_model: ConversationModel, participant_ids: List[uuid.UUID]) -> None:
        """
        Add participants to a conversation.
        
        Args:
            conversation_model: Django conversation model
            participant_ids: List of participant user IDs to add
        """
        for user_id in participant_ids:
            ConversationParticipantModel.objects.create(
                conversation=conversation_model,
                user_id=user_id,
                joined_at=timezone.now()
            )
    
    def _update_participants(self, conversation_model: ConversationModel, participant_ids: List[uuid.UUID]) -> None:
        """
        Update the participants of a conversation using Django's set() method.
        
        This method efficiently handles both adding new participants and removing
        participants who are no longer in the list, all in a single operation.
        
        Args:
            conversation_model: Django conversation model
            participant_ids: List of participant user IDs that should be in the conversation
        """
        # Convert UUIDs to strings if needed
        user_ids = [str(p) if isinstance(p, uuid.UUID) else p for p in participant_ids]
        
        # Use set() to efficiently update the many-to-many relationship
        if conversation_model.type == 'direct':
            # For direct conversations, only add participants, don't remove
            # This ensures direct conversations always have exactly 2 participants
            for user_id in user_ids:
                if not conversation_model.participants.filter(id=user_id).exists():
                    ConversationParticipantModel.objects.create(
                        conversation=conversation_model,
                        user_id=user_id,
                        joined_at=timezone.now()
                    )
        else:
            # For group conversations, use set() to handle both additions and removals
            conversation_model.participants.set(user_ids, through_defaults={'joined_at': timezone.now()})
