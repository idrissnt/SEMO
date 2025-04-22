"""
Factory for creating welcome asset repository instances.

This module provides a factory for creating welcome asset repository instances,
following the factory pattern to abstract the creation of concrete implementations.
"""
from core.infrastructure.django_repositories.django_welcom_assets_repository import DjangoWelcomeAssetsRepository
from core.domain.repositories.welcome_assets_repository import WelcomeAssetsRepository
from core.application.services.welcom_asset_service import WelcomeAssetApplicationService
from core.infrastructure.factories.logging_factory import CoreLoggingFactory

class CoreWelcomeFactory:
    """Factory for creating welcome asset repository instances"""

    @staticmethod
    def create_welcome_asset_repository() -> WelcomeAssetsRepository:
        """
        Create a welcome asset repository instance.
        
        Returns:
            A welcome asset repository implementation
        """
        return DjangoWelcomeAssetsRepository()

    @staticmethod
    def create_welcome_asset_service() -> WelcomeAssetApplicationService:
        """
        Create a welcome asset service instance.
        
        Returns:
            A welcome asset service implementation
        """
        welcome_asset_repository = CoreWelcomeFactory.create_welcome_asset_repository()
        return WelcomeAssetApplicationService(welcome_asset_repository, CoreLoggingFactory.create_logger('welcome to Semo'))
    
