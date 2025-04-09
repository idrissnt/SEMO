"""
Domain layer for the messaging system.

This package contains the core domain logic for the messaging system,
including entities, value objects, and repository interfaces.
"""
from .models import Message, Conversation, Attachment
from .repositories import MessageRepository, ConversationRepository, AttachmentRepository

__all__ = [
    'Message', 
    'Conversation', 
    'Attachment',
    'MessageRepository', 
    'ConversationRepository',
    'AttachmentRepository'
]
