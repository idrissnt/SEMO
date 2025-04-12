from abc import ABC, abstractmethod
from typing import Optional
import uuid

from ...models.entities import Category, Product, StoreProduct

class ProductProcessingRepository(ABC):
    """Repository interface for processing collected products into permanent storage"""
    
    @abstractmethod
    def find_category_by_path(self, category_path: str) -> Optional[Category]:
        """Find a category by its path
        
        Args:
            category_path: Path of the category to find
            
        Returns:
            Category object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create_category(self, category: Category) -> Category:
        """Create a new category
        
        Args:
            category: Category object to create
            
        Returns:
            Created Category object
        """
        pass
    
    @abstractmethod
    def find_product_by_name(self, name: str) -> Optional[Product]:
        """Find a product by its name
        
        Args:
            name: Name of the product to find
            
        Returns:
            Product object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create_product(self, product: Product) -> Product:
        """Create a new product
        
        Args:
            product: Product object to create
            
        Returns:
            Created Product object
        """
        pass
    
    @abstractmethod
    def find_store_product(self, 
                           store_brand_id: uuid.UUID, 
                           product_id: uuid.UUID, 
                           category_id: uuid.UUID) -> Optional[StoreProduct]:
        """Find a store product by store brand and product
        
        Args:
            store_brand_id: UUID of the store brand
            product_id: UUID of the product
            category_id: UUID of the category
            
        Returns:
            StoreProduct object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def update_store_product(self, store_product: StoreProduct) -> StoreProduct:
        """Update an existing store product
        
        Args:
            store_product: StoreProduct object to update
            
        Returns:
            Updated StoreProduct object
        """
        pass
    
    @abstractmethod
    def create_store_product(self, store_product: StoreProduct) -> StoreProduct:
        """Create a new store product
        
        Args:
            store_product: StoreProduct object to create
            
        Returns:
            Created StoreProduct object
        """
        pass
