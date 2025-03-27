from typing import Type

from deliveries.domain.repositories.repository_interfaces import (
    DriverRepository, DeliveryRepository,
    DeliveryTimelineRepository, DeliveryLocationRepository
)
from deliveries.infrastructure.django_repositories.driver_repository import DjangoDriverRepository
from deliveries.infrastructure.django_repositories.delivery_repository import DjangoDeliveryRepository
from deliveries.infrastructure.django_repositories.delivery_timeline_repository import DjangoDeliveryTimelineRepository
from deliveries.infrastructure.django_repositories.delivery_location_repository import DjangoDeliveryLocationRepository


class RepositoryFactory:
    """Factory for creating repository instances"""
    
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
