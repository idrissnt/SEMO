"""
Tests for the Django implementation of the MessageRepository.

This module contains tests for the DjangoMessageRepository class.
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
import uuid
from datetime import datetime, timezone

from messaging.domain.models.entities.message import Message
from messaging.infrastructure.django_models.message_model import MessageModel
from messaging.infrastructure.django_models.conversation_model import ConversationModel
from messaging.infrastructure.repositories.django_message_repository import DjangoMessageRepository


User = get_user_model()


class TestDjangoMessageRepository(TestCase):
    """Test cases for the DjangoMessageRepository."""

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
        
        # Create a test conversation
        self.conversation = ConversationModel.objects.create(
            type="direct",
            title=None,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        self.conversation.participants.add(self.user1, self.user2)
        
        # Create the repository
        self.repository = DjangoMessageRepository()
        
        # Create test data
        self.message_data = {
            'id': uuid.uuid4(),
            'conversation_id': self.conversation.id,
            'sender_id': self.user1.id,
            'content': 'Test message',
            'content_type': 'text',
            'sent_at': datetime.now(timezone.utc),
            'delivered_at': None,
            'read_by': [],
            'metadata': {'importance': 'high'}
        }
        
        # Create a domain entity
        self.message = Message(**self.message_data)

    def test_save_new_message(self):
        """Test saving a new message."""
        # Save the message
        saved_message = self.repository.save(self.message)
        
        # Verify the message was saved to the database
        self.assertTrue(MessageModel.objects.filter(id=self.message.id).exists())
        
        # Verify the returned object is a domain entity
        self.assertIsInstance(saved_message, Message)
        self.assertEqual(saved_message.id, self.message.id)
        self.assertEqual(saved_message.content, self.message.content)

    def test_save_existing_message(self):
        """Test updating an existing message."""
        # Create a message in the database
        MessageModel.objects.create(
            id=self.message.id,
            conversation=self.conversation,
            sender=self.user1,
            content='Original content',
            content_type='text',
            sent_at=self.message.sent_at
        )
        
        # Update the message
        updated_message = self.message
        self.repository.save(updated_message)
        
        # Verify the message was updated
        db_message = MessageModel.objects.get(id=self.message.id)
        self.assertEqual(db_message.content, 'Test message')

    def test_get_by_id(self):
        """Test retrieving a message by ID."""
        # Create a message in the database
        message_model = MessageModel.objects.create(
            id=self.message.id,
            conversation=self.conversation,
            sender=self.user1,
            content=self.message.content,
            content_type=self.message.content_type,
            sent_at=self.message.sent_at,
            metadata=self.message.metadata
        )
        
        # Retrieve the message
        retrieved_message = self.repository.get_by_id(self.message.id)
        
        # Verify the retrieved message
        self.assertIsInstance(retrieved_message, Message)
        self.assertEqual(retrieved_message.id, self.message.id)
        self.assertEqual(retrieved_message.content, self.message.content)

    def test_get_by_id_not_found(self):
        """Test retrieving a non-existent message."""
        # Retrieve a non-existent message
        retrieved_message = self.repository.get_by_id(uuid.uuid4())
        
        # Verify None is returned
        self.assertIsNone(retrieved_message)

    def test_get_by_conversation(self):
        """Test retrieving messages for a conversation."""
        # Create multiple messages in the database
        for i in range(5):
            MessageModel.objects.create(
                id=uuid.uuid4(),
                conversation=self.conversation,
                sender=self.user1 if i % 2 == 0 else self.user2,
                content=f'Message {i}',
                content_type='text',
                sent_at=datetime.now(timezone.utc)
            )
        
        # Retrieve the messages
        result = self.repository.get_by_conversation(
            conversation_id=self.conversation.id,
            limit=3
        )
        
        # Verify the result
        self.assertIn('messages', result)
        self.assertIn('next_cursor', result)
        self.assertIn('has_more', result)
        self.assertEqual(len(result['messages']), 3)
        self.assertTrue(result['has_more'])
        
        # Verify the messages are domain entities
        for message in result['messages']:
            self.assertIsInstance(message, Message)

    def test_mark_as_read(self):
        """Test marking messages as read."""
        # Create multiple messages in the database
        message_ids = []
        for i in range(3):
            message = MessageModel.objects.create(
                id=uuid.uuid4(),
                conversation=self.conversation,
                sender=self.user2,  # Sent by user2
                content=f'Message {i}',
                content_type='text',
                sent_at=datetime.now(timezone.utc)
            )
            message_ids.append(message.id)
        
        # Mark the messages as read by user1
        updated_count = self.repository.mark_as_read(
            message_ids=message_ids,
            user_id=self.user1.id
        )
        
        # Verify the update count
        self.assertEqual(updated_count, 3)
        
        # Verify the messages are marked as read
        for message_id in message_ids:
            message = MessageModel.objects.get(id=message_id)
            self.assertIn(self.user1.id, message.read_by)

    def test_get_unread_count(self):
        """Test getting the count of unread messages."""
        # Create multiple messages in the database
        for i in range(5):
            message = MessageModel.objects.create(
                id=uuid.uuid4(),
                conversation=self.conversation,
                sender=self.user2,  # Sent by user2
                content=f'Message {i}',
                content_type='text',
                sent_at=datetime.now(timezone.utc)
            )
            # Mark some messages as read
            if i < 2:
                message.read_by.add(self.user1)
        
        # Get the unread count
        unread_count = self.repository.get_unread_count(
            user_id=self.user1.id,
            conversation_id=self.conversation.id
        )
        
        # Verify the count
        self.assertEqual(unread_count, 3)

    def test_delete(self):
        """Test deleting a message."""
        # Create a message in the database
        message_model = MessageModel.objects.create(
            id=self.message.id,
            conversation=self.conversation,
            sender=self.user1,
            content=self.message.content,
            content_type=self.message.content_type,
            sent_at=self.message.sent_at
        )
        
        # Delete the message
        result = self.repository.delete(self.message.id)
        
        # Verify the result
        self.assertTrue(result)
        
        # Verify the message was deleted
        self.assertFalse(MessageModel.objects.filter(id=self.message.id).exists())
