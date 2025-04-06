"""
Serializers for attachment-related API endpoints.

This module contains serializers for handling file attachments in the API.
"""
from rest_framework import serializers
import uuid

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
            
        # If the instance is an Attachment entity, convert it to a dictionary
        if isinstance(instance, Attachment):
            return {
                'id': str(instance.id),
                'filename': instance.filename,
                'file_path': instance.file_path,
                'file_size': instance.file_size,
                'content_type': instance.content_type,
                'uploaded_by_id': str(instance.uploaded_by_id),
                'uploaded_at': instance.uploaded_at.isoformat() if instance.uploaded_at else None,
                'message_id': str(instance.message_id) if instance.message_id else None,
                'metadata': instance.metadata or {},
                # Add a URL field for client convenience
                'file_url': f"/media/{instance.file_path}" if instance.file_path else None
            }
            
        # If we got here, we don't know how to handle this type
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
