"""
Unit tests for the Conversation entity.

This module contains tests for the Conversation entity in the domain layer.
"""
import unittest
import uuid
from datetime import datetime, timezone, timedelta
from freezegun import freeze_time

from messaging.domain.models.entities.conversation import Conversation


class TestConversation(unittest.TestCase):
    """Test cases for the Conversation entity."""

    def setUp(self):
        """Set up test fixtures."""
        self.user1_id = uuid.uuid4()
        self.user2_id = uuid.uuid4()
        self.participants = [self.user1_id, self.user2_id]
        self.type = "direct"
        self.title = "Test Conversation"
        self.metadata = {"priority": "high"}

    @freeze_time("2025-04-05 18:00:00")
    def test_create_conversation(self):
        """Test creating a new conversation."""
        conversation = Conversation.create(
            participants=self.participants,
            type=self.type,
            title=self.title,
            metadata=self.metadata
        )

        # Verify the conversation properties
        self.assertIsInstance(conversation.id, uuid.UUID)
        self.assertEqual(set(conversation.participants), set(self.participants))
        self.assertEqual(conversation.type, self.type)
        self.assertEqual(conversation.title, self.title)
        self.assertEqual(conversation.metadata, self.metadata)
        
        # Verify timestamps
        expected_time = datetime(2025, 4, 5, 18, 0, 0, tzinfo=timezone.utc)
        self.assertEqual(conversation.created_at, expected_time)
        self.assertEqual(conversation.updated_at, expected_time)
        self.assertIsNone(conversation.last_message_at)

    def test_add_participant(self):
        """Test adding a participant to a conversation."""
        conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants.copy(),
            type="group",  # Only group conversations can add participants
            title=self.title,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata=self.metadata
        )

        # Add a new participant
        new_user_id = uuid.uuid4()
        updated_conversation = conversation.add_participant(new_user_id)
        self.assertEqual(len(updated_conversation.participants), 3)
        self.assertIn(new_user_id, updated_conversation.participants)

        # Try to add an existing participant (should not duplicate)
        updated_conversation = updated_conversation.add_participant(self.user1_id)
        self.assertEqual(len(updated_conversation.participants), 3)

    def test_remove_participant(self):
        """Test removing a participant from a conversation."""
        conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants.copy(),
            type="group",  # Only group conversations can remove participants
            title=self.title,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata=self.metadata
        )

        # Remove an existing participant
        updated_conversation = conversation.remove_participant(self.user1_id)
        self.assertEqual(len(updated_conversation.participants), 1)
        self.assertNotIn(self.user1_id, updated_conversation.participants)

        # Try to remove a non-existent participant (should not change)
        non_existent_id = uuid.uuid4()
        updated_conversation = updated_conversation.remove_participant(non_existent_id)
        self.assertEqual(len(updated_conversation.participants), 1)

    def test_update_title(self):
        """Test updating the title of a conversation."""
        conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants.copy(),
            type=self.type,
            title=self.title,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata=self.metadata
        )

        # Update the title
        new_title = "Updated Conversation Title"
        with freeze_time("2025-04-05 19:00:00"):
            updated_conversation = conversation.update_title(new_title)
            self.assertEqual(updated_conversation.title, new_title)
            expected_time = datetime(2025, 4, 5, 19, 0, 0, tzinfo=timezone.utc)
            self.assertEqual(updated_conversation.updated_at, expected_time)

    def test_update_last_message_time(self):
        """Test updating the last message time of a conversation."""
        conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants.copy(),
            type=self.type,
            title=self.title,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata=self.metadata
        )

        # Update the last message time
        message_time = datetime.now(timezone.utc)
        updated_conversation = conversation.update_last_message_time(message_time)
        self.assertEqual(updated_conversation.last_message_at, message_time)
        self.assertEqual(updated_conversation.updated_at, message_time)

    def test_is_participant(self):
        """Test checking if a user is a participant in a conversation."""
        conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants.copy(),
            type=self.type,
            title=self.title,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata=self.metadata
        )

        # Check if a user is a participant
        self.assertTrue(conversation.is_participant(self.user1_id))
        self.assertTrue(conversation.is_participant(self.user2_id))
        
        # Check if a non-participant user is a participant
        non_participant_id = uuid.uuid4()
        self.assertFalse(conversation.is_participant(non_participant_id))

    def test_update_metadata(self):
        """Test updating the metadata of a conversation."""
        conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants.copy(),
            type=self.type,
            title=self.title,
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata=self.metadata
        )

        # Update the metadata
        new_metadata = {"priority": "low", "category": "work"}
        with freeze_time("2025-04-05 20:00:00"):
            updated_conversation = conversation.update_metadata(new_metadata)
            self.assertEqual(updated_conversation.metadata, new_metadata)
            expected_time = datetime(2025, 4, 5, 20, 0, 0, tzinfo=timezone.utc)
            self.assertEqual(updated_conversation.updated_at, expected_time)


if __name__ == '__main__':
    unittest.main()
