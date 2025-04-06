"""
Attachment service for handling file uploads and attachments.

This module contains the AttachmentService class, which implements the business logic
for uploading, retrieving, and managing file attachments for messages.
"""
from typing import BinaryIO, Dict, Any, Optional, List
import uuid
import os

from ...domain.repositories import AttachmentRepository
from ...domain.models.entities.attachment import Attachment


class AttachmentService:
    """
    Service for attachment-related business logic.
    
    This service encapsulates all business logic related to file attachments,
    including uploading, retrieving, and managing attachments. It uses the
    repository to access and manipulate data, but contains the business rules itself.
    """
    
    # List of allowed file extensions and their corresponding MIME types
    ALLOWED_EXTENSIONS = {
        # Images
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
        
        # Documents
        'pdf': 'application/pdf',
        'doc': 'application/msword',
        'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'xls': 'application/vnd.ms-excel',
        'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'ppt': 'application/vnd.ms-powerpoint',
        'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'txt': 'text/plain',
        
        # Audio
        'mp3': 'audio/mpeg',
        'wav': 'audio/wav',
        'ogg': 'audio/ogg',
        
        # Video
        'mp4': 'video/mp4',
        'webm': 'video/webm',
        'avi': 'video/x-msvideo',
    }
    
    # Maximum file size (10 MB)
    MAX_FILE_SIZE = 10 * 1024 * 1024
    
    def __init__(self, attachment_repository: AttachmentRepository):
        """
        Initialize the attachment service with required repositories.
        
        Args:
            attachment_repository: Repository for accessing attachments
        """
        self.attachment_repository = attachment_repository
    
    def upload_attachment(
        self,
        file_data: BinaryIO,
        filename: str,
        content_type: str,
        user_id: uuid.UUID,
        max_size: Optional[int] = None
    ) -> Attachment:
        """
        Upload a file attachment.
        
        This method validates the file (size, type) and uploads it using the repository.
        
        Args:
            file_data: The binary file data
            filename: Original filename
            content_type: MIME type of the file
            user_id: ID of the user uploading the file
            max_size: Maximum allowed file size (defaults to MAX_FILE_SIZE)
            
        Returns:
            An Attachment entity representing the uploaded file
            
        Raises:
            ValueError: If the file is too large or has an invalid type
        """
        # Validate file size
        file_data.seek(0, os.SEEK_END)
        file_size = file_data.tell()
        file_data.seek(0)  # Reset file pointer
        
        if max_size is None:
            max_size = self.MAX_FILE_SIZE
            
        if file_size > max_size:
            max_size_mb = max_size / (1024 * 1024)
            raise ValueError(f"File too large. Maximum size is {max_size_mb:.1f} MB")
        
        # Validate file extension
        _, ext = os.path.splitext(filename)
        if ext.startswith('.'):
            ext = ext[1:]
        
        if ext.lower() not in self.ALLOWED_EXTENSIONS:
            raise ValueError(f"File type not allowed: {ext}")
        
        # If content_type is not provided or doesn't match the extension,
        # use the one from our mapping
        expected_content_type = self.ALLOWED_EXTENSIONS.get(ext.lower())
        if not content_type or content_type != expected_content_type:
            content_type = expected_content_type
        
        # Upload the file
        return self.attachment_repository.save(
            file_data=file_data,
            filename=filename,
            content_type=content_type,
            user_id=user_id
        )
    
    def get_attachment(self, file_id: uuid.UUID) -> Optional[Attachment]:
        """
        Get an attachment by its ID.
        
        Args:
            file_id: ID of the attachment to retrieve
            
        Returns:
            An Attachment entity, or None if not found
        """
        return self.attachment_repository.get(file_id)
    
    def delete_attachment(self, file_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        """
        Delete an attachment.
        
        This method deletes an attachment if the user is the one who uploaded it.
        
        Args:
            file_id: ID of the attachment to delete
            user_id: ID of the user attempting to delete the attachment
            
        Returns:
            True if the attachment was deleted, False otherwise
            
        Raises:
            ValueError: If the user is not the one who uploaded the attachment
        """
        # Get the attachment to check ownership
        attachment = self.attachment_repository.get(file_id)
        if not attachment:
            return False
        
        # Check if the user is the owner
        if attachment.uploaded_by_id != user_id:
            raise ValueError("Only the user who uploaded the attachment can delete it")
        
        return self.attachment_repository.delete(file_id)
        
    def get_attachments_for_message(self, message_id: uuid.UUID) -> List[Attachment]:
        """
        Get all attachments for a specific message.
        
        Args:
            message_id: ID of the message
            
        Returns:
            List of Attachment entities
        """
        return self.attachment_repository.get_by_message(message_id)
    
    def associate_with_message(self, file_id: uuid.UUID, message_id: uuid.UUID) -> Optional[Attachment]:
        """
        Associate an attachment with a message.
        
        Args:
            file_id: ID of the attachment to associate
            message_id: ID of the message to associate with
            
        Returns:
            The updated Attachment entity, or None if the attachment was not found
        """
        return self.attachment_repository.associate_with_message(file_id, message_id)
    
    def is_valid_file_type(self, filename: str) -> bool:
        """
        Check if a file has an allowed extension.
        
        Args:
            filename: Name of the file to check
            
        Returns:
            True if the file extension is allowed, False otherwise
        """
        _, ext = os.path.splitext(filename)
        if ext.startswith('.'):
            ext = ext[1:]
        
        return ext.lower() in self.ALLOWED_EXTENSIONS
    
    def get_content_type(self, filename: str) -> Optional[str]:
        """
        Get the MIME type for a filename based on its extension.
        
        Args:
            filename: Name of the file
            
        Returns:
            MIME type if the extension is recognized, None otherwise
        """
        _, ext = os.path.splitext(filename)
        if ext.startswith('.'):
            ext = ext[1:]
        
        return self.ALLOWED_EXTENSIONS.get(ext.lower())
