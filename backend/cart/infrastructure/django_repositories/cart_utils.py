"""
Utility functions for cart repositories
"""
import logging
import uuid
from decimal import Decimal
from typing import Optional, Dict, Any

from cart.domain.models.entities import Cart, CartItem
from cart.infrastructure.django_models.orm_models import CartModel, CartItemModel

logger = logging.getLogger(__name__)

def cart_model_to_domain(cart_model: CartModel) -> Cart:
    """Convert cart ORM model to domain entity
    
    Args:
        cart_model: ORM model
        
    Returns:
        Domain entity
    """
    cart_items = []
    for item in cart_model.cart_items.all():
        cart_item = CartItem(
            id=item.id,
            store_product_id=item.store_product.id,
            quantity=item.quantity,
            product_name=item.store_product.product.name,
            product_image_thumbnail=item.store_product.product.image_thumbnail,
            product_image_url=item.store_product.product.image_url,
            product_price=float(item.product_price),
            product_description=item.store_product.product.description,
            item_total_price=float(item.item_total_price)
        )
        cart_items.append(cart_item)
    
    # Get store brand details
    try:
        store_brand_name = cart_model.store_brand.name
        store_brand_logo = cart_model.store_brand.logo_url
    except:
        store_brand_name = "Unknown"
        store_brand_logo = ""
    
    return Cart(
        id=cart_model.id,
        user_id=cart_model.user_id,
        store_brand_id=cart_model.store_brand_id,
        store_brand_name=store_brand_name,
        store_brand_logo=store_brand_logo,
        items=cart_items,
        cart_total_price=float(cart_model.cart_total_price),
        cart_total_items=cart_model.cart_total_items
    )

def update_cart_totals(cart_id: uuid.UUID) -> bool:
    """Update cart totals using domain entity methods
    
    Args:
        cart_id: UUID of the cart
        
    Returns:
        True if successful, False otherwise
    """
    try:
        cart_model = CartModel.objects.get(id=cart_id)
        cart_entity = cart_model_to_domain(cart_model)
        
        # Use domain entity methods for calculations
        cart_model.cart_total_price = Decimal(str(cart_entity.calculate_cart_price_total()))
        cart_model.cart_total_items = cart_entity.calculate_cart_total_items()
        cart_model.save(update_fields=['cart_total_price', 'cart_total_items'])
        return True
    except CartModel.DoesNotExist:
        logger.error(f"Cart with ID {cart_id} not found")
        return False
    except Exception as e:
        logger.error(f"Error updating cart totals: {str(e)}")
        return False

def calculate_item_total_price(item_model: CartItemModel) -> Decimal:
    """Calculate item total price using domain entity
    
    Args:
        item_model: ORM model
        
    Returns:
        Item total price as Decimal
    """
    # Simple calculation without creating a domain entity
    # This avoids having to fetch all the product details just for a calculation
    return item_model.product_price * item_model.quantity


def get_product_details(store_product_id: uuid.UUID) -> Optional[Dict[str, Any]]:
    """Get product details for display
    
    Args:
        store_product_id: UUID of the store product
        
    Returns:
        Dictionary with product details if found, None otherwise
    """
    try:
        from store.infrastructure.mappers import store_product_to_product_details
        
        # Get the store product with all related objects
        store_product = StoreProduct.objects.select_related(
            'store_brand', 'product', 'category'
        ).get(id=store_product_id)
        
        # Use the mapper to get full product details
        return store_product_to_product_details(store_product)
    except StoreProduct.DoesNotExist:
        logger.warning(f"Store product with ID {store_product_id} not found")
        return None
    except Exception as e:
        logger.error(f"Error getting product details: {str(e)}")
        return None
