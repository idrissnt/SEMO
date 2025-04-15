from typing import List, Dict, Tuple, Optional
import uuid

from store.domain.models.entities import ProductWithDetails
from store.domain.repositories.repository_interfaces import ProductRepository
from store.infrastructure.django_models.orm_models import (
    ProductModel, 
)
from store.infrastructure.search.search_strategies_implement import CombinedSearchStrategy

class DjangoProductRepository(ProductRepository):
    """Django ORM implementation of ProductRepository"""
    
    def __init__(self):
        # Repository initialization
        self.search_service = CombinedSearchStrategy()

    def search_products_in_one_store(self, store_id: uuid.UUID, query: str) -> List[ProductWithDetails]:
        """Search for products with price information by query string in a store"""
        # Use the search service to find matching products for this store
        matching_product_ids = self.search_service.search_products(query, store_id=store_id)
            
        # Import the utility class
        from store.infrastructure.django_repositories.repository_utils import QueryUtils
        
        # Build optimized query using the utility
        store_products = QueryUtils.build_optimized_query(
            store_id=store_id,
            product_id__in=matching_product_ids
        )
        
        # Convert to domain models using the utility
        return QueryUtils.build_product_details_from_queryset(store_products)

    def search_products_in_all_stores(self, query: str) -> Dict[uuid.UUID, Tuple[str, List[ProductWithDetails]]]:
        """Search for products with price information by query string in all stores
        
        Args:
            query: The search query string
            
        Returns:
            Dictionary mapping store IDs to tuples of (category_path, list of products)
        """
        # Use the search service to find matching products
        matching_product_ids = self.search_service.search_products(query)
        
        if not matching_product_ids:
            return {}  # Return empty dict if no matches
            
        # Import the utility class
        from store.infrastructure.django_repositories.repository_utils import QueryUtils
        
        # Build optimized query using the utility
        # QueryUtils.build_optimized_query already includes select_related
        store_products = QueryUtils.build_optimized_query(
            product_id__in=matching_product_ids
        )
        
        # Get a flat list of products with details
        products_list = QueryUtils.build_product_details_from_queryset(store_products)
        
        # Group products by store ID
        products_by_store = {}
        
        # Group products by store_id
        for product in products_list:
            if product.store_id not in products_by_store:
                # Initialize with empty product list and use this product's category path
                products_by_store[product.store_id] = (product.category_path, [])
            
            # Add product to the list for this store
            products_by_store[product.store_id][1].append(product)
        
        return products_by_store
    
    def get_autocomplete_suggestions(self, partial_query: str, store_brand_id: Optional[uuid.UUID] = None, limit: int = 10) -> List[str]:
        """Get autocomplete suggestions for a partial query string
        
        Args:
            partial_query: The partial search query typed by the user
            store_brand_id: Optional UUID of the store brand to limit suggestions to
            limit: Maximum number of suggestions to return
            
        Returns:
            List of ProductName objects that match the partial query
        """
        from django.contrib.postgres.search import TrigramSimilarity
        from django.db.models import Q, Value, F, Case, When, BooleanField
        from store.domain.models.entities import ProductName
        from store.infrastructure.django_models.orm_models import StoreProductModel
        
        # Clean the query (remove whitespace and convert to lowercase)
        clean_query = partial_query.strip().lower()
        if not clean_query:
            return []
        
        # Base queryset
        base_queryset = ProductModel.objects
        
        # If store_brand_id is provided, use a more efficient JOIN approach
        if store_brand_id:
            # Get product IDs that exist in the specified store using StoreProductModel directly
            product_ids_in_store = StoreProductModel.objects.filter(
                store_brand_id=store_brand_id
            ).values_list('product_id', flat=True)
            
            # Filter base queryset to only include these products
            base_queryset = base_queryset.filter(id__in=product_ids_in_store)
        
        # Combine prefix and similarity matching in a single query with ranking
        # This avoids multiple database hits and in-memory processing
        results = (
            base_queryset
            # Add a boolean field to indicate if it's a prefix match
            .annotate(
                is_prefix_match=Case(
                    When(name__istartswith=clean_query, then=Value(True)),
                    default=Value(False),
                    output_field=BooleanField()
                ),
                # Add similarity score for all products
                similarity=TrigramSimilarity('name', clean_query)
            )
            # Filter to include only relevant matches
            .filter(
                # Either it's a prefix match OR it has sufficient similarity
                # similarity__gt=0.3 means that the product name has a similarity of at least 30%
                Q(is_prefix_match=True) | Q(similarity__gt=0.3)
            )
            # Order by prefix match first (True sorts before False), then by similarity
            .order_by('-is_prefix_match', '-similarity')
            # Get distinct product names
            .values_list('name', flat=True)
            .distinct()[:limit]
        )
        
        # Convert to domain entities
        return [ProductName(name) for name in results]

    