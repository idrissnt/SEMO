"""Factory classes for creating repository and service instances.

This module provides factory classes for creating repository and service instances
following the Abstract Factory pattern. This ensures proper dependency injection
and separation of concerns according to Clean Architecture principles.
"""
from typing import Type, Optional

# Repository interfaces
from deliveries.domain.repositories.driver_repo.driver_repository_interfaces import DriverRepository
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.domain.repositories.delivery_repo.delivery_timeline_repository_interfaces import DeliveryTimelineRepository
from deliveries.domain.repositories.delivery_repo.delivery_location_repository_interfaces import DeliveryLocationRepository
from deliveries.domain.repositories.driver_repo.driver_device_repository_interfaces import DriverDeviceRepository
from deliveries.domain.repositories.driver_repo.driver_location_repository_interfaces import DriverLocationRepository
from deliveries.domain.repositories.notification_repo.driver_notification_repository_interfaces import DriverNotificationRepository

# Repository implementations
from deliveries.infrastructure.django_repositories.driver_repo.driver_repository import DjangoDriverRepository
from deliveries.infrastructure.django_repositories.delivery_repo.delivery_repository import DjangoDeliveryRepository
from deliveries.infrastructure.django_repositories.delivery_repo.delivery_timeline_repository import DjangoDeliveryTimelineRepository
from deliveries.infrastructure.django_repositories.delivery_repo.delivery_location_repository import DjangoDeliveryLocationRepository
from deliveries.infrastructure.django_repositories.driver_repo.driver_device_repository import DjangoDriverDeviceRepository
from deliveries.infrastructure.django_repositories.driver_repo.driver_location_repository import DjangoDriverLocationRepository
from deliveries.infrastructure.django_repositories.notification_repo.driver_notification_repository import DjangoDriverNotificationRepository

# Service interfaces
from deliveries.domain.services.maps_service_interface import MapsServiceInterface
from deliveries.domain.services.cache_location_service_interface import LocationCacheService
from deliveries.domain.services.notification_service_interface import NotificationServiceInterface

# Service implementations
from deliveries.infrastructure.services.google_maps_service import GoogleMapsService
from deliveries.infrastructure.services.redis_location_service import RedisLocationService
from deliveries.infrastructure.services.fcm_notification_service import FCMNotificationService

# Application services
from deliveries.application.services.driver_service import NotificationApplicationService
from deliveries.application.services.notification_services.driver_notification_service import DriverNotificationService
from deliveries.application.services.notification_services.delivery_notification_service import DeliveryNotificationService
from deliveries.application.services.notification_services.customer_notification_service import CustomerNotificationService
from deliveries.application.services.delivery_services.base_delivery_services import BaseDeliveryApplicationService
from deliveries.application.services.delivery_services.location_service import LocationApplicationService
from deliveries.application.services.delivery_services.search_services import DeliverySearchApplicationService

# Order repository interface (for dependencies)
from orders.domain.repositories.repository_interfaces import OrderRepository

class RepositoryFactory:
    """Factory for creating repository instances
    
    This factory follows the Abstract Factory pattern to create repository instances
    that implement the repository interfaces defined in the domain layer.
    """
    
    @staticmethod
    def create_driver_repository() -> DriverRepository:
        """Create a driver repository instance"""
        return DjangoDriverRepository()
    
    @staticmethod
    def create_delivery_repository() -> DeliveryRepository:
        """Create a delivery repository instance"""
        return DjangoDeliveryRepository()
    
    @staticmethod
    def create_delivery_timeline_repository() -> DeliveryTimelineRepository:
        """Create a delivery timeline repository instance"""
        return DjangoDeliveryTimelineRepository()
    
    @staticmethod
    def create_delivery_location_repository() -> DeliveryLocationRepository:
        """Create a delivery location repository instance"""
        return DjangoDeliveryLocationRepository()
        
    @staticmethod
    def create_driver_device_repository() -> DriverDeviceRepository:
        """Create a driver device repository instance"""
        return DjangoDriverDeviceRepository()
        
    @staticmethod
    def create_driver_location_repository() -> DriverLocationRepository:
        """Create a driver location repository instance"""
        return DjangoDriverLocationRepository()
        
    @staticmethod
    def create_driver_notification_repository() -> DriverNotificationRepository:
        """Create a driver notification repository instance"""
        return DjangoDriverNotificationRepository()


