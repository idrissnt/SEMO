"""
Serializers for the messaging API.

This package contains serializers for converting domain entities to/from
API representations for the messaging system.
"""
from .message_serializer import (
    MessageSerializer,
    MessageCreateSerializer,
    MessageReadReceiptSerializer
)
from .conversation_serializer import (
    ConversationSerializer,
    ConversationCreateSerializer,
    TaskConversationCreateSerializer
)
from .attachment_serializer import (
    AttachmentSerializer,
    AttachmentUploadSerializer
)

__all__ = [
    'MessageSerializer',
    'MessageCreateSerializer',
    'MessageReadReceiptSerializer',
    'ConversationSerializer',
    'ConversationCreateSerializer',
    'TaskConversationCreateSerializer',
    'AttachmentSerializer',
    'AttachmentUploadSerializer'
]
