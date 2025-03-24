"""
Domain service for search analytics.
"""
from abc import ABC, abstractmethod
from typing import Dict, List, Optional
import uuid

class SearchAnalyticsService(ABC):
    """Abstract base class for search analytics services"""
    
    @abstractmethod
    def record_search(self, query: str, store_id: Optional[uuid.UUID] = None, 
                     result_count: int = 0, user_id: Optional[uuid.UUID] = None) -> None:
        """Record a search query for analytics"""
        pass
    
    @abstractmethod
    def get_popular_searches(self, limit: int = 10, 
                            store_id: Optional[uuid.UUID] = None,
                            days: int = 7) -> List[Dict]:
        """Get most popular searches within a time period"""
        pass
    
    @abstractmethod
    def get_search_trends(self, days: int = 30, 
                         store_id: Optional[uuid.UUID] = None) -> List[Dict]:
        """Get search trends over time"""
        pass
    
    @abstractmethod
    def get_zero_result_searches(self, limit: int = 10,
                                store_id: Optional[uuid.UUID] = None,
                                days: int = 7) -> List[Dict]:
        """Get searches that returned zero results"""
        pass
