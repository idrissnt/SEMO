"""
API views for message-related endpoints.

This module contains the API views for managing messages in the messaging system.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import ServiceFactory
from ..serializers import (
    MessageSerializer,
    MessageCreateSerializer,
    MessageReadReceiptSerializer
)


class MessageViewSet(viewsets.ViewSet):
    """
    ViewSet for message-related endpoints.
    
    This ViewSet provides endpoints for creating, retrieving, and managing
    messages in the messaging system.
    """
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.message_service = ServiceFactory.get_message_service()
        self.conversation_service = ServiceFactory.get_conversation_service()
    
    def create(self, request):
        """
        Send a new message.
        
        This endpoint creates a new message in a conversation. The authenticated
        user must be a participant in the conversation.
        
        Endpoint: POST /api/messaging/messages/
        
        Request body:
        {
            "conversation_id": "conversation-id",
            "content": "Message content",
            "content_type": "text",  // optional, defaults to "text"
            "metadata": {}  // optional additional data
        }
        """
        serializer = MessageCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user_id = uuid.UUID(str(request.user.id))
            conversation_id = serializer.validated_data["conversation_id"]
            
            # Verify the user is a participant in the conversation
            conversation = self.conversation_service.get_conversation(conversation_id)
            if not conversation or user_id not in conversation.participants:
                return Response(
                    {"error": "Conversation not found or you are not a participant"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Create the message
            message = self.message_service.send_message(
                conversation_id=conversation_id,
                sender_id=user_id,
                content=serializer.validated_data["content"],
                content_type=serializer.validated_data.get("content_type", "text"),
                metadata=serializer.validated_data.get("metadata", {})
            )
            
            # Serialize the message
            response_serializer = MessageSerializer(message)
            
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def retrieve(self, request, pk=None):
        """
        Retrieve a specific message.
        
        This endpoint returns details about a specific message. The authenticated
        user must be a participant in the conversation that contains the message.
        
        Endpoint: GET /api/messaging/messages/{id}/
        """
        try:
            message_id = uuid.UUID(pk)
            user_id = uuid.UUID(str(request.user.id))
            
            # Get the message
            message = self.message_service.get_message(message_id)
            
            # Check if the message exists
            if not message:
                return Response(
                    {"error": "Message not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Verify the user is a participant in the conversation
            conversation = self.conversation_service.get_conversation(message.conversation_id)
            if not conversation or user_id not in conversation.participants:
                return Response(
                    {"error": "You are not authorized to view this message"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Serialize the message
            serializer = MessageSerializer(message)
            
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid message ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["post"])
    def mark_as_read(self, request):
        """
        Mark messages as read.
        
        This endpoint marks one or more messages as read by the authenticated user.
        The user must be a participant in the conversations that contain the messages.
        
        Endpoint: POST /api/messaging/messages/mark_as_read/
        
        Request body:
        {
            "message_ids": ["message-id-1", "message-id-2", ...]
        }
        """
        serializer = MessageReadReceiptSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user_id = uuid.UUID(str(request.user.id))
            message_ids = [uuid.UUID(str(mid)) for mid in serializer.validated_data["message_ids"]]
            
            # Mark the messages as read
            updated = self.message_service.mark_as_read(
                message_ids=message_ids,
                user_id=user_id
            )
            
            return Response({"updated": updated})
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"])
    def unread_count(self, request):
        """
        Get the count of unread messages.
        
        This endpoint returns the count of unread messages for the authenticated user,
        optionally filtered by conversation.
        
        Endpoint: GET /api/messaging/messages/unread_count/
        
        Query parameters:
        - conversation_id: Optional, if provided, only count unread messages in this conversation
        """
        try:
            user_id = uuid.UUID(str(request.user.id))
            conversation_id = request.query_params.get("conversation_id")
            conversation_uuid = uuid.UUID(conversation_id) if conversation_id else None
            
            # Get the unread count
            count = self.message_service.get_unread_count(
                user_id=user_id,
                conversation_id=conversation_uuid
            )
            
            return Response({"count": count})
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["delete"])
    def delete(self, request, pk=None):
        """
        Delete a message.
        
        This endpoint deletes a specific message. Only the sender of the message
        can delete it.
        
        Endpoint: DELETE /api/messaging/messages/{id}/delete/
        """
        try:
            message_id = uuid.UUID(pk)
            user_id = uuid.UUID(str(request.user.id))
            
            # Delete the message
            deleted = self.message_service.delete_message(
                message_id=message_id,
                user_id=user_id
            )
            
            if not deleted:
                return Response(
                    {"error": "Message not found or you are not the sender"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            return Response(status=status.HTTP_204_NO_CONTENT)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
