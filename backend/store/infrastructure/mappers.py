"""
Mapper functions to convert between ORM models and domain entities.
"""
from typing import Dict, Any
from store.models import StoreProduct

def store_product_to_product_details(store_product) -> Dict[str, Any]:
    """
    Convert a StoreProduct ORM model to a dictionary format compatible with ProductWithDetailsSerializer.
    
    Args:
        store_product: A StoreProduct ORM model instance with related objects loaded
        
    Returns:
        Dictionary with product details in the format expected by ProductWithDetailsSerializer
    """
    if not store_product:
        return None
        
    # Ensure related objects are loaded
    if not hasattr(store_product, 'store_brand') or not hasattr(store_product, 'product') or not hasattr(store_product, 'category'):
        store_product = StoreProduct.objects.select_related(
            'store_brand', 'product', 'category'
        ).get(id=store_product.id)
    
    return {
        # Store brand fields
        'store_brand_name': store_product.store_brand.name,
        'store_brand_image_logo': store_product.store_brand.image_logo.url if store_product.store_brand.image_logo else None,
        'store_brand_id': store_product.store_brand.id,
        
        # Category fields
        'category_name': store_product.category.name,
        'category_path': str(store_product.category.path),
        'category_slug': store_product.category.slug,
        
        # Product fields
        'product_name': store_product.product.name,
        'product_slug': store_product.product.slug,
        'quantity': store_product.product.quantity,
        'unit': store_product.product.unit,
        'description': store_product.product.description,
        'image_url': store_product.product.image_url.url if store_product.product.image_url else None,
        'image_thumbnail': store_product.product.image_thumbnail.url if hasattr(store_product.product, 'image_thumbnail') and store_product.product.image_thumbnail else None,
        
        # Store product fields
        'price': float(store_product.price),
        'price_per_unit': float(store_product.price_per_unit),
        
        # IDs
        'product_id': store_product.product.id,
        'category_id': store_product.category.id,
        'store_product_id': store_product.id,
    }
