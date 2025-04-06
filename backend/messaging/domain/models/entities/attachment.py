"""
Attachment entity.

This module defines the Attachment entity, which represents a file attachment
in the messaging system.
"""
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Dict, Any, Optional


@dataclass(frozen=True)
class Attachment:
    """
    Represents a file attachment in the messaging system.
    
    An attachment is a file that can be associated with a message, such as
    an image, document, or other media.
    """
    id: uuid.UUID
    filename: str
    content_type: str
    file_path: str
    file_size: int
    uploaded_by_id: uuid.UUID
    uploaded_at: datetime
    message_id: Optional[uuid.UUID] = None
    metadata: Dict[str, Any] = None
    
    @classmethod
    def create(cls, filename: str, content_type: str, file_path: str, 
               file_size: int, uploaded_by_id: uuid.UUID, 
               message_id: Optional[uuid.UUID] = None,
               metadata: Dict[str, Any] = None) -> 'Attachment':
        """
        Create a new attachment.
        
        Args:
            filename: The original filename of the attachment
            content_type: The MIME type of the file
            file_path: The path where the file is stored
            file_size: The size of the file in bytes
            uploaded_by_id: The ID of the user who uploaded the file
            message_id: Optional ID of the message this attachment belongs to
            metadata: Optional additional metadata for the attachment
            
        Returns:
            A new Attachment instance
        """
        return cls(
            id=uuid.uuid4(),
            filename=filename,
            content_type=content_type,
            file_path=file_path,
            file_size=file_size,
            uploaded_by_id=uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=message_id,
            metadata=metadata or {}
        )
    
    def associate_with_message(self, message_id: uuid.UUID) -> 'Attachment':
        """
        Associate this attachment with a message.
        
        Args:
            message_id: The ID of the message to associate with
            
        Returns:
            A new Attachment instance with the message association
        """
        return Attachment(
            id=self.id,
            filename=self.filename,
            content_type=self.content_type,
            file_path=self.file_path,
            file_size=self.file_size,
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=self.uploaded_at,
            message_id=message_id,
            metadata=self.metadata
        )
    
    def update_metadata(self, metadata: Dict[str, Any]) -> 'Attachment':
        """
        Update the metadata of this attachment.
        
        Args:
            metadata: The new metadata
            
        Returns:
            A new Attachment instance with updated metadata
        """
        return Attachment(
            id=self.id,
            filename=self.filename,
            content_type=self.content_type,
            file_path=self.file_path,
            file_size=self.file_size,
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=self.uploaded_at,
            message_id=self.message_id,
            metadata=metadata
        )
    
    def is_image(self) -> bool:
        """
        Check if this attachment is an image.
        
        Returns:
            True if the attachment is an image, False otherwise
        """
        return self.content_type.startswith('image/')
    
    def is_document(self) -> bool:
        """
        Check if this attachment is a document.
        
        Returns:
            True if the attachment is a document, False otherwise
        """
        document_types = [
            'application/pdf',
        ]
        return self.content_type in document_types
    
    def get_extension(self) -> str:
        """
        Get the file extension of this attachment.
        
        Returns:
            The file extension (without the dot)
        """
        if '.' in self.filename:
            return self.filename.split('.')[-1].lower()
        return ""
