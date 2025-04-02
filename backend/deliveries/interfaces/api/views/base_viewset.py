"""
Base ViewSet classes for the deliveries domain.

This module provides base ViewSet classes with common functionality
and dependency injection for repositories and services, following
Domain-Driven Design principles and Clean Architecture.
"""
import logging
from typing import Type, Dict, Any, Optional
from rest_framework import viewsets, status
from rest_framework.response import Response

from deliveries.application.services.delivery_service import DeliveryApplicationService
from deliveries.infrastructure.django_repositories.delivery_repository import DjangoDeliveryRepository
from deliveries.infrastructure.django_repositories.driver_repository import DjangoDriverRepository
from deliveries.infrastructure.django_repositories.delivery_location_repository import DjangoDeliveryLocationRepository
from the_user_app.infrastructure.django_repositories.user_repository import DjangoUserRepository

logger = logging.getLogger(__name__)


class BaseViewSet(viewsets.ViewSet):
    """
    Base ViewSet with common functionality and dependency injection
    
    This ViewSet provides common error handling and dependency injection
    for repositories and services, following Clean Architecture principles.
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Initialize repositories using dependency injection
        self._delivery_repository = None
        self._driver_repository = None
        self._user_repository = None
        self._delivery_location_repository = None
        self._delivery_service = None
    
    @property
    def delivery_repository(self):
        """Lazy-loaded delivery repository"""
        if self._delivery_repository is None:
            self._delivery_repository = DjangoDeliveryRepository()
        return self._delivery_repository
    
    @property
    def driver_repository(self):
        """Lazy-loaded driver repository"""
        if self._driver_repository is None:
            self._driver_repository = DjangoDriverRepository()
        return self._driver_repository
    
    @property
    def user_repository(self):
        """Lazy-loaded user repository"""
        if self._user_repository is None:
            self._user_repository = DjangoUserRepository()
        return self._user_repository
    
    @property
    def delivery_location_repository(self):
        """Lazy-loaded delivery location repository"""
        if self._delivery_location_repository is None:
            self._delivery_location_repository = DjangoDeliveryLocationRepository()
        return self._delivery_location_repository
    
    @property
    def delivery_service(self):
        """Lazy-loaded delivery application service"""
        if self._delivery_service is None:
            self._delivery_service = DeliveryApplicationService(
                delivery_repository=self.delivery_repository,
                driver_repository=self.driver_repository,
                user_repository=self.user_repository,
                delivery_location_repository=self.delivery_location_repository
            )
        return self._delivery_service
    
    def handle_exception(self, exc):
        """
        Handle exceptions and return appropriate responses
        
        This method provides consistent error handling across all ViewSets.
        """
        logger.error(f"Error in {self.__class__.__name__}: {str(exc)}")
        
        if hasattr(exc, 'status_code'):
            # DRF exceptions
            return super().handle_exception(exc)
        
        # Generic exception
        return Response(
            {'error': 'An unexpected error occurred'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    def validate_serializer(self, serializer_class: Type, data: Dict[str, Any], 
                          instance: Optional[Any] = None) -> Dict[str, Any]:
        """
        Validate data using a serializer
        
        Args:
            serializer_class: The serializer class to use
            data: The data to validate
            instance: Optional instance for update operations
            
        Returns:
            The validated data
            
        Raises:
            ValidationError: If validation fails
        """
        serializer = serializer_class(instance, data=data)
        serializer.is_valid(raise_exception=True)
        return serializer.validated_data
