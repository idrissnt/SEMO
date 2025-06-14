"""
API views for conversation-related endpoints.

This module contains the API views for managing conversations in the messaging system.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import ServiceFactory
from ..serializers import (
    ConversationSerializer,
    TaskConversationCreateSerializer,
    MessageSerializer
)


class ConversationViewSet(viewsets.ViewSet):
    """
    ViewSet for conversation-related endpoints.
    
    This ViewSet provides endpoints for creating, retrieving, and managing
    conversations in the messaging system.
    """
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.conversation_service = ServiceFactory.get_conversation_service()
        self.message_service = ServiceFactory.get_message_service()
        self.task_conversation_service = ServiceFactory.get_task_conversation_service()
    
    def list(self, request):
        """
        List conversations for the authenticated user.
        
        This endpoint returns a list of all conversations that the authenticated
        user is participating in, ordered by last_message_at (newest first).
        
        Endpoint: GET /api/messaging/conversations/
        """
        try:
            user_id = uuid.UUID(str(request.user.id))
            
            # Get conversations for the user
            conversations = self.conversation_service.get_user_conversations(user_id)
            
            # Add unread count for each conversation
            for conversation in conversations:
                # Add unread count as an attribute
                conversation.unread_count = 0  # Default to 0 since get_unread_count is commented out
                # Uncomment when get_unread_count is implemented
                # conversation.unread_count = self.message_service.get_unread_count(
                #     user_id=user_id,
                #     conversation_id=conversation.id
                # )
            
            # Serialize the conversations
            serializer = ConversationSerializer(conversations, many=True)
            
            return Response(serializer.data)
        except ValueError as e:
            return Response(
                {"error": f"Invalid UUID format: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def retrieve(self, request, pk=None):
        """
        Retrieve a specific conversation.
        
        This endpoint returns details about a specific conversation.
        The user must be a participant in the conversation.
        
        Endpoint: GET /api/messaging/conversations/{id}/
        """
        try:
            conversation_id = uuid.UUID(pk)
            user_id = uuid.UUID(str(request.user.id))
            
            # Get the conversation
            conversation = self.conversation_service.get_conversation(conversation_id)
            
            # Check if the conversation exists and the user is a participant
            if not conversation or user_id not in conversation.participants:
                return Response(
                    {"error": "Conversation not found or you are not a participant"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Add unread count as an attribute
            conversation.unread_count = self.message_service.get_unread_count(
                user_id=user_id,
                conversation_id=conversation.id
            )
            
            # Serialize the conversation
            serializer = ConversationSerializer(conversation)
            
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid conversation ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["get"])
    def messages(self, request, pk=None):
        """
        Retrieve messages for a specific conversation.
        
        This endpoint returns messages for a specific conversation with
        cursor-based pagination. The user must be a participant in the conversation.
        
        Endpoint: GET /api/messaging/conversations/{id}/messages/
        
        Query parameters:
        - limit: Maximum number of messages to return (default: 50, max: 100)
        - before_id: Only return messages sent before this message ID (for pagination)
        """
        try:
            conversation_id = uuid.UUID(pk)
            user_id = uuid.UUID(str(request.user.id))
            
            # Get the conversation
            conversation = self.conversation_service.get_conversation(conversation_id)
            
            # Check if the conversation exists and the user is a participant
            if not conversation or user_id not in conversation.participants:
                return Response(
                    {"error": "Conversation not found or you are not a participant"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get pagination parameters
            limit = min(int(request.query_params.get("limit", 50)), 100)
            before_id = request.query_params.get("before_id")
            before_uuid = uuid.UUID(str(before_id)) if before_id else None
            
            # Get messages for the conversation
            result = self.message_service.get_conversation_messages(
                conversation_id=conversation_id,
                limit=limit,
                before_message_id=before_uuid
            )
            
            # Serialize the messages
            serializer = MessageSerializer(result["messages"], many=True)
            
            # Return the messages with pagination info
            return Response({
                "messages": serializer.data,
                "next_cursor": result["next_cursor"],
                "has_more": result["has_more"]
            })
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["post"])
    def task(self, request):
        """
        Create a conversation for a specific task.
        
        This endpoint creates a conversation specifically for a task, including
        both the task requester and performer as participants.
        
        Endpoint: POST /api/messaging/conversations/task/
        
        Request body:
        {
            "task_id": "task-id",
            "requester_id": "requester-id",
            "performer_id": "performer-id",
            "task_title": "Optional task title"
        }
        """
        serializer = TaskConversationCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Create the task conversation
            conversation = self.task_conversation_service.create_task_conversation(
                task_id=serializer.validated_data["task_id"],
                requester_id=serializer.validated_data["requester_id"],
                performer_id=serializer.validated_data["performer_id"],
                task_title=serializer.validated_data.get("task_title")
            )
            
            # Serialize the conversation
            response_serializer = ConversationSerializer(conversation)
            
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
