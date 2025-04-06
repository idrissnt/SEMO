"""
Integration tests for the Conversation API views.

This module contains tests for the Conversation API endpoints.
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


class ConversationViewsTest(TestCase):
    """Integration tests for the Conversation API views."""

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
        self.conversations_url = reverse('conversation-list')
        
        # Mock service responses
        self.mock_conversation = Conversation(
            id=uuid.uuid4(),
            participants=[uuid.UUID(str(self.user1.id)), uuid.UUID(str(self.user2.id))],
            type="direct",
            title=None,
            created_at="2025-04-05T18:00:00Z",
            updated_at="2025-04-05T18:00:00Z",
            last_message_at=None,
            metadata={}
        )
        
        self.mock_message = Message(
            id=uuid.uuid4(),
            conversation_id=self.mock_conversation.id,
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
    def test_list_conversations(self, mock_message_service, mock_conversation_service):
        """Test listing conversations for the authenticated user."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_user_conversations.return_value = [self.mock_conversation]
        
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.get_unread_count.return_value = 5
        
        # Make the request
        response = self.client.get(self.conversations_url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['unread_count'], 5)
        
        # Verify the service calls
        mock_conversation_service_instance.get_user_conversations.assert_called_once_with(
            uuid.UUID(str(self.user1.id))
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    def test_create_conversation(self, mock_conversation_service):
        """Test creating a new conversation."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.create_conversation.return_value = self.mock_conversation
        
        # Prepare request data
        data = {
            'type': 'direct',
            'participants': [str(self.user2.id)]
        }
        
        # Make the request
        response = self.client.post(
            self.conversations_url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['type'], 'direct')
        
        # Verify the service calls
        mock_conversation_service_instance.create_conversation.assert_called_once()

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_retrieve_conversation(self, mock_message_service, mock_conversation_service):
        """Test retrieving a specific conversation."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation.return_value = self.mock_conversation
        
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.get_unread_count.return_value = 3
        
        # Make the request
        url = reverse('conversation-detail', args=[str(self.mock_conversation.id)])
        response = self.client.get(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], str(self.mock_conversation.id))
        self.assertEqual(response.data['unread_count'], 3)
        
        # Verify the service calls
        mock_conversation_service_instance.get_conversation.assert_called_once_with(
            self.mock_conversation.id
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_get_conversation_messages(self, mock_message_service, mock_conversation_service):
        """Test retrieving messages for a specific conversation."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_conversation.return_value = self.mock_conversation
        
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.get_conversation_messages.return_value = {
            "messages": [self.mock_message],
            "next_cursor": str(uuid.uuid4()),
            "has_more": False
        }
        
        # Make the request
        url = reverse('conversation-messages', args=[str(self.mock_conversation.id)])
        response = self.client.get(url)
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['messages']), 1)
        self.assertEqual(response.data['messages'][0]['id'], str(self.mock_message.id))
        self.assertFalse(response.data['has_more'])
        
        # Verify the service calls
        mock_conversation_service_instance.get_conversation.assert_called_once_with(
            self.mock_conversation.id
        )
        mock_message_service_instance.get_conversation_messages.assert_called_once()

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    @patch('messaging.infrastructure.factory.ServiceFactory.get_message_service')
    def test_get_direct_conversation(self, mock_message_service, mock_conversation_service):
        """Test getting or creating a direct conversation with another user."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        mock_conversation_service_instance.get_or_create_direct_conversation.return_value = self.mock_conversation
        
        mock_message_service_instance = MagicMock()
        mock_message_service.return_value = mock_message_service_instance
        mock_message_service_instance.get_unread_count.return_value = 0
        
        # Prepare request data
        data = {
            'user_id': str(self.user2.id)
        }
        
        # Make the request
        url = reverse('conversation-direct')
        response = self.client.post(
            url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], str(self.mock_conversation.id))
        self.assertEqual(response.data['type'], 'direct')
        
        # Verify the service calls
        mock_conversation_service_instance.get_or_create_direct_conversation.assert_called_once_with(
            user_id1=uuid.UUID(str(self.user1.id)),
            user_id2=uuid.UUID(str(self.user2.id))
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_task_conversation_service')
    def test_create_task_conversation(self, mock_task_conversation_service):
        """Test creating a conversation for a specific task."""
        # Configure mocks
        mock_task_conversation_service_instance = MagicMock()
        mock_task_conversation_service.return_value = mock_task_conversation_service_instance
        mock_task_conversation_service_instance.create_task_conversation.return_value = self.mock_conversation
        
        # Prepare request data
        task_id = uuid.uuid4()
        data = {
            'task_id': str(task_id),
            'requester_id': str(self.user1.id),
            'performer_id': str(self.user2.id),
            'task_title': 'Test Task'
        }
        
        # Make the request
        url = reverse('conversation-task')
        response = self.client.post(
            url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['id'], str(self.mock_conversation.id))
        
        # Verify the service calls
        mock_task_conversation_service_instance.create_task_conversation.assert_called_once_with(
            task_id=uuid.UUID(str(task_id)),
            requester_id=uuid.UUID(str(self.user1.id)),
            performer_id=uuid.UUID(str(self.user2.id)),
            task_title='Test Task'
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    def test_add_participant(self, mock_conversation_service):
        """Test adding a participant to a conversation."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        
        # Create a group conversation
        group_conversation = Conversation(
            id=uuid.uuid4(),
            participants=[uuid.UUID(str(self.user1.id)), uuid.UUID(str(self.user2.id))],
            type="group",
            title="Group Chat",
            created_at="2025-04-05T18:00:00Z",
            updated_at="2025-04-05T18:00:00Z",
            last_message_at=None,
            metadata={}
        )
        
        mock_conversation_service_instance.add_participant.return_value = group_conversation
        
        # Create a new user to add
        user3 = User.objects.create_user(
            username='user3',
            email='user3@example.com',
            password='password123'
        )
        
        # Prepare request data
        data = {
            'user_id': str(user3.id)
        }
        
        # Make the request
        url = reverse('conversation-add-participant', args=[str(group_conversation.id)])
        response = self.client.post(
            url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], str(group_conversation.id))
        
        # Verify the service calls
        mock_conversation_service_instance.add_participant.assert_called_once_with(
            conversation_id=group_conversation.id,
            user_id=uuid.UUID(str(user3.id)),
            added_by_id=uuid.UUID(str(self.user1.id))
        )

    @patch('messaging.infrastructure.factory.ServiceFactory.get_conversation_service')
    def test_update_title(self, mock_conversation_service):
        """Test updating the title of a conversation."""
        # Configure mocks
        mock_conversation_service_instance = MagicMock()
        mock_conversation_service.return_value = mock_conversation_service_instance
        
        # Create a group conversation
        group_conversation = Conversation(
            id=uuid.uuid4(),
            participants=[uuid.UUID(str(self.user1.id)), uuid.UUID(str(self.user2.id))],
            type="group",
            title="Updated Group Title",
            created_at="2025-04-05T18:00:00Z",
            updated_at="2025-04-05T19:00:00Z",
            last_message_at=None,
            metadata={}
        )
        
        mock_conversation_service_instance.update_conversation_title.return_value = group_conversation
        
        # Prepare request data
        data = {
            'title': 'Updated Group Title'
        }
        
        # Make the request
        url = reverse('conversation-update-title', args=[str(group_conversation.id)])
        response = self.client.post(
            url,
            data=json.dumps(data),
            content_type='application/json'
        )
        
        # Verify the response
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['title'], 'Updated Group Title')
        
        # Verify the service calls
        mock_conversation_service_instance.update_conversation_title.assert_called_once_with(
            conversation_id=group_conversation.id,
            title='Updated Group Title',
            user_id=uuid.UUID(str(self.user1.id))
        )
