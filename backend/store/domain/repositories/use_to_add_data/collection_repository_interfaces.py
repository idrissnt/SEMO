from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from datetime import datetime
from store.domain.models.use_to_add_data.collection_entities import ProductCollectionBatch, CollectedProduct

class ProductCollectionBatchRepository(ABC):
    """Repository interface for ProductCollectionBatch domain model"""
    
    @abstractmethod
    def create_batch(self, batch: ProductCollectionBatch) -> ProductCollectionBatch:
        """Create a new collection batch
        
        Args:
            batch: The ProductCollectionBatch to create
            
        Returns:
            The created ProductCollectionBatch with ID
        """
        pass
    
    @abstractmethod
    def get_batch_by_id(self, batch_id: uuid.UUID) -> Optional[ProductCollectionBatch]:
        """Get a collection batch by ID
        
        Args:
            batch_id: UUID of the batch to retrieve
            
        Returns:
            The ProductCollectionBatch if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_batches_by_collector(self, collector_id: uuid.UUID) -> List[ProductCollectionBatch]:
        """Get all collection batches for a collector
        
        Args:
            collector_id: UUID of the collector
            
        Returns:
            List of ProductCollectionBatch objects
        """
        pass
    
    @abstractmethod
    def update_batch_status(self, batch_id: uuid.UUID, status: str, completed_at: Optional[datetime] = None) -> bool:
        """Update the status of a collection batch
        
        Args:
            batch_id: UUID of the batch to update
            status: New status value
            completed_at: Completion timestamp (if status is 'completed')
            
        Returns:
            True if update was successful, False otherwise
        """
        pass

class CollectedProductRepository(ABC):
    """Repository interface for CollectedProduct domain model"""
    
    @abstractmethod
    def create_collected_product(self, product: CollectedProduct) -> CollectedProduct:
        """Create a new collected product
        
        Args:
            product: The CollectedProduct to create
            
        Returns:
            The created CollectedProduct with ID
        """
        pass
    
    @abstractmethod
    def get_products_by_batch(self, batch_id: uuid.UUID) -> List[CollectedProduct]:
        """Get all collected products for a batch
        
        Args:
            batch_id: UUID of the batch
            
        Returns:
            List of CollectedProduct objects
        """
        pass
    
    @abstractmethod
    def update_product_status(self, product_id: uuid.UUID, status: str, error_message: Optional[str] = None) -> bool:
        """Update the status of a collected product
        
        Args:
            product_id: UUID of the product to update
            status: New status value
            error_message: Error message if status is 'error'
            
        Returns:
            True if update was successful, False otherwise
        """
        pass
    
    @abstractmethod
    def bulk_create_collected_products(self, products: List[CollectedProduct]) -> List[CollectedProduct]:
        """Create multiple collected products in a single operation
        
        Args:
            products: List of CollectedProduct objects to create
            
        Returns:
            List of created CollectedProduct objects with IDs
        """
        pass
