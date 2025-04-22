"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import delivery models from infrastructure layer
from core.infrastructure.django_models.welcom_asset_orm_model import (
    CompanyAssetModel as CompanyAsset,
    StoreAssetModel as StoreAsset,
    TaskAssetModel as TaskAsset
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['CompanyAsset', 'StoreAsset', 'TaskAsset']
