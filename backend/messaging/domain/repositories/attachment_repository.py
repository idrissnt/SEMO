"""
Attachment repository interface.

This module defines the interface for accessing and manipulating message attachments.
Following the repository pattern, this interface abstracts the data access logic
from the business logic.
"""
from abc import ABC, abstractmethod
from typing import Optional, BinaryIO, Dict, Any, List
import uuid

from ..models import Attachment


class AttachmentRepository(ABC):
    """
    Interface for storing and retrieving message attachments.
    
    This repository handles the storage and retrieval of files attached to messages,
    such as images, documents, and other media.
    """
    
    @abstractmethod
    def save(self, file_data: BinaryIO, filename: str, 
            content_type: str, user_id: uuid.UUID) -> Attachment:
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
        pass
    
    @abstractmethod
    def get(self, file_id: uuid.UUID) -> Optional[Attachment]:
        """
        Get an attachment by its ID.
        
        Args:
            file_id: ID of the attachment to retrieve
            
        Returns:
            An Attachment entity, or None if not found
        """
        pass
    
    @abstractmethod
    def delete(self, file_id: uuid.UUID) -> bool:
        """
        Delete an attachment.
        
        Args:
            file_id: ID of the attachment to delete
            
        Returns:
            True if the attachment was deleted, False otherwise
        """
        pass
        
    @abstractmethod
    def get_by_message(self, message_id: uuid.UUID) -> List[Attachment]:
        """
        Get all attachments for a specific message.
        
        Args:
            message_id: The ID of the message
            
        Returns:
            A list of Attachment entities
        """
        pass
        
    @abstractmethod
    def associate_with_message(self, file_id: uuid.UUID, message_id: uuid.UUID) -> Optional[Attachment]:
        """
        Associate an attachment with a message.
        
        Args:
            file_id: The ID of the attachment
            message_id: The ID of the message
            
        Returns:
            The updated Attachment entity, or None if the attachment was not found
        """
        pass
