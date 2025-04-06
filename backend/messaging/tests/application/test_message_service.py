"""
Unit tests for the MessageService.

This module contains tests for the MessageService in the application layer.
"""
import unittest
import uuid
from datetime import datetime, timezone
from unittest.mock import Mock, patch
from freezegun import freeze_time

from messaging.domain.models.entities.message import Message
from messaging.domain.models.entities.conversation import Conversation
from messaging.application.services.message_service import MessageService


class TestMessageService(unittest.TestCase):
    """Test cases for the MessageService."""

    def setUp(self):
        """Set up test fixtures."""
        # Create mock repositories
        self.message_repository = Mock()
        self.conversation_repository = Mock()
        
        # Create the service with mock repositories
        self.message_service = MessageService(
            message_repository=self.message_repository,
            conversation_repository=self.conversation_repository
        )
        
        # Test data
        self.conversation_id = uuid.uuid4()
        self.sender_id = uuid.uuid4()
        self.content = "Test message"
        self.content_type = "text"
        self.metadata = {"importance": "high"}
        
        # Create a test conversation
        self.participants = [self.sender_id, uuid.uuid4()]
        self.conversation = Conversation(
            id=self.conversation_id,
            participants=self.participants,
            type="direct",
            title="Test Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        
        # Create a test message
        self.message = Message(
            id=uuid.uuid4(),
            conversation_id=self.conversation_id,
            sender_id=self.sender_id,
            content=self.content,
            content_type=self.content_type,
            sent_at=datetime.now(timezone.utc),
            delivered_at=None,
            read_by=[],
            metadata=self.metadata
        )

    @freeze_time("2025-04-05 18:00:00")
    def test_send_message(self):
        """Test sending a message."""
        # Configure mocks
        self.conversation_repository.get_by_id.return_value = self.conversation
        self.message_repository.save.return_value = self.message
        
        # Call the service method
        result = self.message_service.send_message(
            conversation_id=self.conversation_id,
            sender_id=self.sender_id,
            content=self.content,
            content_type=self.content_type,
            metadata=self.metadata
        )
        
        # Verify the result
        self.assertEqual(result, self.message)
        
        # Verify the repository calls
        self.conversation_repository.get_by_id.assert_called_once_with(self.conversation_id)
        self.message_repository.save.assert_called_once()

    def test_send_message_conversation_not_found(self):
        """Test sending a message to a non-existent conversation."""
        # Configure mocks
        self.conversation_repository.get_by_id.return_value = None
        
        # Call the service method and verify it raises an exception
        with self.assertRaises(ValueError):
            self.message_service.send_message(
                conversation_id=self.conversation_id,
                sender_id=self.sender_id,
                content=self.content
            )

    def test_send_message_sender_not_in_conversation(self):
        """Test sending a message by a user who is not in the conversation."""
        # Configure mocks
        self.conversation_repository.get_by_id.return_value = self.conversation
        
        # Call the service method with a sender who is not in the conversation
        non_participant_id = uuid.uuid4()
        with self.assertRaises(ValueError):
            self.message_service.send_message(
                conversation_id=self.conversation_id,
                sender_id=non_participant_id,
                content=self.content
            )

    def test_get_message(self):
        """Test retrieving a message by ID."""
        # Configure mocks
        self.message_repository.get_by_id.return_value = self.message
        
        # Call the service method
        result = self.message_service.get_message(self.message.id)
        
        # Verify the result
        self.assertEqual(result, self.message)
        
        # Verify the repository calls
        self.message_repository.get_by_id.assert_called_once_with(self.message.id)

    def test_get_conversation_messages(self):
        """Test retrieving messages for a conversation."""
        # Configure mocks
        messages = [self.message, Mock(spec=Message), Mock(spec=Message)]
        self.message_repository.get_by_conversation.return_value = {
            "messages": messages,
            "next_cursor": str(uuid.uuid4()),
            "has_more": True
        }
        
        # Call the service method
        result = self.message_service.get_conversation_messages(
            conversation_id=self.conversation_id,
            limit=10
        )
        
        # Verify the result
        self.assertEqual(result["messages"], messages)
        self.assertTrue(result["has_more"])
        self.assertIsNotNone(result["next_cursor"])
        
        # Verify the repository calls
        self.message_repository.get_by_conversation.assert_called_once_with(
            conversation_id=self.conversation_id,
            limit=10,
            before_message_id=None
        )

    def test_mark_as_read(self):
        """Test marking messages as read."""
        # Configure mocks
        message_ids = [uuid.uuid4(), uuid.uuid4()]
        user_id = uuid.uuid4()
        self.message_repository.mark_as_read.return_value = 2
        
        # Call the service method
        result = self.message_service.mark_as_read(
            message_ids=message_ids,
            user_id=user_id
        )
        
        # Verify the result
        self.assertEqual(result, 2)
        
        # Verify the repository calls
        self.message_repository.mark_as_read.assert_called_once_with(
            message_ids=message_ids,
            user_id=user_id
        )

    def test_get_unread_count(self):
        """Test getting the count of unread messages."""
        # Configure mocks
        user_id = uuid.uuid4()
        self.message_repository.get_unread_count.return_value = 5
        
        # Call the service method
        result = self.message_service.get_unread_count(
            user_id=user_id,
            conversation_id=self.conversation_id
        )
        
        # Verify the result
        self.assertEqual(result, 5)
        
        # Verify the repository calls
        self.message_repository.get_unread_count.assert_called_once_with(
            user_id=user_id,
            conversation_id=self.conversation_id
        )

    def test_delete_message(self):
        """Test deleting a message."""
        # Configure mocks
        message_id = uuid.uuid4()
        user_id = self.sender_id
        self.message_repository.get_by_id.return_value = self.message
        self.message_repository.delete.return_value = True
        
        # Call the service method
        result = self.message_service.delete_message(
            message_id=message_id,
            user_id=user_id
        )
        
        # Verify the result
        self.assertTrue(result)
        
        # Verify the repository calls
        self.message_repository.get_by_id.assert_called_once_with(message_id)
        self.message_repository.delete.assert_called_once_with(message_id)

    def test_delete_message_not_sender(self):
        """Test deleting a message by a user who is not the sender."""
        # Configure mocks
        message_id = uuid.uuid4()
        user_id = uuid.uuid4()  # Not the sender
        self.message_repository.get_by_id.return_value = self.message
        
        # Call the service method
        result = self.message_service.delete_message(
            message_id=message_id,
            user_id=user_id
        )
        
        # Verify the result
        self.assertFalse(result)
        
        # Verify the repository calls
        self.message_repository.get_by_id.assert_called_once_with(message_id)
        self.message_repository.delete.assert_not_called()


if __name__ == '__main__':
    unittest.main()
