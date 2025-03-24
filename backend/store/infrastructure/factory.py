"""
Factory for creating repositories, services and application services with proper dependency injection.
This centralizes the creation of dependencies throughout the application.
"""
# Application Services
from store.application.services.search_products_service import SearchProductsService
from store.application.services.store_products_service import StoreProductsService
from store.application.services.store_brand_location_service import StoreBrandLocationService

# Repositories
from store.infrastructure.django_repositories.django_store_product_repository import DjangoStoreProductRepository
from store.infrastructure.django_repositories.django_store_brand_repository import DjangoStoreBrandRepository
from store.infrastructure.django_repositories.django_product_repository import DjangoProductRepository

# External Services
from store.infrastructure.external_services.cache_service import DjangoCacheService
from store.infrastructure.external_services.store_location_google_maps_service import GoogleMapsService
from store.infrastructure.analytics.search_analytics_implementation import DjangoSearchAnalyticsService


# Class-based factory for creating complete application services
class StoreFactory:
    """Factory for creating application services with proper dependency injection"""
    
    @staticmethod
    def create_store_products_service():
        """Create a StoreProductsService with all dependencies"""
        store_product_repository = DjangoStoreProductRepository()
        cache_service = DjangoCacheService()
        
        return StoreProductsService(
            store_product_repository=store_product_repository,
            cache_service=cache_service
        )
    
    @staticmethod
    def create_store_brand_location_service():
        """Create a StoreBrandLocationService with all dependencies"""
        store_brand_repository = DjangoStoreBrandRepository()
        location_service = GoogleMapsService()
        cache_service = DjangoCacheService()    
        
        return StoreBrandLocationService(
            store_brand_repository=store_brand_repository,
            location_service=location_service,
            cache_service=cache_service
        )
    
    @staticmethod
    def create_search_products_service():
        """Create a SearchProductsService with all dependencies"""
        product_repository = DjangoProductRepository()
        cache_service = DjangoCacheService()
        analytics_service = DjangoSearchAnalyticsService()
        
        return SearchProductsService(
            product_repository=product_repository,
            cache_service=cache_service,
            analytics_service=analytics_service
        )
        
    
            