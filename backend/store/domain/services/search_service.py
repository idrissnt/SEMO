"""
Domain service for search-related operations.
"""
from abc import ABC, abstractmethod
from typing import List, TypeVar, Generic

T = TypeVar('T')  # Generic type for search results

class SearchStrategy(ABC, Generic[T]):
    """Abstract base class for search strategies"""
    
    @abstractmethod
    def search_products(self, query: str, **kwargs) -> List[T]:
        """
        Execute the search using this strategy
        
        Args:
            query: The search query
            **kwargs: Additional search parameters
            
        Returns:
            List of search results
        """
        pass
        

