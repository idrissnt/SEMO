from typing import List, Dict, Optional, Tuple
import uuid

from store.domain.models.entities import ProductName, ProductWithDetails
from store.domain.repositories.repository_interfaces import (
    ProductRepository
)
from store.domain.services.cache_service import CacheService
from store.domain.services.search_analytics_service import SearchAnalyticsService
from store.domain.value_objects.pagination import PaginationParams, PagedResult


class SearchProductsService:
    """Application service for search-related use cases"""
    
    def __init__(
        self, 
        product_repository: ProductRepository,
        cache_service: CacheService,
        analytics_service: Optional[SearchAnalyticsService] = None
    ):
        self.product_repository = product_repository
        self.cache_service = cache_service
        self.analytics_service = analytics_service
        
    def autocomplete_query(self, partial_query: str, limit: int = 10) -> List[ProductName]:
        """
        Get autocomplete suggestions for a partial search query
        
        Args:
            partial_query: The partial query to autocomplete
            limit: Maximum number of suggestions to return
            
        Returns:
            List of ProductName objects as autocomplete suggestions
        """
        # Clean the query
        clean_query = partial_query.strip().lower()
        
        if not clean_query or len(clean_query) < 2:
            return []
        
        # Try to get from cache first
        cache_key = f'autocomplete:{clean_query}'
        cached_results = self.cache_service.get(cache_key)
        
        if cached_results:
            return cached_results
            
        # Get suggestions from repository
        suggestions = self.product_repository.get_autocomplete_suggestions(
            partial_query=clean_query,
            limit=limit
        )
        
        # Cache the results with a short timeout (5 minutes)
        # Autocomplete results should be relatively fresh, but we still want some caching
        # to handle repeated requests for common prefixes
        self.cache_service.set(cache_key, suggestions, timeout=300)  # 5 minutes
        
        return suggestions
    
    def search_products(self, query: str, 
                        store_id: Optional[uuid.UUID] = None,
                        page: int = 1,
                        page_size: int = 10,
                        ) -> Tuple[Dict[uuid.UUID, Tuple[str, List[ProductWithDetails]]], Dict[str, int]]:
        """
        Search for products with optional store filtering
        
        Args:
            query: Search query string
            store_id: Optional store ID to filter by (None for global search)
            
        Returns:
            For store-specific search: List of matching products
            For global search: Dictionary mapping store IDs to tuples of (category_path, list of products)
        """
        # Clean and validate query
        clean_query = query.strip()
        if not clean_query or len(clean_query) < 2:
            return {} if store_id is None else []
            
        # Default pagination
        pagination = PaginationParams(page=page, page_size=page_size)
        
        # Generate cache key based on whether this is a global or store-specific search
        cache_key = self.cache_service.generate_search_key(
            query=clean_query, 
            store_id=str(store_id) if store_id else None
        )
        cached_results = self.cache_service.get(cache_key)
        
        if cached_results:
            # return cached results
            return cached_results
        
        # Execute search based on whether this is global or store-specific
        if store_id:
            # Store-specific search
            all_products = self.product_repository.search_products_in_one_store(store_id, clean_query)
            query_complexity = 0.3  # Lower complexity for store-specific search

            # Apply pagination
            start_idx = pagination.offset
            end_idx = start_idx + pagination.limit
            paginated_products = all_products[start_idx:end_idx]
            
            # Record analytics if service is available
            if self.analytics_service:
                self.analytics_service.record_search(
                    query=clean_query,
                    store_id=store_id,
                    result_count=len(all_products)
                )
            
            # Cache results with adaptive TTL
            product_ids = [str(product.product_id) for product in all_products]
            self.cache_service.set_with_adaptive_timeout(
                key=cache_key,
                value=product_ids,
                complexity=query_complexity,
                result_size=len(all_products)
            )
            
            # Return paginated products and metadata
            metadata = {'total_products': len(all_products)}
            return paginated_products, metadata
        else:
            # Global search across all stores
            products_by_store = self.product_repository.search_products_in_all_stores(clean_query)
            query_complexity = 0.7  # Higher complexity for global search

            # Process all stores in a single loop (for pagination, analytics, and caching)
            paginated_results = {}
            total_products = 0
            cache_structure = {}
            metadata = {'store_counts': {}}
            
            for store_id, (category_path, products) in products_by_store.items():
                # Count total products for analytics
                total_products += len(products)
                
                # Prepare cache structure for this store
                cache_structure[str(store_id)] = {
                    'category_path': category_path,
                    'product_ids': [str(product.product_id) for product in products]
                }
                
                # Apply pagination to this store's products
                start_idx = pagination.offset
                end_idx = start_idx + pagination.limit
                paginated_store_products = products[start_idx:end_idx]
                
                # Only include stores that have products after pagination
                if paginated_store_products:
                    paginated_results[store_id] = (category_path, paginated_store_products)

                metadata['store_counts'][str(store_id)] = len(products)
            
            # Record analytics if service is available
            if self.analytics_service:
                self.analytics_service.record_search(
                    query=clean_query,
                    store_id=None,
                    result_count=total_products
                )
            
            self.cache_service.set_with_adaptive_timeout(
                key=cache_key,
                value=cache_structure,
                complexity=query_complexity,
                result_size=total_products
            )
            
            return paginated_results, metadata
            
   