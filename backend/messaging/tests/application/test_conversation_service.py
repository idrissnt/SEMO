"""
Unit tests for the ConversationService.

This module contains tests for the ConversationService in the application layer.
"""
import unittest
import uuid
from datetime import datetime, timezone
from unittest.mock import Mock, patch
from freezegun import freeze_time

from messaging.domain.models.entities.conversation import Conversation
from messaging.application.services.conversation_service import ConversationService


class TestConversationService(unittest.TestCase):
    """Test cases for the ConversationService."""

    def setUp(self):
        """Set up test fixtures."""
        # Create mock repositories
        self.conversation_repository = Mock()
        
        # Create the service with mock repositories
        self.conversation_service = ConversationService(
            conversation_repository=self.conversation_repository
        )
        
        # Test data
        self.user1_id = uuid.uuid4()
        self.user2_id = uuid.uuid4()
        self.participants = [self.user1_id, self.user2_id]
        
        # Create a test conversation
        self.conversation = Conversation(
            id=uuid.uuid4(),
            participants=self.participants,
            type="direct",
            title="Test Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )

    @freeze_time("2025-04-05 18:00:00")
    def test_create_conversation(self):
        """Test creating a new conversation."""
        # Configure mocks
        self.conversation_repository.get_direct_conversation.return_value = None
        self.conversation_repository.save.return_value = self.conversation
        
        # Call the service method
        result = self.conversation_service.create_conversation(
            participants=self.participants,
            type="direct",
            title="Test Conversation"
        )
        
        # Verify the result
        self.assertEqual(result, self.conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_direct_conversation.assert_called_once_with(
            self.participants[0], self.participants[1]
        )
        self.conversation_repository.save.assert_called_once()

    def test_create_direct_conversation_existing(self):
        """Test creating a direct conversation that already exists."""
        # Configure mocks
        self.conversation_repository.get_direct_conversation.return_value = self.conversation
        
        # Call the service method
        result = self.conversation_service.create_conversation(
            participants=self.participants,
            type="direct"
        )
        
        # Verify the result
        self.assertEqual(result, self.conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_direct_conversation.assert_called_once_with(
            self.participants[0], self.participants[1]
        )
        self.conversation_repository.save.assert_not_called()

    def test_create_direct_conversation_invalid_participants(self):
        """Test creating a direct conversation with invalid number of participants."""
        # Call the service method with too many participants
        with self.assertRaises(ValueError):
            self.conversation_service.create_conversation(
                participants=[uuid.uuid4(), uuid.uuid4(), uuid.uuid4()],
                type="direct"
            )
        
        # Call the service method with too few participants
        with self.assertRaises(ValueError):
            self.conversation_service.create_conversation(
                participants=[uuid.uuid4()],
                type="direct"
            )

    def test_get_conversation(self):
        """Test retrieving a conversation by ID."""
        # Configure mocks
        conversation_id = uuid.uuid4()
        self.conversation_repository.get_by_id.return_value = self.conversation
        
        # Call the service method
        result = self.conversation_service.get_conversation(conversation_id)
        
        # Verify the result
        self.assertEqual(result, self.conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_by_id.assert_called_once_with(conversation_id)

    def test_get_user_conversations(self):
        """Test retrieving conversations for a user."""
        # Configure mocks
        user_id = self.user1_id
        conversations = [self.conversation, Mock(spec=Conversation), Mock(spec=Conversation)]
        self.conversation_repository.get_by_participant.return_value = conversations
        
        # Call the service method
        result = self.conversation_service.get_user_conversations(user_id)
        
        # Verify the result
        self.assertEqual(result, conversations)
        
        # Verify the repository calls
        self.conversation_repository.get_by_participant.assert_called_once_with(user_id)

    def test_get_or_create_direct_conversation(self):
        """Test getting or creating a direct conversation."""
        # Configure mocks for existing conversation
        self.conversation_repository.get_direct_conversation.return_value = self.conversation
        
        # Call the service method
        result = self.conversation_service.get_or_create_direct_conversation(
            user_id1=self.user1_id,
            user_id2=self.user2_id
        )
        
        # Verify the result
        self.assertEqual(result, self.conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_direct_conversation.assert_called_once_with(
            self.user1_id, self.user2_id
        )
        
        # Reset mocks for non-existing conversation
        self.conversation_repository.reset_mock()
        self.conversation_repository.get_direct_conversation.return_value = None
        self.conversation_repository.save.return_value = self.conversation
        
        # Call the service method again
        result = self.conversation_service.get_or_create_direct_conversation(
            user_id1=self.user1_id,
            user_id2=self.user2_id
        )
        
        # Verify the result
        self.assertEqual(result, self.conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_direct_conversation.assert_called_once_with(
            self.user1_id, self.user2_id
        )
        self.conversation_repository.save.assert_called_once()

    def test_add_participant(self):
        """Test adding a participant to a conversation."""
        # Configure mocks
        conversation_id = uuid.uuid4()
        user_id = uuid.uuid4()
        added_by_id = self.user1_id
        
        # Create a group conversation
        group_conversation = Conversation(
            id=conversation_id,
            participants=self.participants.copy(),
            type="group",
            title="Group Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        
        # Updated conversation with the new participant
        updated_conversation = Conversation(
            id=conversation_id,
            participants=self.participants + [user_id],
            type="group",
            title="Group Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        
        self.conversation_repository.get_by_id.return_value = group_conversation
        self.conversation_repository.save.return_value = updated_conversation
        
        # Call the service method
        result = self.conversation_service.add_participant(
            conversation_id=conversation_id,
            user_id=user_id,
            added_by_id=added_by_id
        )
        
        # Verify the result
        self.assertEqual(result, updated_conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_by_id.assert_called_once_with(conversation_id)
        self.conversation_repository.save.assert_called_once()

    def test_add_participant_direct_conversation(self):
        """Test adding a participant to a direct conversation (should fail)."""
        # Configure mocks
        conversation_id = uuid.uuid4()
        user_id = uuid.uuid4()
        added_by_id = self.user1_id
        
        self.conversation_repository.get_by_id.return_value = self.conversation  # Direct conversation
        
        # Call the service method
        with self.assertRaises(ValueError):
            self.conversation_service.add_participant(
                conversation_id=conversation_id,
                user_id=user_id,
                added_by_id=added_by_id
            )

    def test_add_participant_not_in_conversation(self):
        """Test adding a participant by a user who is not in the conversation."""
        # Configure mocks
        conversation_id = uuid.uuid4()
        user_id = uuid.uuid4()
        added_by_id = uuid.uuid4()  # Not in the conversation
        
        # Create a group conversation
        group_conversation = Conversation(
            id=conversation_id,
            participants=self.participants.copy(),
            type="group",
            title="Group Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        
        self.conversation_repository.get_by_id.return_value = group_conversation
        
        # Call the service method
        with self.assertRaises(ValueError):
            self.conversation_service.add_participant(
                conversation_id=conversation_id,
                user_id=user_id,
                added_by_id=added_by_id
            )

    def test_remove_participant(self):
        """Test removing a participant from a conversation."""
        # Configure mocks
        conversation_id = uuid.uuid4()
        user_id = self.user2_id
        removed_by_id = self.user1_id
        
        # Create a group conversation
        group_conversation = Conversation(
            id=conversation_id,
            participants=self.participants + [uuid.uuid4()],
            type="group",
            title="Group Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        
        # Updated conversation without the removed participant
        updated_conversation = Conversation(
            id=conversation_id,
            participants=[self.user1_id, uuid.uuid4()],
            type="group",
            title="Group Conversation",
            created_at=datetime.now(timezone.utc),
            updated_at=datetime.now(timezone.utc),
            last_message_at=None,
            metadata={}
        )
        
        self.conversation_repository.get_by_id.return_value = group_conversation
        self.conversation_repository.save.return_value = updated_conversation
        
        # Call the service method
        result = self.conversation_service.remove_participant(
            conversation_id=conversation_id,
            user_id=user_id,
            removed_by_id=removed_by_id
        )
        
        # Verify the result
        self.assertEqual(result, updated_conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_by_id.assert_called_once_with(conversation_id)
        self.conversation_repository.save.assert_called_once()

    def test_update_conversation_title(self):
        """Test updating the title of a conversation."""
        # Configure mocks
        conversation_id = uuid.uuid4()
        user_id = self.user1_id
        new_title = "Updated Title"
        
        self.conversation_repository.get_by_id.return_value = self.conversation
        
        # Updated conversation with the new title
        updated_conversation = Conversation(
            id=self.conversation.id,
            participants=self.conversation.participants,
            type=self.conversation.type,
            title=new_title,
            created_at=self.conversation.created_at,
            updated_at=datetime.now(timezone.utc),
            last_message_at=self.conversation.last_message_at,
            metadata=self.conversation.metadata
        )
        
        self.conversation_repository.save.return_value = updated_conversation
        
        # Call the service method
        result = self.conversation_service.update_conversation_title(
            conversation_id=conversation_id,
            title=new_title,
            user_id=user_id
        )
        
        # Verify the result
        self.assertEqual(result, updated_conversation)
        
        # Verify the repository calls
        self.conversation_repository.get_by_id.assert_called_once_with(conversation_id)
        self.conversation_repository.save.assert_called_once()


if __name__ == '__main__':
    unittest.main()
