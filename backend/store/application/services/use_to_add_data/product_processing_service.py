
from typing import List, Optional, Tuple
import uuid

from store.domain.repositories.use_to_add_data.collection_repository_interfaces import (
    ProductCollectionBatchRepository,
    CollectedProductRepository
)
from store.domain.repositories.use_to_add_data.product_processing_repository import ProductProcessingRepository
from store.domain.models.entities import StoreProduct, Product, Category

class ProductProcessingService:
    """Application service for product processing-related use cases"""
    
    def __init__(
        self,
        batch_repository: ProductCollectionBatchRepository,
        product_repository: CollectedProductRepository,
        product_processing_repository: ProductProcessingRepository
    ):
        self.batch_repository = batch_repository
        self.product_repository = product_repository
        self.product_processing_repository = product_processing_repository
    
    def process_batch(self, batch_id: uuid.UUID) -> Tuple[int, int, List[str]]:
        """Process a completed batch to create actual products
        
        This method will:
        1. Get all products in the batch
        2. For each product, create/update the corresponding domain entities
        3. Update the status of the batch and products
        
        Args:
            batch_id: UUID of the batch to process
            
        Returns:
            Tuple of (success_count, error_count, error_messages)
        """
        # Validate batch exists and is completed
        batch = self.batch_repository.get_batch_by_id(batch_id)
        if not batch:
            raise ValueError(f"Batch with ID {batch_id} does not exist")
        
        if batch.status != 'completed':
            raise ValueError(f"Cannot process batch with status '{batch.status}'")
        
        # Get all products in the batch
        collected_products = self.product_repository.get_products_by_batch(batch_id)
        
        # Process each product
        success_count = 0
        error_count = 0
        error_messages = []
        
        # Process each collected product and create/update records in main product tables
        for product in collected_products:
            try:
                # Step 1: Find or create the category
                category = self._find_or_create_category(
                    name=product.category_name,
                    slug=product.category_slug,
                    path=product.category_path,
                    store_brand_id=batch.store_brand_id
                )
                
                # Step 2: Find or create the product
                main_product = self._find_or_create_product(
                    name=product.name,
                    slug=product.slug,
                    quantity=product.quantity,
                    unit=product.unit,
                    description=product.description,
                    image_url=product.image_url
                )
                
                # Step 3: Find or create the store product
                store_product = self._find_or_create_store_product(
                    store_brand_id=batch.store_brand_id,
                    product_id=main_product.id,
                    category_id=category.id,
                    price=product.price,
                    price_per_unit=product.price_per_unit
                )
                
                # Step 4: Update product status to processed
                self.product_repository.update_product_status(
                    product_id=product.id,
                    status='processed'
                )
                success_count += 1
            except Exception as e:
                # Update product status to error
                self.product_repository.update_product_status(
                    product_id=product.id,
                    status='error',
                    error_message=str(e)
                )
                error_count += 1
                error_messages.append(f"Error processing product {product.name}: {str(e)}")
        
        # Update batch status
        if error_count == 0:
            self.batch_repository.update_batch_status(batch_id, 'processed')
        
        return success_count, error_count, error_messages
    
    def _find_or_create_category(self, name: str, 
                                 slug: str,
                                 path: str,
                                 store_brand_id: uuid.UUID) -> Category:
        """Find or create a category based on name and path"""
        # Try to find existing category by path
        existing_category = self.product_processing_repository.find_category_by_path(path)
        
        if existing_category:
            return existing_category
        
        # Create new category
        # Parse the path to determine parent-child relationships
        path_parts = path.strip('.').split('.')
        
        # Create category
        new_category = Category(
            name=name,
            path=path,
            slug=slug,
            store_brand_id=store_brand_id
        )
        
        # Save the category
        return self.product_processing_repository.create_category(new_category)
    
    def _find_or_create_product(self, 
                                name: str, 
                                slug: str,
                                quantity: int,
                                unit: str,
                                description: str, 
                                image_url: str,
                                ) -> Product:
        """Find or create a product based on name and category"""
        
        # Try to find by name and category
        existing_product = self.product_processing_repository.find_product_by_name_and_category(
            name=name,
        )
        if existing_product:
            return existing_product
        
        # Create new product
        new_product = Product(
            name=name,
            slug=slug,
            quantity=quantity,
            unit=unit,
            description=description,
            image_url=image_url
        )
        
        # Save the product
        return self.product_processing_repository.create_product(new_product)
    
    def _find_or_create_store_product(self, 
                                      store_brand_id: uuid.UUID, 
                                      product_id: uuid.UUID, 
                                      category_id: uuid.UUID, 
                                      price: float, 
                                      price_per_unit: float) -> StoreProduct:
        """Find or create a store product"""
        # Try to find existing store product
        existing_store_product = self.product_processing_repository.find_store_product(
            store_brand_id=store_brand_id,
            product_id=product_id,
            category_id=category_id
        )
        
        if existing_store_product:
            # Update price if it changed
            if (existing_store_product.price != price or 
                existing_store_product.price_per_unit != price_per_unit):
                existing_store_product.price = price
                existing_store_product.price_per_unit = price_per_unit
                return self.product_processing_repository.update_store_product(existing_store_product)
            return existing_store_product
        
        # Create new store product
        new_store_product = StoreProduct(
            store_brand_id=store_brand_id,
            product_id=product_id,
            category_id=category_id,
            price=price,
            price_per_unit=price_per_unit
        )
        
        # Save the store product
        return self.product_processing_repository.create_store_product(new_store_product)
