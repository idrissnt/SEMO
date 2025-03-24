from typing import List, Optional
import uuid

from backend.store.domain.models.entities import ProductWithDetails
from backend.store.domain.repositories.repository_interfaces import StoreProductRepository
from backend.store.infrastructure.django_repositories.repository_utils import QueryUtils

class DjangoStoreProductRepository(StoreProductRepository):
    """Django ORM implementation of StoreProductRepository"""
    
    def get_store_products_with_details(self, 
            store_brand_id: uuid.UUID) -> List[ProductWithDetails]:
        """Get all store products for a store brand"""
        
        store_products = QueryUtils.build_optimized_query(store_brand_id=store_brand_id)
        return QueryUtils.build_product_details_from_queryset(store_products)
    
    def get_products_in_category_for_store(self, 
        store_brand_id: uuid.UUID,
        category_path: Optional[str] = None,    
    ) -> List[ProductWithDetails]:
        """Get all products in a category for a store"""
        
        store_products = QueryUtils.build_optimized_query(
            store_brand_id=store_brand_id, 
            category__path=category_path
        )
        return QueryUtils.build_product_details_from_queryset(store_products)

   

   