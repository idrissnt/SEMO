"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from store.infrastructure.django_models.orm_models import (
    StoreBrandModel as StoreBrand,
    CategoryModel as Category,
    ProductModel as Product,
    StoreProductModel as StoreProduct,
)

from store.infrastructure.django_models.use_to_add_data.collection_models import (
    ProductCollectionBatchModel as ProductCollectionBatch,
    CollectedProductModel as CollectedProduct
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['StoreBrand', 'Category', 'Product', 'StoreProduct', 'ProductCollectionBatch', 'CollectedProduct']
