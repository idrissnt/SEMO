from abc import ABC, abstractmethod
from typing import Optional, Tuple, BinaryIO


class FileStorageService(ABC):
    """Domain service interface for file storage operations"""
    
    @abstractmethod
    def upload_file(self, file_data: BinaryIO, file_name: str, content_type: str) -> str:
        """Upload a file to storage and return its URL
        
        Args:
            file_data: File-like object containing the file data
            file_name: Name of the file
            content_type: MIME type of the file
            
        Returns:
            URL of the uploaded file
        """
        pass
    
    @abstractmethod
    def delete_file(self, file_url: str) -> bool:
        """Delete a file from storage
        
        Args:
            file_url: URL of the file to delete
            
        Returns:
            True if deletion was successful, False otherwise
        """
        pass
    
    @abstractmethod
    def generate_presigned_url(self, file_name: str, content_type: str, 
                              expiration: int = 3600) -> Tuple[str, dict]:
        """Generate a presigned URL for direct client-side uploads
        
        Args:
            file_name: Name of the file to be uploaded
            content_type: MIME type of the file
            expiration: Expiration time in seconds
            
        Returns:
            Tuple of (presigned_url, form_data) where form_data contains any additional
            fields needed for the upload
        """
        pass
