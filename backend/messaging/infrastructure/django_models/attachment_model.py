"""
Django model for file attachments.

This module defines the Django ORM model for storing file attachment metadata in the database.
"""
from django.db import models
from django.conf import settings
import uuid

from .message_model import MessageModel

class AttachmentModel(models.Model):
    """
    Django model for storing file attachment metadata.
    
    This model represents a file attachment in the database. It stores metadata
    about the file, while the actual file content is stored in the file system
    or a cloud storage service.
    
    Attributes:
        id: Primary key (UUID)
        file_name: Original name of the file
        file_path: Path where the file is stored
        file_url: URL to access the file
        file_size: Size of the file in bytes
        content_type: MIME type of the file
        uploaded_by: Foreign key to the user who uploaded the file
        uploaded_at: When the file was uploaded
        message: Optional foreign key to the message this attachment belongs to
        metadata: Optional additional metadata for the attachment
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    file_name = models.CharField(max_length=255)
    file_path = models.CharField(max_length=1000)
    file_url = models.CharField(max_length=1000)
    file_size = models.PositiveIntegerField()
    content_type = models.CharField(max_length=100)
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='uploaded_attachments'
    )
    uploaded_at = models.DateTimeField(auto_now_add=True)
    message = models.ForeignKey(
        MessageModel,
        on_delete=models.CASCADE,
        related_name='attachments',
        null=True,
        blank=True
    )
    metadata = models.JSONField(default=dict, blank=True, null=True)
    
    class Meta:
        """Meta options for the AttachmentModel."""
        app_label = 'messaging'
        db_table = 'messaging_attachment'
        ordering = ['-uploaded_at']
        indexes = [
            models.Index(fields=['uploaded_by', '-uploaded_at']),
            models.Index(fields=['message']),
        ]
    
    def __str__(self):
        """String representation of the attachment."""
        return f"Attachment {self.id}: {self.file_name}"
