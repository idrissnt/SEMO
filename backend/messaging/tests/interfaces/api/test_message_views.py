"""
Integration tests for the Message API views.

This module contains tests for the Message API endpoints.
"""
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
import uuid
import json
from unittest.mock import patch, MagicMock

from django.contrib.auth import get_user_model
from messaging.domain.models.entities.conversation import Conversation
from messaging.domain.models.entities.message import Message


User = get_user_model()


class MessageViewsTest(TestCase):
    """Integration tests for the Message API views."""

    def setUp(self):
        """Set up test fixtures."""
        # Create test users
        self.user1 = User.objects.create_user(
            username='user1',
            email='user1@example.com',
            password='password123'
        )
        self.user2 = User.objects.create_user(
            username='user2',
            email='user2@example.com',
            password='password123'
        )
        
        # Set up API client
        self.client = APIClient()
        self.client.force_authenticate(user=self.user1)
        
        # URLs
        self.messages_url = reverse('message-list')
        
        # Mock data
        self.conversation_id = uuid.uuid4()
        self.message_id = uuid.uuid4()
        
        # Mock conversation
        self.mock_conversation = Conversation(
            id=self.conversation_id,
            participants=[uuid.UUID(str(self.user1.id)), uuid.UUID(str(self.user2.id))],
            type="direct",
            title=None,
            created_at="2025-04-05T18:00:00Z",
            updated_at="2025-04-05T18:00:00Z",
            last_message_at=None,
            metadata={}
        )
        
        # Mock message
        self.mock_message = Message(
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
    def test_create_message(self, mock_message_service, mock_conversation_service):
        """Test creating a new message."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation.return_value = self.mock_conversation
        
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.send_message.return_value = self.mock_message
        
        # Prepare request data
        data = {
            'conversation_id': str(self.conversation_id),
            'content': 'Hello, world!',
            'content_type': 'text',
            'metadata': {'importance': 'high'}
        }
        
        # Make the request
        response = self.client.post(
            self.messages_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['id'], str(self.message_id))
        self.assertEqual(response.data['content'], 'Hello, world!')
        
        # Verify the service calls
        mock_conversation_service_instance.get_conversation.assert_called_once_with(
            self.conversation_id
        )
        mock_message_service_instance.send_message.assert_called_once_with(
            conversation_id=self.conversation_id,
            sender_id=uuid.UUID(str(self.user1.id)),
            content='Hello, world!',
            content_type='text',
            metadata={'importance': 'high'}
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_retrieve_message(self, mock_message_service, mock_conversation_service):
        """Test retrieving a specific message."""
        # Configure mocks
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.get_message.return_value = self.mock_message
        
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation.return_value = self.mock_conversation
        
        # Make the request
        url = reverse('message-detail', args=[str(self.message_id)])
        response = self.client.get(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], str(self.message_id))
        self.assertEqual(response.data['content'], 'Hello, world!')
        
        # Verify the service calls
        mock_message_service_instance.get_message.assert_called_once_with(
            self.message_id
        )
        mock_conversation_service_instance.get_conversation.assert_called_once_with(
            self.conversation_id
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_mark_as_read(self, mock_message_service):
        """Test marking messages as read."""
        # Configure mocks
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.mark_as_read.return_value = 2
        
        # Prepare request data
        message_ids = [str(uuid.uuid4()), str(uuid.uuid4())]
        data = {
            'message_ids': message_ids
        }
        
        # Make the request
        url = reverse('message-mark-as-read')
        response = self.client.post(
            url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['updated'], 2)
        
        # Verify the service calls
        mock_message_service_instance.mark_as_read.assert_called_once()
        # Check that the UUIDs were converted correctly
        call_args = mock_message_service_instance.mark_as_read.call_args[1]
        self.assertEqual(len(call_args['message_ids']), 2)
        for message_id in call_args['message_ids']:
            self.assertIsInstance(message_id, uuid.UUID)

    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_unread_count(self, mock_message_service):
        """Test getting the count of unread messages."""
        # Configure mocks
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.get_unread_count.return_value = 5
        
        # Make the request
        url = reverse('message-unread-count')
        response = self.client.get(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 5)
        
        # Verify the service calls
        mock_message_service_instance.get_unread_count.assert_called_once_with(
            user_id=uuid.UUID(str(self.user1.id)),
            conversation_id=None
        )
        
        # Test with conversation_id parameter
        url = f"{url}?conversation_id={self.conversation_id}"
        mock_message_service_instance.get_unread_count.return_value = 3
        response = self.client.get(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 3)
        
        # Verify the service calls
        mock_message_service_instance.get_unread_count.assert_called_with(
            user_id=uuid.UUID(str(self.user1.id)),
            conversation_id=self.conversation_id
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_delete_message(self, mock_message_service):
        """Test deleting a message."""
        # Configure mocks
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.delete_message.return_value = True
        
        # Make the request
        url = reverse('message-delete', args=[str(self.message_id)])
        response = self.client.delete(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        
        # Verify the service calls
        mock_message_service_instance.delete_message.assert_called_once_with(
            message_id=self.message_id,
            user_id=uuid.UUID(str(self.user1.id))
        )
        
        # Test deleting a message that doesn't exist or user is not the sender
        mock_message_service_instance.delete_message.return_value = False
        response = self.client.delete(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
