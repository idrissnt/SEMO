"""
Django implementation of the AttachmentRepository.

This module provides a Django ORM implementation of the AttachmentRepository interface.
"""
from typing import Optional, BinaryIO, List
import uuid

from django.conf import settings
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.urls import reverse

from domain import (AttachmentRepository, Attachment)
from django_models import AttachmentModel


class DjangoAttachmentRepository(AttachmentRepository):
    """
    Django ORM implementation of the AttachmentRepository interface.
    
    This class implements the AttachmentRepository interface using Django's ORM
    and file storage system to store and retrieve file attachments.
    """
    
    def save(
        self,
        file_data: BinaryIO,
        filename: str,
        content_type: str,
        user_id: uuid.UUID
    ) -> Attachment:
        """
        Save an attachment file.
        
        Args:
            file_data: The binary file data
            filename: Original filename
            content_type: MIME type of the file
            user_id: ID of the user uploading the file
            
        Returns:
            An Attachment entity representing the saved file
        """
        # Generate a unique ID for the file
        file_id = uuid.uuid4()
        
        # Create a path for the file based on user ID and file ID
        # This helps organize files and avoid name collisions
        relative_path = f"attachments/{user_id}/{file_id}/{filename}"
        
        # Save the file using Django's storage system
        file_path = default_storage.save(relative_path, ContentFile(file_data.read()))
        
        # Get the file URL
        file_url = self._get_file_url(file_path)
        
        # Get the file size
        file_size = default_storage.size(file_path)
        
        # Create the attachment model
        attachment = AttachmentModel.objects.create(
            id=file_id,
            file_name=filename,
            file_path=file_path,
            file_url=file_url,
            file_size=file_size,
            content_type=content_type,
            uploaded_by_id=user_id
        )
        
        # Convert to domain entity and return
        return self._to_domain_entity(attachment)
    
    def get(self, file_id: uuid.UUID) -> Optional[Attachment]:
        """
        Get an attachment by its ID.
        
        Args:
            file_id: ID of the attachment to retrieve
            
        Returns:
            An Attachment entity, or None if not found
        """
        try:
            attachment = AttachmentModel.objects.get(id=file_id)
            
            # Check if the file exists
            if not default_storage.exists(attachment.file_path):
                return None
            
            # Convert to domain entity and return
            return self._to_domain_entity(attachment)
        except AttachmentModel.DoesNotExist:
            return None
    
    def delete(self, file_id: uuid.UUID) -> bool:
        """
        Delete an attachment.
        
        Args:
            file_id: ID of the attachment to delete
            
        Returns:
            True if the attachment was deleted, False otherwise
        """
        try:
            attachment = AttachmentModel.objects.get(id=file_id)
            
            # Delete the file from storage
            if default_storage.exists(attachment.file_path):
                default_storage.delete(attachment.file_path)
            
            # Delete the attachment model
            attachment.delete()
            
            return True
        except AttachmentModel.DoesNotExist:
            return False
            
    def get_by_message(self, message_id: uuid.UUID) -> List[Attachment]:
        """
        Get all attachments for a specific message.
        
        Args:
            message_id: The ID of the message
            
        Returns:
            A list of Attachment entities
        """
        attachments = AttachmentModel.objects.filter(message_id=message_id)
        return [self._to_domain_entity(attachment) for attachment in attachments]
    
    def associate_with_message(self, file_id: uuid.UUID, message_id: uuid.UUID) -> Optional[Attachment]:
        """
        Associate an attachment with a message.
        
        Args:
            file_id: The ID of the attachment
            message_id: The ID of the message
            
        Returns:
            The updated Attachment entity, or None if the attachment was not found
        """
        try:
            attachment = AttachmentModel.objects.get(id=file_id)
            attachment.message_id = message_id
            attachment.save(update_fields=['message_id'])
            return self._to_domain_entity(attachment)
        except AttachmentModel.DoesNotExist:
            return None

    def _get_file_url(self, file_path: str) -> str:
        """
        Get the URL for a file path.
        
        Args:
            file_path: Path to the file in storage
            
        Returns:
            URL to access the file
        """
        # If using default file storage with a URL method, use that
        if hasattr(default_storage, 'url'):
            return default_storage.url(file_path)
        
        # Otherwise, construct a URL using Django's reverse function
        # This assumes you have a view named 'attachment-download' that takes a path parameter
        try:
            return reverse('attachment-download', kwargs={'path': file_path})
        except:
            # Fallback to a simple path-based URL
            return f"/media/{file_path}"

    def _to_domain_entity(self, attachment: AttachmentModel) -> Attachment: 
        """
        Convert an attachment model to a domain entity.
        
        Args:
            attachment: AttachmentModel instance
            
        Returns:
            Attachment domain entity
        """
        return Attachment(
            id=attachment.id,
            filename=attachment.file_name,
            content_type=attachment.content_type,
            file_path=attachment.file_path,
            file_size=attachment.file_size,
            uploaded_by_id=attachment.uploaded_by.id,
            uploaded_at=attachment.uploaded_at,
            message_id=attachment.message.id,
            metadata=attachment.metadata or {}
        )