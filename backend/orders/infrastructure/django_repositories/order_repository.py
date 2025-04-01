from typing import List, Optional, Dict, Any
from uuid import UUID
from decimal import Decimal
from django.db import transaction

from orders.domain.models.entities import Order, OrderItem
from orders.domain.repositories.repository_interfaces import OrderRepository
from orders.infrastructure.django_models.orm_models import OrderModel, OrderItemModel
from .order_utils import order_model_to_domain, calculate_order_fee_and_total


class DjangoOrderRepository(OrderRepository):
    """Django ORM implementation of OrderRepository"""
    
    def create_with_items(self, 
                         user_id: UUID, 
                         store_brand_id: UUID, 
                         items_data: List[Dict[str, Any]],
                         cart_total_price: float = 0.0, 
                         cart_total_items: int = 0, 
                         status: str = 'pending',
                         payment_id: UUID = None,
                         cart_id: UUID = None,
                         store_brand_name: str = "",
                         store_brand_image_logo: str = "",
                         store_brand_address: str = "",
                         user_store_distance: float = 0.0
                         ) -> Order:
        """Create a new order with its items in a single transaction
        
        Args:
            user_id: User ID
            store_brand_id: Store brand ID
            items_data: List of item data dictionaries
            cart_total_price: Total price of items
            cart_total_items: Total number of items
            status: Order status
            payment_id: Payment ID if already paid
            cart_id: Cart ID if created from cart
            store_brand_name: Store brand name
            store_brand_image_logo: Store brand logo URL
            store_brand_address: Store brand address
            user_store_distance: Distance between user and store in meters
            
        Returns:
            Order domain entity with items
        """
        with transaction.atomic():
            # Create the order model
            order_model = OrderModel.objects.create(
                user_id=user_id,
                store_brand_id=store_brand_id,
                cart_total_price=cart_total_price,
                cart_total_items=cart_total_items,
                status=status,
                payment_id=payment_id,
                cart_id=cart_id,
                user_store_distance=user_store_distance,
                store_brand_address=store_brand_address,
            )
            
            # Create order items in bulk
            order_items = []
            item_models = []
            
            for item_data in items_data:
                # Create ORM model
                item_model = OrderItemModel(
                    order_id=order_model.id,
                    store_product_id=item_data.get('store_product_id'),
                    quantity=item_data.get('quantity'),
                    product_price=Decimal(str(item_data.get('product_price'))),
                    item_total_price=Decimal(str(item_data.get('product_price'))) * item_data.get('quantity')
                )
                item_models.append(item_model)
                
                # Create domain entity
                order_item = OrderItem(
                    order_id=order_model.id,
                    store_product_id=item_data.get('store_product_id'),
                    quantity=item_data.get('quantity'),
                    product_name=item_data.get('product_name'),
                    product_image_url=item_data.get('product_image_url'),
                    product_image_thumbnail=item_data.get('product_image_thumbnail'),
                    product_price=item_data.get('product_price'),
                    product_description=item_data.get('product_description'),
                    item_total_price=item_data.get('product_price') * item_data.get('quantity')
                )
                order_items.append(order_item)
            
            # Bulk create the item models
            OrderItemModel.objects.bulk_create(item_models)
            
            # Calculate fee and total price
            calculate_order_fee_and_total(order_model)
            
            # Create a domain entity with the provided store brand details and items
            return Order(
                id=order_model.id,
                user_id=user_id,
                store_brand_id=store_brand_id,
                cart_id=cart_id,
                store_brand_name=store_brand_name,
                store_brand_image_logo=store_brand_image_logo,
                store_brand_address=store_brand_address,
                cart_total_price=cart_total_price,
                cart_total_items=cart_total_items,
                status=status,
                payment_id=payment_id,
                fee=float(order_model.fee),
                order_total_price=float(order_model.order_total_price),
                user_store_distance=user_store_distance,
                items=order_items
            )
        
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
    
    def update_status(self, order_id: UUID, status: str) -> Optional[Order]:
        """Update order status"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            order_model.status = status                    
            order_model.save()
            return self._to_entity(order_model)
        except OrderModel.DoesNotExist:
            return None

    def add_schedule_for(self, order_id: UUID, schedule_for: datetime) -> Optional[Order]:
        """Update order schedule for"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            order_model.schedule_for = schedule_for
            order_model.save()
            return self._to_entity(order_model)
        except OrderModel.DoesNotExist:
            return None

    def add_notes_for_driver(self, order_id: UUID, notes_for_driver: str) -> Optional[Order]:
        """Update order notes for driver"""
        try:
            order_model = OrderModel.objects.get(id=order_id)
            order_model.notes_for_driver = notes_for_driver
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
        # Use the utility function for consistent conversion
        return order_model_to_domain(order_model)
