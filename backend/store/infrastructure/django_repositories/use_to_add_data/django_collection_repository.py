from typing import List, Optional
import uuid
from datetime import datetime

from django.db import transaction
from django.contrib.auth import get_user_model

from store.domain.models.use_to_add_data.collection_entities import ProductCollectionBatch, CollectedProduct
from store.domain.repositories.use_to_add_data.collection_repository_interfaces import (
    ProductCollectionBatchRepository,
    CollectedProductRepository
)
from store.infrastructure.django_models.use_to_add_data.collection_models import (
    ProductCollectionBatchModel,
    CollectedProductModel
)
from store.infrastructure.django_models.orm_models import StoreBrandModel

User = get_user_model()

class DjangoProductCollectionBatchRepository(ProductCollectionBatchRepository):
    """Django ORM implementation of ProductCollectionBatchRepository"""
    
    def create_batch(self, batch: ProductCollectionBatch) -> ProductCollectionBatch:
        """Create a new collection batch"""
        try:
            store_brand = StoreBrandModel.objects.get(id=batch.store_brand_id)
            collector = User.objects.get(id=batch.collector_id)
            
            batch_model = ProductCollectionBatchModel.objects.create(
                id=batch.id,
                store_brand=store_brand,
                collector=collector,
                name=batch.name,
                status=batch.status,
                created_at=batch.created_at,
                completed_at=batch.completed_at
            )
            
            return self._batch_model_to_domain(batch_model)
        except (StoreBrandModel.DoesNotExist, User.DoesNotExist) as e:
            raise ValueError(f"Failed to create batch: {str(e)}")
    
    def get_batch_by_id(self, batch_id: uuid.UUID) -> Optional[ProductCollectionBatch]:
        """Get a collection batch by ID"""
        try:
            batch_model = ProductCollectionBatchModel.objects.get(id=batch_id)
            return self._batch_model_to_domain(batch_model)
        except ProductCollectionBatchModel.DoesNotExist:
            return None
    
    def get_batches_by_collector(self, collector_id: uuid.UUID) -> List[ProductCollectionBatch]:
        """Get all collection batches for a collector"""
        batch_models = ProductCollectionBatchModel.objects.filter(collector_id=collector_id)
        return [self._batch_model_to_domain(model) for model in batch_models]
    
    def update_batch_status(self, batch_id: uuid.UUID, status: str, completed_at: Optional[datetime] = None) -> bool:
        """Update the status of a collection batch"""
        try:
            update_data = {'status': status}
            if completed_at:
                update_data['completed_at'] = completed_at
                
            rows_updated = ProductCollectionBatchModel.objects.filter(id=batch_id).update(**update_data)
            return rows_updated > 0
        except Exception:
            return False
    
    def _batch_model_to_domain(self, model: ProductCollectionBatchModel) -> ProductCollectionBatch:
        """Convert ORM model to domain entity"""
        return ProductCollectionBatch(
            id=model.id,
            store_brand_id=model.store_brand.id,
            collector_id=model.collector.id,
            name=model.name,
            status=model.status,
            created_at=model.created_at,
            completed_at=model.completed_at
        )

class DjangoCollectedProductRepository(CollectedProductRepository):
    """Django ORM implementation of CollectedProductRepository"""
    
    def create_collected_product(self, product: CollectedProduct) -> CollectedProduct:
        """Create a new collected product"""
        try:
            batch_model = ProductCollectionBatchModel.objects.get(id=product.batch_id)
            
            product_model = CollectedProductModel.objects.create(
                id=product.id,
                batch=batch_model,
                name=product.name,
                slug=product.slug,
                quantity=product.quantity,
                unit=product.unit,
                description=product.description,
                category_name=product.category_name,
                category_path=product.category_path,
                category_slug=product.category_slug,
                price=product.price,
                price_per_unit=product.price_per_unit,
                image_url=product.image_url,
                notes=product.notes,
                status=product.status,
                error_message=product.error_message
            )
            
            return self._product_model_to_domain(product_model)
        except ProductCollectionBatchModel.DoesNotExist:
            raise ValueError(f"Batch with ID {product.batch_id} does not exist")
    
    def get_products_by_batch(self, batch_id: uuid.UUID) -> List[CollectedProduct]:
        """Get all collected products for a batch"""
        product_models = CollectedProductModel.objects.filter(batch_id=batch_id)
        return [self._product_model_to_domain(model) for model in product_models]
    
    def update_product_status(self, product_id: uuid.UUID, status: str, error_message: Optional[str] = None) -> bool:
        """Update the status of a collected product"""
        try:
            update_data = {'status': status}
            if error_message is not None:
                update_data['error_message'] = error_message
                
            rows_updated = CollectedProductModel.objects.filter(id=product_id).update(**update_data)
            return rows_updated > 0
        except Exception:
            return False
    
    @transaction.atomic
    def bulk_create_collected_products(self, products: List[CollectedProduct]) -> List[CollectedProduct]:
        """Create multiple collected products in a single operation"""
        if not products:
            return []
        
        try:
            # Verify batch exists
            batch_id = products[0].batch_id
            batch_model = ProductCollectionBatchModel.objects.get(id=batch_id)
            
            # Create models
            product_models = []
            for product in products:
                if product.batch_id != batch_id:
                    raise ValueError("All products must belong to the same batch")
                
                product_models.append(CollectedProductModel(
                    id=product.id,
                    batch=batch_model,
                    name=product.name,
                    slug=product.slug,
                    quantity=product.quantity,
                    unit=product.unit,
                    description=product.description,
                    category_name=product.category_name,
                    category_path=product.category_path,
                    category_slug=product.category_slug,
                    price=product.price,
                    price_per_unit=product.price_per_unit,
                    image_url=product.image_url,
                    notes=product.notes,
                    status=product.status,
                    error_message=product.error_message
                ))
            
            # Bulk create
            created_models = CollectedProductModel.objects.bulk_create(product_models)
            
            # Convert back to domain entities
            return [self._product_model_to_domain(model) for model in created_models]
        except ProductCollectionBatchModel.DoesNotExist:
            raise ValueError(f"Batch with ID {batch_id} does not exist")
    
    def _product_model_to_domain(self, model: CollectedProductModel) -> CollectedProduct:
        """Convert ORM model to domain entity"""
        return CollectedProduct(
            id=model.id,
            batch_id=model.batch_id,
            name=model.name,
            slug=model.slug,
            quantity=model.quantity,
            unit=model.unit,
            description=model.description,
            category_name=model.category_name,
            category_path=model.category_path,
            category_slug=model.category_slug,
            price=float(model.price),
            price_per_unit=float(model.price_per_unit),
            image_url=model.image_url,
            notes=model.notes,
            status=model.status,
            error_message=model.error_message
        )
