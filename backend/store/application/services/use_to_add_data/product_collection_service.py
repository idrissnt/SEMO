from typing import List, Dict, Any
import uuid
from datetime import datetime

from store.domain.models.use_to_add_data.collection_entities import ProductCollectionBatch, CollectedProduct
from store.domain.repositories.use_to_add_data.collection_repository_interfaces import (
    ProductCollectionBatchRepository,
    CollectedProductRepository
)

class ProductCollectionService:
    """Application service for product collection-related use cases"""
    
    def __init__(
        self,
        batch_repository: ProductCollectionBatchRepository,
        product_repository: CollectedProductRepository
    ):
        self.batch_repository = batch_repository
        self.product_repository = product_repository
    
    def create_collection_batch(
        self,
        store_brand_id: uuid.UUID,
        collector_id: uuid.UUID,
        name: str
    ) -> ProductCollectionBatch:
        """Create a new product collection batch
        
        Args:
            store_brand_id: UUID of the store brand
            collector_id: UUID of the collector (user)
            name: Name of the batch
            
        Returns:
            The created ProductCollectionBatch
        """
        batch = ProductCollectionBatch(
            store_brand_id=store_brand_id,
            collector_id=collector_id,
            name=name,
            status='draft'
        )
        
        return self.batch_repository.create_batch(batch)
    
    def get_collector_batches(self, collector_id: uuid.UUID) -> List[ProductCollectionBatch]:
        """Get all batches for a collector
        
        Args:
            collector_id: UUID of the collector
            
        Returns:
            List of ProductCollectionBatch objects
        """
        return self.batch_repository.get_batches_by_collector(collector_id)
    
    def update_batch_status(
        self,
        batch_id: uuid.UUID,
        status: str
    ) -> bool:
        """Update the status of a batch
        
        Args:
            batch_id: UUID of the batch
            status: New status value
            
        Returns:
            True if update was successful, False otherwise
        """
        completed_at = None
        if status == 'completed':
            completed_at = datetime.now()
            
        return self.batch_repository.update_batch_status(
            batch_id=batch_id,
            status=status,
            completed_at=completed_at
        )
    
    def add_product_to_batch(
        self,
        batch_id: uuid.UUID,
        product_data: Dict[str, Any]
    ) -> CollectedProduct:
        """Add a product to a collection batch
        
        Args:
            batch_id: UUID of the batch
            product_data: Dictionary containing product data
            
        Returns:
            The created CollectedProduct
        """
        # Validate batch exists and is in correct status
        batch = self.batch_repository.get_batch_by_id(batch_id)
        if not batch:
            raise ValueError(f"Batch with ID {batch_id} does not exist")
        
        if batch.status not in ['draft', 'in_progress']:
            raise ValueError(f"Cannot add products to batch with status '{batch.status}'")
        
        # If batch is in draft status, update to in_progress
        if batch.status == 'draft':
            self.batch_repository.update_batch_status(batch_id, 'in_progress')
        
        # Create collected product
        product = CollectedProduct(
            batch_id=batch_id,
            name=product_data.get('name', ''),
            slug=product_data.get('slug', ''),
            quantity=product_data.get('quantity', 0),
            unit=product_data.get('unit', ''),
            description=product_data.get('description', ''),
            image_url=product_data.get('image_url', ''),
            category_name=product_data.get('category_name', ''),
            category_path=product_data.get('category_path', ''),
            category_slug=product_data.get('category_slug', ''),
            price=product_data.get('price', 0.0),
            price_per_unit=product_data.get('price_per_unit', 0.0),
            # image_data=product_data.get('image_data'),
            notes=product_data.get('notes')
        )
        
        return self.product_repository.create_collected_product(product)
    
    def get_batch_products(self, batch_id: uuid.UUID) -> List[CollectedProduct]:
        """Get all products in a batch
        
        Args:
            batch_id: UUID of the batch
            
        Returns:
            List of CollectedProduct objects
        """
        return self.product_repository.get_products_by_batch(batch_id)
    
    def bulk_add_products(
        self,
        batch_id: uuid.UUID,
        products_data: List[Dict[str, Any]]
    ) -> List[CollectedProduct]:
        """Add multiple products to a batch in a single operation
        
        Args:
            batch_id: UUID of the batch
            products_data: List of dictionaries containing product data
            
        Returns:
            List of created CollectedProduct objects
        """
        # Validate batch exists and is in correct status
        batch = self.batch_repository.get_batch_by_id(batch_id)
        if not batch:
            raise ValueError(f"Batch with ID {batch_id} does not exist")
        
        if batch.status not in ['draft', 'in_progress']:
            raise ValueError(f"Cannot add products to batch with status '{batch.status}'")
        
        # If batch is in draft status, update to in_progress
        if batch.status == 'draft':
            self.batch_repository.update_batch_status(batch_id, 'in_progress')
        
        # Create collected products
        products = []
        for data in products_data:
            product = CollectedProduct(
                batch_id=batch_id,
                name=data.get('name', ''),
                slug=data.get('slug', ''),
                quantity=data.get('quantity', 0),
                unit=data.get('unit', ''),
                description=data.get('description', ''),
                image_url=data.get('image_url', ''),
                category_name=data.get('category_name', ''),
                category_path=data.get('category_path', ''),
                category_slug=data.get('category_slug', ''),
                price=data.get('price', 0.0),
                price_per_unit=data.get('price_per_unit', 0.0),
                # image_data=data.get('image_data'),
                notes=data.get('notes')
            )
            products.append(product)
        
        return self.product_repository.bulk_create_collected_products(products)
    