"""
Tests for the WebSocket consumers.

This module contains tests for the WebSocket consumers that handle
real-time messaging functionality.
"""
import json
import uuid
from unittest.mock import patch, MagicMock, AsyncMock
from channels.testing import WebsocketCommunicator
from channels.db import database_sync_to_async
from django.test import TransactionTestCase
from django.contrib.auth import get_user_model
from django.urls import re_path

from messaging.infrastructure.websocket.consumers import ChatConsumer
from messaging.infrastructure.websocket.auth import JWTAuthMiddleware
from messaging.domain.models.entities.message import Message
from messaging.domain.models.entities.conversation import Conversation


User = get_user_model()


# Test-specific routing for the WebSocket communicator
websocket_urlpatterns = [
    re_path(r"ws/messaging/conversations/(?P<conversation_id>[^/]+)/$", ChatConsumer.as_asgi()),
]


class TestChatConsumer(TransactionTestCase):
    """Test cases for the ChatConsumer."""

    async def setUp(self):
        """Set up test fixtures."""
        # Create test users
        self.user1 = await database_sync_to_async(User.objects.create_user)(
            username='user1',
            email='user1@example.com',
            password='password123'
        )
        self.user2 = await database_sync_to_async(User.objects.create_user)(
            username='user2',
            email='user2@example.com',
            password='password123'
        )
        
        # Create test data
        self.conversation_id = uuid.uuid4()
        self.message_id = uuid.uuid4()
        
        # Create a mock conversation
        self.conversation = Conversation(
            id=self.conversation_id,
            participants=[uuid.UUID(str(self.user1.id)), uuid.UUID(str(self.user2.id))],
            type="direct",
            title=None,
            created_at="2025-04-05T18:00:00Z",
            updated_at="2025-04-05T18:00:00Z",
            last_message_at=None,
            metadata={}
        )
        
        # Create a mock message
        self.message = Message(
            id=self.message_id,
            conversation_id=self.conversation_id,
            sender_id=uuid.UUID(str(self.user1.id)),
            content="Hello, world!",
            content_type="text",
            sent_at="2025-04-05T18:05:00Z",
            delivered_at=None,
            read_by=[],
            metadata={}
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    async def test_connect(self, mock_message_service, mock_conversation_service):
        """Test connecting to the WebSocket."""
        # Configure mocks
        mock_conversation_service_instance = AsyncMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation = AsyncMock(return_value=self.conversation)
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(re_path(r"^ws/messaging/conversations/(?P<conversation_id>[^/]+)/$", ChatConsumer.as_asgi()))
        
        # Create communicator with auth user in scope
        communicator = WebsocketCommunicator(
            application,
            f"ws/messaging/conversations/{self.conversation_id}/",
        )
        communicator.scope["user"] = self.user1
        
        # Connect
        connected, _ = await communicator.connect()
        
        # Verify connection was successful
        self.assertTrue(connected)
        
        # Disconnect
        await communicator.disconnect()

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    async def test_receive_message(self, mock_message_service, mock_conversation_service):
        """Test receiving a message from the WebSocket."""
        # Configure mocks
        mock_conversation_service_instance = AsyncMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation = AsyncMock(return_value=self.conversation)
        
        mock_message_service_instance = AsyncMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.send_message = AsyncMock(return_value=self.message)
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(re_path(r"^ws/messaging/conversations/(?P<conversation_id>[^/]+)/$", ChatConsumer.as_asgi()))
        
        # Create communicator with auth user in scope
        communicator = WebsocketCommunicator(
            application,
            f"ws/messaging/conversations/{self.conversation_id}/",
        )
        communicator.scope["user"] = self.user1
        
        # Connect
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        
        # Send a message
        message_data = {
            "type": "message.send",
            "content": "Hello, world!",
            "content_type": "text",
            "metadata": {"importance": "high"}
        }
        await communicator.send_json_to(message_data)
        
        # Receive response
        response = await communicator.receive_json_from()
        
        # Verify response
        self.assertEqual(response["type"], "message.created")
        self.assertEqual(response["message"]["content"], "Hello, world!")
        self.assertEqual(response["message"]["sender_id"], str(self.user1.id))
        
        # Verify service call
        mock_message_service_instance.send_message.assert_called_once_with(
            conversation_id=uuid.UUID(str(self.conversation_id)),
            sender_id=uuid.UUID(str(self.user1.id)),
            content="Hello, world!",
            content_type="text",
            metadata={"importance": "high"}
        )
        
        # Disconnect
        await communicator.disconnect()

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    async def test_mark_as_read(self, mock_message_service, mock_conversation_service):
        """Test marking messages as read via WebSocket."""
        # Configure mocks
        mock_conversation_service_instance = AsyncMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation = AsyncMock(return_value=self.conversation)
        
        mock_message_service_instance = AsyncMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.mark_as_read = AsyncMock(return_value=1)
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(re_path(r"^ws/messaging/conversations/(?P<conversation_id>[^/]+)/$", ChatConsumer.as_asgi()))
        
        # Create communicator with auth user in scope
        communicator = WebsocketCommunicator(
            application,
            f"ws/messaging/conversations/{self.conversation_id}/",
        )
        communicator.scope["user"] = self.user1
        
        # Connect
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        
        # Send a mark as read command
        read_data = {
            "type": "message.read",
            "message_ids": [str(self.message_id)]
        }
        await communicator.send_json_to(read_data)
        
        # Receive response
        response = await communicator.receive_json_from()
        
        # Verify response
        self.assertEqual(response["type"], "message.read")
        self.assertEqual(response["updated"], 1)
        
        # Verify service call
        mock_message_service_instance.mark_as_read.assert_called_once_with(
            message_ids=[uuid.UUID(str(self.message_id))],
            user_id=uuid.UUID(str(self.user1.id))
        )
        
        # Disconnect
        await communicator.disconnect()

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    async def test_typing_indicator(self, mock_conversation_service):
        """Test sending typing indicators via WebSocket."""
        # Configure mocks
        mock_conversation_service_instance = AsyncMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation = AsyncMock(return_value=self.conversation)
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(re_path(r"^ws/messaging/conversations/(?P<conversation_id>[^/]+)/$", ChatConsumer.as_asgi()))
        
        # Create communicator with auth user in scope
        communicator = WebsocketCommunicator(
            application,
            f"ws/messaging/conversations/{self.conversation_id}/",
        )
        communicator.scope["user"] = self.user1
        
        # Connect
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        
        # Send a typing start indicator
        typing_data = {
            "type": "typing.start"
        }
        await communicator.send_json_to(typing_data)
        
        # Receive response
        response = await communicator.receive_json_from()
        
        # Verify response
        self.assertEqual(response["type"], "typing.indicator")
        self.assertEqual(response["user_id"], str(self.user1.id))
        self.assertTrue(response["is_typing"])
        
        # Send a typing stop indicator
        typing_data = {
            "type": "typing.stop"
        }
        await communicator.send_json_to(typing_data)
        
        # Receive response
        response = await communicator.receive_json_from()
        
        # Verify response
        self.assertEqual(response["type"], "typing.indicator")
        self.assertEqual(response["user_id"], str(self.user1.id))
        self.assertFalse(response["is_typing"])
        
        # Disconnect
        await communicator.disconnect()

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    async def test_disconnect(self, mock_conversation_service):
        """Test disconnecting from the WebSocket."""
        # Configure mocks
        mock_conversation_service_instance = AsyncMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation = AsyncMock(return_value=self.conversation)
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(re_path(r"^ws/messaging/conversations/(?P<conversation_id>[^/]+)/$", ChatConsumer.as_asgi()))
        
        # Create communicator with auth user in scope
        communicator = WebsocketCommunicator(
            application,
            f"ws/messaging/conversations/{self.conversation_id}/",
        )
        communicator.scope["user"] = self.user1
        
        # Connect
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        
        # Disconnect
        await communicator.disconnect()
        
        # No need to verify anything here, just making sure it doesn't raise exceptions
