"""
Repository interfaces for the messaging system.

This package contains the repository interfaces for the messaging system.
These interfaces define the contract for data access and are implemented
in the infrastructure layer.
"""
from .message_repository import MessageRepository
from .conversation_repository import ConversationRepository
from .attachment_repository import AttachmentRepository

__all__ = ['MessageRepository', 'ConversationRepository', 'AttachmentRepository']
