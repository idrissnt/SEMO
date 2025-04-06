"""
Infrastructure layer for the messaging system.

This package contains the infrastructure components for the messaging system,
including repository implementations, Django models, and WebSocket consumers.
"""
from .factory import ServiceFactory, RepositoryFactory
from .repositories import (
    DjangoMessageRepository,
    DjangoConversationRepository,
    DjangoAttachmentRepository
)
from .websocket import (
    ChatConsumer,
    websocket_urlpatterns,
    JwtAuthMiddleware,
    JwtAuthMiddlewareStack
)

__all__ = [
    'ServiceFactory',
    'RepositoryFactory',
    'DjangoMessageRepository',
    'DjangoConversationRepository',
    'DjangoAttachmentRepository',
    'ChatConsumer',
    'websocket_urlpatterns',
    'JwtAuthMiddleware',
    'JwtAuthMiddlewareStack'
]