class ServiceFactory:
    """Factory for creating service instances
    
    This factory follows the Abstract Factory pattern to create service instances
    that implement the service interfaces defined in the domain layer. It uses
    the Singleton pattern to ensure only one instance of each service is created.
    """
    
    # Singleton instances
    _maps_service: Optional[MapsServiceInterface] = None
    _location_cache_service: Optional[LocationCacheService] = None
    _notification_service: Optional[NotificationServiceInterface] = None
    
    @classmethod
    def create_maps_service(cls) -> MapsServiceInterface:
        """Create or get a maps service instance
        
        This method follows the singleton pattern to ensure only one
        instance of the maps service is created. This is important for
        services that might have rate limits or connection pooling.
        
        Returns:
            An implementation of MapsServiceInterface
        """
        if cls._maps_service is None:
            cls._maps_service = GoogleMapsService()
        return cls._maps_service
    
    @classmethod
    def set_maps_service(cls, service: MapsServiceInterface) -> None:
        """Set a custom maps service implementation
        
        This method allows for dependency injection, particularly useful
        for testing where you might want to inject a mock implementation.
        
        Args:
            service: An implementation of MapsServiceInterface
        """
        cls._maps_service = service
    
    @classmethod
    def create_location_cache_service(cls) -> LocationCacheService:
        """Create or get a location cache service instance
        
        This method follows the singleton pattern to ensure only one
        instance of the location cache service is created.
        
        Returns:
            An implementation of LocationCacheService
        """
        if cls._location_cache_service is None:
            cls._location_cache_service = RedisLocationService()
        return cls._location_cache_service
    
    @classmethod
    def set_location_cache_service(cls, service: LocationCacheService) -> None:
        """Set a custom location cache service implementation
        
        This method allows for dependency injection, particularly useful
        for testing where you might want to inject a mock implementation.
        
        Args:
            service: An implementation of LocationCacheService
        """
        cls._location_cache_service = service
        
    @classmethod
    def create_notification_service(cls) -> NotificationServiceInterface:
        """Create or get a notification service instance
        
        This method follows the singleton pattern to ensure only one
        instance of the notification service is created.
        
        Returns:
            An implementation of NotificationServiceInterface
        """
        if cls._notification_service is None:
            cls._notification_service = FCMNotificationService()
        return cls._notification_service
    
    @classmethod
    def set_notification_service(cls, service: NotificationServiceInterface) -> None:
        """Set a custom notification service implementation
        
        This method allows for dependency injection, particularly useful
        for testing where you might want to inject a mock implementation.
        
        Args:
            service: An implementation of NotificationServiceInterface
        """
        cls._notification_service = service


class ApplicationServiceFactory:
    """Factory for creating application service instances
    
    This factory follows the Abstract Factory pattern to create application service
    instances with their dependencies properly injected. It uses the RepositoryFactory
    and ServiceFactory to get the required dependencies.
    """
    
    @classmethod
    def create_notification_application_service(cls) -> NotificationApplicationService:
        """Create a notification application service instance"""
        notification_repository = RepositoryFactory.create_driver_notification_repository()
        notification_service = ServiceFactory.create_notification_service()
        
        return NotificationApplicationService(
            notification_service=notification_service,
            notification_repository=notification_repository
        )
    
    @classmethod
    def create_driver_notification_service(cls) -> DriverNotificationService:
        """Create a driver notification service instance"""
        notification_repository = RepositoryFactory.create_driver_notification_repository()
        notification_service = ServiceFactory.create_notification_service()
        
        return DriverNotificationService(
            notification_repository=notification_repository,
            notification_service=notification_service
        )
    
    @classmethod
    def create_delivery_notification_service(cls) -> DeliveryNotificationService:
        """Create a delivery notification service instance"""
        delivery_repository = RepositoryFactory.create_delivery_repository()
        notification_service = ServiceFactory.create_notification_service()
        driver_location_repository = RepositoryFactory.create_driver_location_repository()
        notification_repository = RepositoryFactory.create_driver_notification_repository()
        # Note: Order repository would need proper initialization in a real implementation
        order_repository = None
        
        return DeliveryNotificationService(
            delivery_repository=delivery_repository,
            notification_service=notification_service,
            driver_location_repository=driver_location_repository,
            notification_repository=notification_repository,
            order_repository=order_repository
        )
    
    @classmethod
    def create_customer_notification_service(cls) -> CustomerNotificationService:
        """Create a customer notification service instance"""
        notification_repository = RepositoryFactory.create_driver_notification_repository()
        delivery_repository = RepositoryFactory.create_delivery_repository()
        notification_service = ServiceFactory.create_notification_service()
        
        return CustomerNotificationService(
            notification_repository=notification_repository,
            delivery_repository=delivery_repository,
            notification_service=notification_service
        )
    
    @classmethod
    def create_delivery_application_service(cls) -> BaseDeliveryApplicationService:
        """Create a delivery application service instance"""
        delivery_repository = RepositoryFactory.create_delivery_repository()
        delivery_timeline_repository = RepositoryFactory.create_delivery_timeline_repository()
        
        return BaseDeliveryApplicationService(
            delivery_repository=delivery_repository,
            delivery_timeline_repository=delivery_timeline_repository
        )
    
    @classmethod
    def create_location_application_service(cls) -> LocationApplicationService:
        """Create a location application service instance"""
        delivery_location_repository = RepositoryFactory.create_delivery_location_repository()
        maps_service = ServiceFactory.create_maps_service()
        
        return LocationApplicationService(
            delivery_location_repository=delivery_location_repository,
            maps_service=maps_service
        )
    
    @classmethod
    def create_delivery_search_service(cls) -> DeliverySearchApplicationService:
        """Create a delivery search service instance"""
        delivery_repository = RepositoryFactory.create_delivery_repository()
        
        return DeliverySearchApplicationService(
            delivery_repository=delivery_repository
        )
