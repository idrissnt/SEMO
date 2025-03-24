from typing import List, Dict, Tuple
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
    
    def get_autocomplete_suggestions(self, partial_query: str, limit: int = 10) -> List[str]:
        """Get autocomplete suggestions for a partial query string"""
        
        # Import needed for trigram similarity
        from django.contrib.postgres.search import TrigramSimilarity
        
        # Clean the query
        clean_query = partial_query.strip().lower()
        
        # First try prefix matching (words that start with the query)
        # This gives priority to words that actually start with what the user typed
        prefix_matches = list(
            ProductModel.objects
            .filter(name__istartswith=clean_query)
            .values_list('name', flat=True)
            .distinct()[:limit]
        )
        
        # If we have enough prefix matches, return them
        if len(prefix_matches) >= limit:
            from store.domain.models.entities import ProductName
            return [ProductName(name) for name in prefix_matches[:limit]]
            
        # Otherwise, supplement with trigram similarity matches
        # Calculate how many more results we need
        remaining_slots = limit - len(prefix_matches)
        
        # Get trigram similarity matches, excluding exact prefix matches we already have
        similarity_matches = list(
            ProductModel.objects
            .annotate(similarity=TrigramSimilarity('name', clean_query))
            .filter(similarity__gt=0.3)  # Adjust threshold as needed
            .exclude(name__in=prefix_matches)  # Exclude items we already have
            .order_by('-similarity')
            .values_list('name', flat=True)
            .distinct()[:remaining_slots]
        )
        
        # Combine results, with prefix matches first
        from store.domain.models.entities import ProductName
        # Flatten the list and ensure we don't exceed the limit
        combined_matches = prefix_matches + similarity_matches
        return [ProductName(name) for name in combined_matches[:limit]]

    