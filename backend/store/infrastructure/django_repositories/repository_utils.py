from django.db.models import QuerySet
from typing import List
from backend.store.domain.models.entities import ProductWithDetails
from backend.store.infrastructure.django_models.orm_models import StoreProductModel

class QueryUtils:
    """Utility methods for optimized queries across repositories"""
    
    @staticmethod
    def build_optimized_query(**filters) -> QuerySet:
        """Build an optimized query for StoreProductModel with the given filters"""
        return StoreProductModel.objects.filter(
            **filters
        ).select_related(
            'store_brand', 'product', 'category'
        ).only(
            # Store fields
            'store_brand__name', 'store_brand__image_logo',
            
            # StoreProduct fields
            'id', 'price', 'price_per_unit',
            
            # Product fields
            'product__id', 'product__name', 'product__slug', 
            'product__quantity', 'product__unit', 'product__description',
            'product__image_url', 'product__image_thumbnail',
            
            # Category fields
            'category__id', 'category__name', 'category__path', 'category__slug'
        )
    
    @staticmethod
    def build_product_details_from_queryset(queryset) -> List[ProductWithDetails]:
        """Convert a queryset of StoreProductModel to a list of ProductWithDetails"""
        result = []
        for sp in queryset:
            product = sp.product
            category = sp.category
            store_brand = sp.store_brand
            
            # Create the combined entity with only the fields you want
            product_with_details = ProductWithDetails(
                # Store fields
                store_name=store_brand.name,
                store_image_logo=store_brand.image_logo.url,
                store_id=store_brand.id,
                
                # Category fields
                category_name=category.name if category else '',
                category_path=category.path if category else '',
                category_slug=category.slug if category else '',
                
                # Product fields
                product_name=product.name,
                product_slug=product.slug,
                quantity=product.quantity,
                unit=product.unit,
                description=product.description,
                image_url=product.image_url.url if product.image_url else '',
                image_thumbnail=product.image_thumbnail.url if hasattr(product, 'image_thumbnail') and product.image_thumbnail else '',
                
                # Store product fields
                price=float(sp.price),
                price_per_unit=float(sp.price_per_unit),
                
                # IDs
                product_id=product.id,
                category_id=category.id if category else None,
                store_product_id=sp.id
            )
            
            result.append(product_with_details)
        
        return result