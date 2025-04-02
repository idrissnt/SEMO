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

logger = logging.getLogger(__name__)

class BaseViewSet(viewsets.ViewSet):
    """
    Base ViewSet with common functionality and dependency injection
    
    This ViewSet provides common error handling and dependency injection
    for repositories and services, following Clean Architecture principles.
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
    
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
