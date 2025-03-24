"""
Implementation of search analytics service.
"""
from typing import Dict, List, Optional
import uuid
from datetime import datetime, timedelta

from django.db import models
from django.utils import timezone

from store.domain.services.search_analytics_service import SearchAnalyticsService
from store.infrastructure.django_models.analytics_models import SearchQueryLog


class DjangoSearchAnalyticsService(SearchAnalyticsService):
    """Django ORM implementation of SearchAnalyticsService"""
    
    def record_search(self, query: str, store_id: Optional[uuid.UUID] = None, 
                     result_count: int = 0, user_id: Optional[uuid.UUID] = None) -> None:
        """Record a search query for analytics"""
        SearchQueryLog.objects.create(
            query=query,
            store_id=store_id,
            result_count=result_count,
            user_id=user_id,
            timestamp=timezone.now()
        )
    
    def get_popular_searches(self, limit: int = 10, 
                            store_id: Optional[uuid.UUID] = None,
                            days: int = 7) -> List[Dict]:
        """Get most popular searches within a time period"""
        time_threshold = timezone.now() - timedelta(days=days)
        
        # Base query
        query = SearchQueryLog.objects.filter(timestamp__gte=time_threshold)
        
        # Apply store filter if provided
        if store_id:
            query = query.filter(store_id=store_id)
        
        # Aggregate and order
        popular_searches = (
            query
            .values('query')
            .annotate(
                count=models.Count('id'),
                avg_results=models.Avg('result_count')
            )
            .order_by('-count')[:limit]
        )
        
        return list(popular_searches)
    
    def get_search_trends(self, days: int = 30, 
                         store_id: Optional[uuid.UUID] = None) -> List[Dict]:
        """Get search trends over time"""
        time_threshold = timezone.now() - timedelta(days=days)
        
        # Base query
        query = SearchQueryLog.objects.filter(timestamp__gte=time_threshold)
        
        # Apply store filter if provided
        if store_id:
            query = query.filter(store_id=store_id)
        
        # Group by day and count
        trends = (
            query
            .annotate(day=models.functions.TruncDay('timestamp'))
            .values('day')
            .annotate(
                count=models.Count('id'),
                avg_results=models.Avg('result_count')
            )
            .order_by('day')
        )
        
        return list(trends)
    
    def get_zero_result_searches(self, limit: int = 10,
                                store_id: Optional[uuid.UUID] = None,
                                days: int = 7) -> List[Dict]:
        """Get searches that returned zero results"""
        time_threshold = timezone.now() - timedelta(days=days)
        
        # Base query for zero results
        query = SearchQueryLog.objects.filter(
            timestamp__gte=time_threshold,
            result_count=0
        )
        
        # Apply store filter if provided
        if store_id:
            query = query.filter(store_id=store_id)
        
        # Aggregate and order
        zero_result_searches = (
            query
            .values('query')
            .annotate(count=models.Count('id'))
            .order_by('-count')[:limit]
        )
        
        return list(zero_result_searches)
