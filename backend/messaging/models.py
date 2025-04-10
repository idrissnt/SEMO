"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from messaging.infrastructure.django_models import (
    MessageModel as Message,
    ConversationModel as Conversation,
    ConversationParticipantModel as ConversationParticipant,
    AttachmentModel as Attachment
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['Message', 'Conversation', 'ConversationParticipant', 'Attachment']
