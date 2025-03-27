from typing import List, Optional
from uuid import UUID
from decimal import Decimal
from datetime import datetime

from orders.domain.models.entities import Order, OrderItem
from orders.domain.repositories.repository_interfaces import OrderRepository
from orders.infrastructure.django_models.orm_models import OrderModel


class DjangoOrderRepository(OrderRepository):
    """Django ORM implementation of OrderRepository"""
    
    def get_by_id(self, order_id: UUID) -> Optional[Order]:
        """Get an order by ID"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            return self._to_entity(order_model)
        except OrderModel.DoesNotExist:
            return None
    
    def list_by_user(self, user_id: UUID) -> List[Order]:
        """List all orders for a user"""
        order_models = OrderModel.objects.filter(user_id=user_id)
        return [self._to_entity(order_model) for order_model in order_models]
    
    def list_by_store_brand(self, store_brand_id: UUID) -> List[Order]:
        """List all orders for a store brand"""
        order_models = OrderModel.objects.filter(store_brand_id=store_brand_id)
        return [self._to_entity(order_model) for order_model in order_models]
    
    def list_by_status(self, status: str) -> List[Order]:
        """List all orders with a specific status"""
        order_models = OrderModel.objects.filter(status=status)
        return [self._to_entity(order_model) for order_model in order_models]
    
    def create(self, user_id: UUID, 
                    store_brand_id: UUID, 
                    cart_total_price: float, 
                    cart_total_items: int, 
                    status: str = 'pending',
                    payment_id: UUID = None,
                    cart_id: UUID = None
                    ) -> Order:
        """Create a new order"""
        order_model = OrderModel.objects.create(
            user_id=user_id,
            store_brand_id=store_brand_id,
            cart_total_price=cart_total_price,
            cart_total_items=cart_total_items,
            status=status,
            payment_id=payment_id,
            cart_id=cart_id,
        )
        return self._to_entity(order_model)
    
    def update_status(self, order_id: UUID, status: str) -> Optional[Order]:
        """Update order status"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            order_model.status = status                    
            order_model.save()
            return self._to_entity(order_model)
        except OrderModel.DoesNotExist:
            return None

    def delete(self, order_id: UUID) -> bool:
        """Delete an order"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            order_model.delete()
            return True
        except OrderModel.DoesNotExist:
            return False
    
    def set_payment(self, order_id: UUID, payment_id: UUID) -> Optional[Order]:
        """Set payment for an order"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            order_model.payment_id = payment_id
            order_model.save()
            return self._to_entity(order_model)
        except OrderModel.DoesNotExist:
            return None
            
    def get_by_cart_id(self, cart_id: UUID) -> Optional[Order]:
        """Get an order by cart ID"""
        try:
            order_model = OrderModel.objects.get(cart_id=cart_id)
            return self._to_entity(order_model)
        except OrderModel.DoesNotExist:
            return None
    
    def _to_entity(self, order_model: OrderModel) -> Order:
        """Convert ORM model to domain entity"""

        from .order_item_repository import DjangoOrderItemRepository
        item_to_entity = DjangoOrderItemRepository()._to_entity
        
        # Get store brand details
        store_brand_name = ""
        store_brand_image_logo = ""
        try:
            store_brand_name = order_model.store_brand.name
            store_brand_image_logo = order_model.store_brand.image_logo
        except Exception:
            pass
            
        return Order(
            id=order_model.id,
            user_id=order_model.user.id,
            store_brand_id=order_model.store_brand.id,
            store_brand_name=store_brand_name,
            store_brand_image_logo=store_brand_image_logo,
            cart_total_price=float(order_model.cart_total_price),
            cart_total_items=order_model.cart_total_items,
            status=order_model.status,
            payment_id=order_model.payment.id if order_model.payment else None,
            cart_id=order_model.cart_id,
            items=[item_to_entity(item) for item in order_model.order_items.all()]
        )
