"""
Unit tests for the Message entity.

This module contains tests for the Message entity in the domain layer.
"""
import unittest
import uuid
from datetime import datetime, timezone
from freezegun import freeze_time

from messaging.domain.models.entities.message import Message


class TestMessage(unittest.TestCase):
    """Test cases for the Message entity."""

    def setUp(self):
        """Set up test fixtures."""
        self.conversation_id = uuid.uuid4()
        self.sender_id = uuid.uuid4()
        self.content = "Hello, world!"
        self.content_type = "text"
        self.metadata = {"importance": "high"}

    @freeze_time("2025-04-05 18:00:00")
    def test_create_message(self):
        """Test creating a new message."""
        message = Message.create(
            conversation_id=self.conversation_id,
            sender_id=self.sender_id,
            content=self.content,
            content_type=self.content_type,
            metadata=self.metadata
        )

        # Verify the message properties
        self.assertIsInstance(message.id, uuid.UUID)
        self.assertEqual(message.conversation_id, self.conversation_id)
        self.assertEqual(message.sender_id, self.sender_id)
        self.assertEqual(message.content, self.content)
        self.assertEqual(message.content_type, self.content_type)
        self.assertEqual(message.metadata, self.metadata)
        
        # Verify timestamps
        expected_time = datetime(2025, 4, 5, 18, 0, 0, tzinfo=timezone.utc)
        self.assertEqual(message.sent_at, expected_time)
        self.assertIsNone(message.delivered_at)
        self.assertEqual(message.read_by, [])

    def test_mark_as_delivered(self):
        """Test marking a message as delivered."""
        message = Message(
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

        with freeze_time("2025-04-05 18:05:00"):
            delivered_message = message.mark_as_delivered()
            expected_time = datetime(2025, 4, 5, 18, 5, 0, tzinfo=timezone.utc)
            self.assertEqual(delivered_message.delivered_at, expected_time)

    def test_mark_as_read(self):
        """Test marking a message as read by a user."""
        message = Message(
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

        # Mark as read by a user
        user_id = uuid.uuid4()
        read_message = message.mark_as_read(user_id)
        self.assertEqual(read_message.read_by, [user_id])

        # Mark as read by another user
        another_user_id = uuid.uuid4()
        read_message = read_message.mark_as_read(another_user_id)
        self.assertEqual(set(read_message.read_by), {user_id, another_user_id})

        # Mark as read by the same user again (should not duplicate)
        read_message = read_message.mark_as_read(user_id)
        self.assertEqual(set(read_message.read_by), {user_id, another_user_id})

    def test_is_read_by(self):
        """Test checking if a message is read by a specific user."""
        user_id = uuid.uuid4()
        message = Message(
            id=uuid.uuid4(),
            conversation_id=self.conversation_id,
            sender_id=self.sender_id,
            content=self.content,
            content_type=self.content_type,
            sent_at=datetime.now(timezone.utc),
            delivered_at=None,
            read_by=[user_id],
            metadata=self.metadata
        )

        # Check if read by the user
        self.assertTrue(message.is_read_by(user_id))
        
        # Check if read by another user
        another_user_id = uuid.uuid4()
        self.assertFalse(message.is_read_by(another_user_id))

    def test_update_content(self):
        """Test updating the content of a message."""
        message = Message(
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

        # Update the content
        new_content = "Updated content"
        updated_message = message.update_content(new_content)
        self.assertEqual(updated_message.content, new_content)
        self.assertEqual(updated_message.content_type, self.content_type)

        # Update the content type
        new_content_type = "markdown"
        updated_message = message.update_content(new_content, new_content_type)
        self.assertEqual(updated_message.content, new_content)
        self.assertEqual(updated_message.content_type, new_content_type)


if __name__ == '__main__':
    unittest.main()
