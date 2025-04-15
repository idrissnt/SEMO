from abc import ABC, abstractmethod
from typing import Dict, List, Tuple, Optional
import uuid
from ..models.entities import StoreBrand, ProductWithDetails

class StoreBrandRepository(ABC):
    """Repository interface for StoreBrand domain model"""

    @abstractmethod
    def get_all_store_brands(self) -> List[StoreBrand]:
        """Get all store brands
        
        Returns:
            List of StoreBrand objects
        """
        pass

    
class ProductRepository(ABC):
    """Repository interface for Product domain model""" 
        
    @abstractmethod
    def search_products_in_all_stores(self, 
            query: str) -> Dict[uuid.UUID, Tuple[str, List[ProductWithDetails]]]:

        """Search for products with price information by query string in all stores
        
        Args:
            query: The search query string
            
        Returns:
            Dictionary of store brand IDs to Tuple of category path and list of ProductWithDetails objects
        """
        pass
        
    @abstractmethod
    def search_products_in_one_store(self, store_brand_id: uuid.UUID, 
            query: str) -> List[ProductWithDetails]:
        """Search for products with price information by query string in a store
        
        Args:
            store_brand_id: UUID of the store brand to search in
            query: The search query string
            
        Returns:
            List of ProductWithDetails objects
        """
        pass
        
    @abstractmethod
    def get_autocomplete_suggestions(self, partial_query: str, 
            store_brand_id: Optional[uuid.UUID] = None, 
            limit: int = 10) -> List[str]:
        """Get autocomplete suggestions for a partial query string
        
        Args:
            partial_query: The partial search query typed by the user
            store_brand_id: Optional UUID of the store brand to limit suggestions to
            limit: Maximum number of suggestions to return
            
        Returns:
            List of product name suggestions that match the partial query
        """
        pass

class StoreProductRepository(ABC):
    """Base interface for StoreProduct persistence"""
    
    @abstractmethod
    def get_store_products_with_details(self, store_brand_id: uuid.UUID) -> List[ProductWithDetails]:
        """Get all store products for a store brand with details
        
        Args:
            store_brand_id: UUID of the store brand to get products for
            
        Returns:
            List of ProductWithDetails objects
        """
        pass

    @abstractmethod
    def get_products_in_category_for_store(self, store_brand_id: uuid.UUID, 
            category_path: Optional[str] = None) -> List[ProductWithDetails]:
        """Get all products in a category for a store brand with details
        
        Args:
            store_brand_id: UUID of the store brand to get products for
            category_path: Path of the category to filter by
            
        Returns:
            List of ProductWithDetails objects
        """
        pass
    
        
