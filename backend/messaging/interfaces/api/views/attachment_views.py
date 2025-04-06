"""
API views for attachment-related endpoints.

This module contains the API views for managing file attachments in the messaging system.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import ServiceFactory
from ..serializers import (
    AttachmentSerializer,
    AttachmentUploadSerializer
)


class AttachmentViewSet(viewsets.ViewSet):
    """
    ViewSet for attachment-related endpoints.
    
    This ViewSet provides endpoints for uploading, retrieving, and managing
    file attachments in the messaging system.
    """
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.attachment_service = ServiceFactory.get_attachment_service()
        self.message_service = ServiceFactory.get_message_service()
    
    def create(self, request):
        """
        Upload a file attachment.
        
        This endpoint uploads a file attachment and returns metadata about the file.
        The file can optionally be associated with a message.
        
        Endpoint: POST /api/messaging/attachments/
        
        Request body (multipart/form-data):
        - file: The file to upload
        - message_id: Optional, ID of the message to associate the attachment with
        """
        serializer = AttachmentUploadSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user_id = uuid.UUID(str(request.user.id))
            file_obj = serializer.validated_data["file"]
            message_id = serializer.validated_data.get("message_id")
            
            # If message_id is provided, verify the user is the sender of the message
            if message_id:
                message = self.message_service.get_message(message_id)
                if not message or message.sender_id != user_id:
                    return Response(
                        {"error": "Message not found or you are not the sender"},
                        status=status.HTTP_403_FORBIDDEN
                    )
            
            # Upload the file
            attachment = self.attachment_service.upload_attachment(
                file_data=file_obj,
                filename=file_obj.name,
                content_type=file_obj.content_type,
                user_id=user_id
            )
            
            # Serialize the attachment
            serializer = AttachmentSerializer(attachment)
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def retrieve(self, request, pk=None):
        """
        Retrieve attachment metadata.
        
        This endpoint returns metadata about a specific file attachment.
        
        Endpoint: GET /api/messaging/attachments/{id}/
        """
        try:
            file_id = uuid.UUID(pk)
            
            # Get the attachment
            attachment = self.attachment_service.get_attachment(file_id)
            
            if not attachment:
                return Response(
                    {"error": "Attachment not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the attachment
            serializer = AttachmentSerializer(attachment)
            
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid attachment ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["delete"])
    def delete(self, request, pk=None):
        """
        Delete an attachment.
        
        This endpoint deletes a specific file attachment. Only the user who
        uploaded the attachment can delete it.
        
        Endpoint: DELETE /api/messaging/attachments/{id}/delete/
        """
        try:
            file_id = uuid.UUID(pk)
            user_id = uuid.UUID(str(request.user.id))
            
            # Delete the attachment
            deleted = self.attachment_service.delete_attachment(
                file_id=file_id,
                user_id=user_id
            )
            
            if not deleted:
                return Response(
                    {"error": "Attachment not found or you are not the owner"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            return Response(status=status.HTTP_204_NO_CONTENT)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
