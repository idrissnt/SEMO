from typing import List, Optional
from uuid import UUID

from decimal import Decimal

from orders.domain.models.entities import OrderItem
from orders.domain.repositories.repository_interfaces import OrderItemRepository
from orders.infrastructure.django_models.orm_models import OrderItemModel


class DjangoOrderItemRepository(OrderItemRepository):
    """Django ORM implementation of OrderItemRepository"""
    
    def get_by_id(self, item_id: UUID) -> Optional[OrderItem]:
        """Get an order item by ID"""
        try:
            item_model = OrderItemModel.objects.get(id=item_id)
            return self._to_entity(item_model)
        except OrderItemModel.DoesNotExist:
            return None
    
    def list_by_order(self, order_id: UUID) -> List[OrderItem]:
        """List all items for an order"""
        item_models = OrderItemModel.objects.filter(order_id=order_id)
        return [self._to_entity(item_model) for item_model in item_models]
    
    def delete(self, item_id: UUID) -> bool:
        """Delete an order item"""
        try:
            item_model = OrderItemModel.objects.get(id=item_id)
            item_model.delete()
            return True
        except OrderItemModel.DoesNotExist:
            return False
    
    def _to_entity(self, item_model: OrderItemModel) -> OrderItem:
        """Convert ORM model to domain entity"""
        # Get product details from store product
        product_name = ""
        product_image_url = ""
        product_image_thumbnail = ""
        product_description = ""
        
        try:
            store_product = item_model.store_product
            product = store_product.product
            product_name = product.name
            product_image_url = product.image_url if hasattr(product, 'image_url') else ""
            product_image_thumbnail = product.image_thumbnail if hasattr(product, 'image_thumbnail') else ""
            product_description = product.description if hasattr(product, 'description') else ""
        except Exception:
            pass
            
        return OrderItem(
            id=item_model.id,
            order_id=item_model.order.id,
            store_product_id=item_model.store_product.id,
            quantity=item_model.quantity,
            product_name=product_name,
            product_image_url=product_image_url,
            product_image_thumbnail=product_image_thumbnail,
            product_price=float(item_model.product_price),
            product_description=product_description,
            item_total_price=float(item_model.item_total_price)
        )
