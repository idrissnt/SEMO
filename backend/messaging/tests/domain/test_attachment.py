"""
Unit tests for the Attachment entity.

This module contains tests for the Attachment entity in the domain layer.
"""
import unittest
import uuid
from datetime import datetime, timezone
from freezegun import freeze_time

from messaging.domain.models.entities.attachment import Attachment


class TestAttachment(unittest.TestCase):
    """Test cases for the Attachment entity."""

    def setUp(self):
        """Set up test fixtures."""
        self.file_id = uuid.uuid4()
        self.filename = "test_document.pdf"
        self.content_type = "application/pdf"
        self.file_path = "attachments/user1/test_document.pdf"
        self.file_size = 1024 * 1024  # 1 MB
        self.uploaded_by_id = uuid.uuid4()
        self.message_id = uuid.uuid4()
        self.metadata = {"description": "Test document"}

    @freeze_time("2025-04-05 18:00:00")
    def test_create_attachment(self):
        """Test creating a new attachment."""
        attachment = Attachment.create(
            filename=self.filename,
            content_type=self.content_type,
            file_path=self.file_path,
            file_size=self.file_size,
            uploaded_by_id=self.uploaded_by_id,
            message_id=self.message_id,
            metadata=self.metadata
        )

        # Verify the attachment properties
        self.assertIsInstance(attachment.id, uuid.UUID)
        self.assertEqual(attachment.filename, self.filename)
        self.assertEqual(attachment.content_type, self.content_type)
        self.assertEqual(attachment.file_path, self.file_path)
        self.assertEqual(attachment.file_size, self.file_size)
        self.assertEqual(attachment.uploaded_by_id, self.uploaded_by_id)
        self.assertEqual(attachment.message_id, self.message_id)
        self.assertEqual(attachment.metadata, self.metadata)
        
        # Verify timestamp
        expected_time = datetime(2025, 4, 5, 18, 0, 0, tzinfo=timezone.utc)
        self.assertEqual(attachment.uploaded_at, expected_time)

    def test_associate_with_message(self):
        """Test associating an attachment with a message."""
        # Create an attachment without a message
        attachment = Attachment(
            id=self.file_id,
            filename=self.filename,
            content_type=self.content_type,
            file_path=self.file_path,
            file_size=self.file_size,
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata=self.metadata
        )
        
        # Associate with a message
        new_message_id = uuid.uuid4()
        updated_attachment = attachment.associate_with_message(new_message_id)
        
        # Verify the message ID was updated
        self.assertEqual(updated_attachment.message_id, new_message_id)
        
        # Verify other properties remain unchanged
        self.assertEqual(updated_attachment.id, attachment.id)
        self.assertEqual(updated_attachment.filename, attachment.filename)
        self.assertEqual(updated_attachment.content_type, attachment.content_type)
        self.assertEqual(updated_attachment.file_path, attachment.file_path)
        self.assertEqual(updated_attachment.file_size, attachment.file_size)
        self.assertEqual(updated_attachment.uploaded_by_id, attachment.uploaded_by_id)
        self.assertEqual(updated_attachment.uploaded_at, attachment.uploaded_at)
        self.assertEqual(updated_attachment.metadata, attachment.metadata)

    def test_update_metadata(self):
        """Test updating the metadata of an attachment."""
        # Create an attachment
        attachment = Attachment(
            id=self.file_id,
            filename=self.filename,
            content_type=self.content_type,
            file_path=self.file_path,
            file_size=self.file_size,
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=self.message_id,
            metadata=self.metadata
        )
        
        # Update the metadata
        new_metadata = {"description": "Updated document", "category": "important"}
        updated_attachment = attachment.update_metadata(new_metadata)
        
        # Verify the metadata was updated
        self.assertEqual(updated_attachment.metadata, new_metadata)
        
        # Verify other properties remain unchanged
        self.assertEqual(updated_attachment.id, attachment.id)
        self.assertEqual(updated_attachment.filename, attachment.filename)
        self.assertEqual(updated_attachment.content_type, attachment.content_type)
        self.assertEqual(updated_attachment.file_path, attachment.file_path)
        self.assertEqual(updated_attachment.file_size, attachment.file_size)
        self.assertEqual(updated_attachment.uploaded_by_id, attachment.uploaded_by_id)
        self.assertEqual(updated_attachment.uploaded_at, attachment.uploaded_at)
        self.assertEqual(updated_attachment.message_id, attachment.message_id)

    def test_is_image(self):
        """Test checking if an attachment is an image."""
        # Create an image attachment
        image_attachment = Attachment(
            id=uuid.uuid4(),
            filename="test_image.jpg",
            content_type="image/jpeg",
            file_path="attachments/user1/test_image.jpg",
            file_size=500 * 1024,  # 500 KB
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata={}
        )
        
        # Create a non-image attachment
        pdf_attachment = Attachment(
            id=uuid.uuid4(),
            filename="test_document.pdf",
            content_type="application/pdf",
            file_path="attachments/user1/test_document.pdf",
            file_size=1024 * 1024,  # 1 MB
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata={}
        )
        
        # Verify is_image returns the correct value
        self.assertTrue(image_attachment.is_image())
        self.assertFalse(pdf_attachment.is_image())

    def test_is_document(self):
        """Test checking if an attachment is a document."""
        # Create a document attachment
        doc_attachment = Attachment(
            id=uuid.uuid4(),
            filename="test_document.docx",
            content_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            file_path="attachments/user1/test_document.docx",
            file_size=1024 * 1024,  # 1 MB
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata={}
        )
        
        # Create a non-document attachment
        image_attachment = Attachment(
            id=uuid.uuid4(),
            filename="test_image.jpg",
            content_type="image/jpeg",
            file_path="attachments/user1/test_image.jpg",
            file_size=500 * 1024,  # 500 KB
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata={}
        )
        
        # Verify is_document returns the correct value
        self.assertTrue(doc_attachment.is_document())
        self.assertFalse(image_attachment.is_document())

    def test_get_extension(self):
        """Test getting the file extension of an attachment."""
        # Create an attachment
        attachment = Attachment(
            id=uuid.uuid4(),
            filename="test_document.pdf",
            content_type="application/pdf",
            file_path="attachments/user1/test_document.pdf",
            file_size=1024 * 1024,  # 1 MB
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata={}
        )
        
        # Verify get_extension returns the correct value
        self.assertEqual(attachment.get_extension(), "pdf")
        
        # Test with a filename that has no extension
        attachment = Attachment(
            id=uuid.uuid4(),
            filename="test_file",
            content_type="application/octet-stream",
            file_path="attachments/user1/test_file",
            file_size=1024,
            uploaded_by_id=self.uploaded_by_id,
            uploaded_at=datetime.now(timezone.utc),
            message_id=None,
            metadata={}
        )
        
        # Verify get_extension returns an empty string
        self.assertEqual(attachment.get_extension(), "")


if __name__ == '__main__':
    unittest.main()
