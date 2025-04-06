"""
Service factory for the messaging system.

This module provides a factory for creating service instances for the messaging system.
It ensures that services are created with the correct dependencies and are properly
configured.
"""
from typing import Optional

from ..application.services import (
    MessageService,
    ConversationService,
    TaskConversationService,
    AttachmentService
)
from ..domain.repositories import (
    MessageRepository,
    ConversationRepository,
    AttachmentRepository
)
from .repositories import (
    DjangoMessageRepository,
    DjangoConversationRepository,
    DjangoAttachmentRepository
)


class RepositoryFactory:
    """
    Factory for creating repository instances.
    
    This class provides static methods for creating repository instances
    with the correct dependencies.
    """
    
    @staticmethod
    def get_message_repository() -> MessageRepository:
        """
        Get a MessageRepository instance.
        
        Returns:
            MessageRepository instance
        """
        return DjangoMessageRepository()
    
    @staticmethod
    def get_conversation_repository() -> ConversationRepository:
        """
        Get a ConversationRepository instance.
        
        Returns:
            ConversationRepository instance
        """
        return DjangoConversationRepository()
    
    @staticmethod
    def get_attachment_repository() -> AttachmentRepository:
        """
        Get an AttachmentRepository instance.
        
        Returns:
            AttachmentRepository instance
        """
        return DjangoAttachmentRepository()


class ServiceFactory:
    """
    Factory for creating service instances.
    
    This class provides static methods for creating service instances
    with the correct dependencies. It also caches instances to avoid
    creating multiple instances of the same service.
    """
    
    # Service instances
    _message_service: Optional[MessageService] = None
    _conversation_service: Optional[ConversationService] = None
    _task_conversation_service: Optional[TaskConversationService] = None
    _attachment_service: Optional[AttachmentService] = None
    
    @classmethod
    def get_message_service(cls) -> MessageService:
        """
        Get a MessageService instance.
        
        Returns:
            MessageService instance
        """
        if cls._message_service is None:
            cls._message_service = MessageService(
                message_repository=RepositoryFactory.get_message_repository(),
                conversation_repository=RepositoryFactory.get_conversation_repository()
            )
        return cls._message_service
    
    @classmethod
    def get_conversation_service(cls) -> ConversationService:
        """
        Get a ConversationService instance.
        
        Returns:
            ConversationService instance
        """
        if cls._conversation_service is None:
            cls._conversation_service = ConversationService(
                conversation_repository=RepositoryFactory.get_conversation_repository()
            )
        return cls._conversation_service
    
    @classmethod
    def get_task_conversation_service(cls) -> TaskConversationService:
        """
        Get a TaskConversationService instance.
        
        Returns:
            TaskConversationService instance
        """
        if cls._task_conversation_service is None:
            cls._task_conversation_service = TaskConversationService(
                conversation_service=cls.get_conversation_service(),
                conversation_repository=RepositoryFactory.get_conversation_repository()
            )
        return cls._task_conversation_service
    
    @classmethod
    def get_attachment_service(cls) -> AttachmentService:
        """
        Get an AttachmentService instance.
        
        Returns:
            AttachmentService instance
        """
        if cls._attachment_service is None:
            cls._attachment_service = AttachmentService(
                attachment_repository=RepositoryFactory.get_attachment_repository()
            )
        return cls._attachment_service
