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

    def create(self, order_id: UUID, store_product_id: UUID, 
        quantity: int, item_total_price: float, product_details: dict = None
        ) -> OrderItem:
        """Create a new order item"""

        # Calculate item price from store product
        from store.models import StoreProduct
        try:
            store_product = StoreProduct.objects.get(id=store_product_id)
            item_price = store_product.price
        except StoreProduct.DoesNotExist:
            item_price = Decimal('0.00')
            
        item_model = OrderItemModel.objects.create(
            order_id=order_id,
            store_product_id=store_product_id,
            quantity=quantity,
            item_price=item_price,
            item_total_price=Decimal(str(item_total_price))
        )
        return self._to_entity(item_model)
    
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
        product_details = None
        try:
            store_product = item_model.store_product
            product_details = {
                'id': str(store_product.id),
                'name': store_product.product.name,
                'price': float(store_product.price),
                'image': store_product.product.image_url if hasattr(store_product.product, 'image_url') else None
            }
        except Exception:
            pass
            
        return OrderItem(
            id=item_model.id,
            order_id=item_model.order.id,
            store_product_id=item_model.store_product.id,
            quantity=item_model.quantity,
            item_total_price=float(item_model.item_total_price),
            product_details=product_details
        )
