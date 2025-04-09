"""
Serializers for attachment-related API endpoints.

This module contains serializers for handling file attachments in the API.
"""
from rest_framework import serializers

from ....domain.models.entities.attachment import Attachment


class AttachmentSerializer(serializers.Serializer):
    """
    Serializer for file attachments.
    
    This serializer handles file attachment metadata for API responses.
    """
    id = serializers.UUIDField(read_only=True)
    filename = serializers.CharField(read_only=True)
    file_path = serializers.CharField(read_only=True)
    file_size = serializers.IntegerField(read_only=True)
    content_type = serializers.CharField(read_only=True)
    uploaded_by_id = serializers.UUIDField(read_only=True)
    uploaded_at = serializers.DateTimeField(read_only=True)
    message_id = serializers.UUIDField(read_only=True, allow_null=True)
    metadata = serializers.DictField(read_only=True)
    
    def to_representation(self, instance):
        """
        Convert an Attachment entity to an API representation.
        
        This method is called when serializing an Attachment entity to an
        API representation.
        
        Args:
            instance: Attachment entity or dictionary
            
        Returns:
            Dictionary representation of the attachment
        """
        # If the instance is already a dictionary, return it as is
        if isinstance(instance, dict):
            return instance
            
        # If the instance is a Pydantic model, use its model_dump method
        if hasattr(instance, 'model_dump'):
            # Start with the base model data
            result = instance.model_dump()
            # Convert UUIDs to strings for JSON serialization
            result['id'] = str(result['id'])
            result['uploaded_by_id'] = str(result['uploaded_by_id'])
            if result['message_id']:
                result['message_id'] = str(result['message_id'])
            # Format datetime objects
            if result['uploaded_at']:
                result['uploaded_at'] = result['uploaded_at'].isoformat()
            # Add a URL field for client convenience
            result['file_url'] = f"/media/{result['file_path']}" if result['file_path'] else None
            # Ensure metadata is not None
            result['metadata'] = result['metadata'] or {}
            return result
        
        # Fallback to standard serialization
        return super().to_representation(instance)


class AttachmentUploadSerializer(serializers.Serializer):
    """
    Serializer for file upload requests.
    
    This serializer validates file upload requests and handles the file data.
    """
    file = serializers.FileField()
    message_id = serializers.UUIDField(required=False, allow_null=True)
    
    def validate_file(self, value):
        """
        Validate the uploaded file.
        
        This method performs additional validation on the uploaded file,
        such as checking the file size and type.
        
        Args:
            value: The uploaded file
            
        Returns:
            The validated file
            
        Raises:
            ValidationError: If the file is invalid
        """
        # Check file size (10 MB limit)
        if value.size > 10 * 1024 * 1024:
            raise serializers.ValidationError(
                "File too large. Maximum size is 10 MB."
            )
        
        # Get file extension
        name = value.name.lower()
        ext = name.split('.')[-1] if '.' in name else ''
        
        # Check file type (this is a simple check, the service does more thorough validation)
        allowed_extensions = {
            'jpg', 'jpeg', 'png', 'gif', 'webp',  # Images
            'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt',  # Documents
            'mp3', 'wav', 'ogg',  # Audio
            'mp4', 'webm', 'avi'  # Video
        }
        
        if ext not in allowed_extensions:
            raise serializers.ValidationError(
                f"File type not allowed: {ext}"
            )
        
        return value
