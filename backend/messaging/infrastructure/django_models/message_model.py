"""
Django model for messages.

This module defines the Django ORM model for storing messages in the database.
"""
from django.db import models
from django.conf import settings
import uuid
from .conversation_model import ConversationModel

class MessageModel(models.Model):
    """
    Django model for storing messages.
    
    This model represents a message in the database. It maps directly to the
    Message domain entity but is specific to the Django ORM.
    
    Attributes:
        id: Primary key (UUID)
        conversation: Foreign key to the conversation this message belongs to
        sender: Foreign key to the user who sent the message
        content: The message content
        content_type: Type of content (text, image, file, etc.)
        sent_at: When the message was sent
        delivered_at: When the message was delivered to the recipient(s)
        read_at: When the message was read by the recipient(s)
        metadata: Additional data for special message types (JSON field)
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(
        ConversationModel,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    content = models.TextField()
    content_type = models.CharField(max_length=20, default='text')
    sent_at = models.DateTimeField(auto_now_add=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    read_at = models.DateTimeField(null=True, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    
    class Meta:
        """Meta options for the MessageModel."""
        db_table = 'messaging_message'
        ordering = ['-sent_at']
        indexes = [
            models.Index(fields=['conversation', '-sent_at']),
            models.Index(fields=['sender', '-sent_at']),
        ]
    
    def __str__(self):
        """String representation of the message."""
        return f"Message {self.id} from {self.sender_id} in conversation {self.conversation_id}"
