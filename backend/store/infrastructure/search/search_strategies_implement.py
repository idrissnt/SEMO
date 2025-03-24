"""
Implementation of search strategies for the product.
"""
from typing import List, Optional
import uuid

from django.db.models import(
    Q, F, Case, When, Value, 
    IntegerField, FloatField, 
    ExpressionWrapper
)
from django.contrib.postgres.search import(
    SearchQuery, SearchRank, TrigramSimilarity
)

from backend.store.domain.services.search_service import SearchStrategy
from backend.store.infrastructure.django_models.orm_models import(
    ProductModel, StoreProductModel
)

class CombinedSearchStrategy(SearchStrategy[uuid.UUID]):
    """
    Search strategy that combines full-text search, trigram similarity, and basic search
    in a single optimized database query
    """
    
    def __init__(self, min_query_length: int = 2):
        """
        Initialize the combined search strategy
        
        Args:
            min_query_length: Minimum query length for this strategy to be applicable
        """
        self.min_query_length = min_query_length
        
    def search_products(self, query: str, 
                        store_id: Optional[uuid.UUID] = None
                        ) -> List[uuid.UUID]:
        """
        Execute combined search using multiple techniques in a single query
        
        Args:
            query: The search query
            store_id: Optional UUID of store to search within
                
        Returns:
            List of matching product IDs ordered by relevance
        """
        # Clean the query
        clean_query = query.strip()
        
        # Create search query object for full-text search
        search_query = SearchQuery(clean_query, config='french')
        
        # Build base query with store filter if needed
        base_query = ProductModel.objects
        if store_id:
            product_ids = StoreProductModel.objects.filter(
                store_id=store_id
            ).values_list('product_id', flat=True)
            base_query = base_query.filter(id__in=product_ids)
        
        # Execute a single query that combines all search techniques
        matching_product_ids = base_query.annotate(
            # Full-text search rank
            fts_rank=SearchRank('search_vector', search_query),
            # Trigram similarity
            name_sim=TrigramSimilarity('name', clean_query),
            desc_sim=TrigramSimilarity('description', clean_query),
            # Combined trigram similarity with weights
            trgm_sim=ExpressionWrapper(
                (F('name_sim') * 0.7) + (F('desc_sim') * 0.3),
                output_field=FloatField()
            ),
            # Determine which strategy matched
            strategy_used=Case(
                # Full-text search hit
                When(fts_rank__gt=0.1, then=Value(1)),
                # Trigram similarity hit
                When(trgm_sim__gt=0.3, then=Value(2)),
                # Basic search hit
                When(
                    Q(name__icontains=clean_query) | 
                    Q(description__icontains=clean_query),
                    then=Value(3)
                ),
                default=Value(0),
                output_field=IntegerField()
            ),
            # Combined score for sorting
            relevance=Case(
                When(strategy_used=1, then=F('fts_rank') * 10),
                When(strategy_used=2, then=F('trgm_sim') * 5),
                When(strategy_used=3, then=Value(1)),
                default=Value(0),
                output_field=FloatField()
            )
        ).filter(
            # Include results from any strategy
            Q(fts_rank__gt=0.1) | 
            Q(trgm_sim__gt=0.3) | 
            Q(name__icontains=clean_query) |
            Q(description__icontains=clean_query)
        ).order_by(
            '-strategy_used', '-relevance'
        ).values_list('id', flat=True)
        
        return list(matching_product_ids)
