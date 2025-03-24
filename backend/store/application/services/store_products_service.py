from typing import List, Optional
import uuid

from store.domain.models.entities import ProductWithDetails
from store.domain.repositories.repository_interfaces import StoreProductRepository
from store.domain.services.cache_service import CacheService

class StoreProductsService:
    """Application service for store products-related use cases"""
    
    def __init__(
        self, 
        store_product_repository: StoreProductRepository,
        cache_service: Optional[CacheService] = None
    ):
        self.store_product_repository = store_product_repository
        self.cache_service = cache_service
        
    def get_products_by_store_id(self, store_id: uuid.UUID) -> List[ProductWithDetails]:
        """Get all store products for a specific store
        
        This method implements caching to improve performance.
        
        Args:
            store_id: UUID of the store to get products for
            
        Returns:
            A list of ProductWithDetails domain entities
        """
        # Try to get from cache first
        if self.cache_service:
            cache_key = f'store_products:{store_id}'
            cached_products = self.cache_service.get(cache_key)
            
            if cached_products:
                return cached_products
        
        # Get products from repository
        products_with_details = self.store_product_repository.get_store_products_with_details(store_id)
        
        # Cache the results if cache service is available
        if self.cache_service and products_with_details:
            # Cache with a reasonable timeout (1 hour)
            self.cache_service.set(cache_key, products_with_details, timeout=3600)
        
        return products_with_details
    
    def get_products_by_category_path(self, 
                             store_brand_id: uuid.UUID,
                             category_path: Optional[str] = None, 
                             ) -> List[ProductWithDetails]:
        """Get store products by category path
        
        This method retrieves products for a specific category path and filters by store.
        
        Args:
            category_path: Category path to retrieve products for
            store_brand_id: UUID of the store to filter products by
            
        Returns:
            A list of ProductWithDetails domain entities
        """
        if not category_path:
            category_path = "fruits_et_legumes.fruits"
        
        if self.cache_service:
            cache_key = f'store_products_by_category:{category_path}'
            cached_products = self.cache_service.get(cache_key)
            
            if cached_products:
                return cached_products

        # Get products from repository
        products_with_details = self.store_product_repository.get_products_in_category_for_store(
            store_brand_id=store_brand_id,
            category_path=category_path
        )
        
        # Cache the results if cache service is available
        if self.cache_service and products_with_details:
            # Cache with a reasonable timeout (1 hour)
            self.cache_service.set(cache_key, products_with_details, timeout=3600)
        
        return products_with_details
            

