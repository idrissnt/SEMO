"""
Factory for creating logging service instances.

This module provides a factory for creating logging service instances,
following the factory pattern to abstract the creation of concrete implementations.
"""
from core.domain.services.logging_service_interface import LoggingServiceInterface
from core.infrastructure.services.django_logging_service import DjangoLoggingService

class CoreLoggingFactory:
    """Factory for creating logging service instances"""
    
    @staticmethod
    def create_logger(logger_name: str = "semo") -> LoggingServiceInterface:
        """
        Create a logging service instance.
        
        Args:
            logger_name: Name of the logger to use
            
        Returns:
            A logging service implementation
        """
        return DjangoLoggingService(logger_name)
