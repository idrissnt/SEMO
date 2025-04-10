"""
Django model for conversations.

This module defines the Django ORM model for storing conversations in the database.
"""
from django.db import models
from django.conf import settings
import uuid


class ConversationModel(models.Model):
    """
    Django model for storing conversations.
    
    This model represents a conversation in the database. It maps directly to the
    Conversation domain entity but is specific to the Django ORM.
    
    Attributes:
        id: Primary key (UUID)
        type: Type of conversation (direct, group, task)
        title: Optional title for the conversation
        created_at: When the conversation was created
        last_message_at: When the last message was sent
        metadata: Additional data (e.g., task_id for task-related conversations)
        participants: Many-to-many relationship with users
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    type = models.CharField(max_length=20, default='direct')
    title = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    last_message_at = models.DateTimeField(null=True, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    participants = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='conversations',
        through='ConversationParticipantModel'
    )
    
    class Meta:
        """Meta options for the ConversationModel."""
        app_label = 'messaging'
        db_table = 'messaging_conversation'
        ordering = ['-last_message_at', '-created_at']
        indexes = [
            models.Index(fields=['-last_message_at']),
            models.Index(fields=['type']),
        ]
    
    def __str__(self):
        """String representation of the conversation."""
        return f"Conversation {self.id} ({self.type})"


class ConversationParticipantModel(models.Model):
    """
    Django model for conversation participants.
    
    This model represents the many-to-many relationship between conversations and users,
    with additional metadata about the participant's role and status in the conversation.
    
    Attributes:
        id: Primary key (UUID)
        conversation: Foreign key to the conversation
        user: Foreign key to the user
        joined_at: When the user joined the conversation
        is_admin: Whether the user is an admin of the conversation
        last_read_at: When the user last read the conversation
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(
        ConversationModel,
        on_delete=models.CASCADE,
        related_name='conversation_participants'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='conversation_participations'
    )
    joined_at = models.DateTimeField(auto_now_add=True)
    is_admin = models.BooleanField(default=False)
    last_read_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        """Meta options for the ConversationParticipantModel."""
        app_label = 'messaging'
        db_table = 'messaging_conversation_participant'
        unique_together = ('conversation', 'user')
        indexes = [
            models.Index(fields=['user', 'conversation']),
        ]
    
    def __str__(self):
        """String representation of the conversation participant."""
        return f"User {self.user_id} in conversation {self.conversation_id}"
