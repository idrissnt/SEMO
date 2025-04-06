"""
Entity models for the messaging system.

This package contains the core domain entities for the messaging system.
"""
from .message import Message
from .conversation import Conversation
from .attachment import Attachment

__all__ = ['Message', 'Conversation', 'Attachment']
