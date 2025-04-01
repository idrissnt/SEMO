"""
Utility functions for order repositories
"""
import logging
import uuid
from decimal import Decimal
from typing import Optional

from orders.domain.models.entities import Order, OrderItem
from orders.infrastructure.django_models.orm_models import OrderModel, OrderItemModel

logger = logging.getLogger(__name__)

def order_model_to_domain(order_model: OrderModel) -> Order:
    """Convert order ORM model to domain entity
    
    Args:
        order_model: ORM model
        
    Returns:
        Domain entity
    """
    # Get store brand details
    try:
        store_brand_name = order_model.store_brand.name
        store_brand_image_logo = order_model.store_brand.logo_url
    except:
        store_brand_name = "Unknown"
        store_brand_image_logo = ""
    
    # Convert order items
    order_items = []
    for item_model in order_model.order_items.all():
        order_item = OrderItem(
            id=item_model.id,
            order_id=order_model.id,
            store_product_id=item_model.store_product.id,
            quantity=item_model.quantity,
            product_name=item_model.store_product.product.name,
            product_image_url=item_model.store_product.product.image_url,
            product_image_thumbnail=item_model.store_product.product.image_thumbnail,
            product_price=float(item_model.product_price),
            product_description=item_model.store_product.product.description,
            item_total_price=float(item_model.item_total_price)
        )
        order_items.append(order_item)
    
    # Create domain entity
    return Order(
        id=order_model.id,
        user_id=order_model.user.id,
        store_brand_id=order_model.store_brand.id,
        store_brand_address=order_model.store_brand_address,
        cart_id=order_model.cart_id,
        store_brand_name=store_brand_name,
        store_brand_image_logo=store_brand_image_logo,
        items=order_items,
        cart_total_price=float(order_model.cart_total_price),
        cart_total_items=order_model.cart_total_items,
        status=order_model.status,
        notes_for_driver=order_model.notes_for_driver,
        schedule_for=order_model.schedule_for,
        fee=float(order_model.fee),
        order_total_price=float(order_model.order_total_price),
        user_store_distance=float(order_model.user_store_distance),
        payment_id=order_model.payment.id if order_model.payment else None
    )

def calculate_order_fee_and_total(order_model: OrderModel) -> bool:
    """Calculate order fee and total price using domain entity logic
    
    Args:
        order_model: OrderModel instance
        
    Returns:
        True if successful, False otherwise
    """
    try:
        # Convert to domain entity
        order_entity = order_model_to_domain(order_model)
        
        # Use domain entity method to calculate
        order_entity.calculate_order_total_price()
        
        # Update ORM model with calculated values
        order_model.fee = Decimal(str(order_entity.fee))
        order_model.order_total_price = Decimal(str(order_entity.order_total_price))
        order_model.total_time = Decimal(str(order_entity.total_time))
        order_model.save(update_fields=['fee', 'order_total_price', 'total_time'])
        
        return True
    except Exception as e:
        logger.error(f"Error calculating order fee and total: {str(e)}")
        return False
