import uuid
from typing import List, Tuple, Optional
from decimal import Decimal
from datetime import datetime

from orders.domain.models.entities import Order
from orders.domain.models.constants import OrderStatus, OrderEventType
from orders.domain.repositories.repository_interfaces import (
    OrderRepository, OrderItemRepository, OrderTimelineRepository
)
from orders.domain.services.user_service_interface import UserServiceInterface
from orders.domain.services.cart_service_interface import CartServiceInterface
from core.domain_events.event_bus import event_bus
from orders.domain.events.orders_events import (
    OrderCreatedEvent, OrderStatusChangedEvent, OrderPaidEvent
)

class OrderApplicationService:
    """Application service for order management"""
    
    def __init__(
        self,
        order_repository: OrderRepository,
        order_item_repository: OrderItemRepository,
        order_timeline_repository: OrderTimelineRepository,
        user_service: UserServiceInterface,
        cart_service: CartServiceInterface
    ):
        self.order_repository = order_repository
        self.order_item_repository = order_item_repository
        self.order_timeline_repository = order_timeline_repository
        self.user_service = user_service
        self.cart_service = cart_service
    
    def create_order(
        self, 
        user_id: uuid.UUID, 
        store_brand_id: uuid.UUID, 
        items: List[dict],
        store_brand_name: str = "",
        store_brand_image_logo: str = "",
        user_store_distance: float = 0.0
    ) -> Tuple[bool, str, Optional[Order]]:
        """
        Create a new order with items without a creating a cart
        
        Args:
            user_id: ID of the user placing the order
            store_brand_id: ID of the store brand
            items: List of dicts with store_product details
            store_brand_name: Name of the store brand
            store_brand_image_logo: Logo URL of the store brand
            user_store_distance: Distance between user and store in meters
            
        Returns:
            Tuple of (success, message, order)
        """
        # Validate user exists
        user_info = self.user_service.get_user_by_id(user_id)
        if not user_info:
            return False, "User not found", None
        
        # Calculate total items and amount
        total_items = sum(item['quantity'] for item in items)
        total_amount = sum(Decimal(str(item['product_price'])) * item['quantity'] for item in items)
        
        # Create order with items in a single transaction
        order = self.order_repository.create_with_items(
            user_id=user_id, 
            store_brand_id=store_brand_id, 
            items_data=items,
            cart_total_price=float(total_amount),
            cart_total_items=total_items,
            status=OrderStatus.PENDING,
            payment_id=None,
            cart_id=None,
            store_brand_name=store_brand_name,
            store_brand_image_logo=store_brand_image_logo,
            user_store_distance=user_store_distance
        )
        
        # Create timeline event
        self.order_timeline_repository.create(
            order.id,
            OrderEventType.CREATED,
            f"Order created with {len(items)} items"
        )
        
        # Publish domain event
        event_bus.publish(OrderCreatedEvent.create(
            order_id=order.id
        ))
        
        return True, "Order created successfully", order
        
    def create_order_from_cart(self, cart_id: uuid.UUID, store_brand_address: str, user_store_distance: float = 0.0) -> Tuple[bool, str, Optional[Order]]:
        """
        Create a new order from an existing cart
        
        Args:
            cart_id: UUID of the cart to convert
            user_store_distance: Distance between user and store in meters
            
        Returns:
            Tuple of (success, message, order)
        """
        # Get cart with items using the cart service
        cart = self.cart_service.get_cart(cart_id)
        if not cart:
            return False, "Cart not found", None
            
        if cart.is_empty():
            return False, "Cart is empty", None
        
        # Validate user exists
        user_info = self.user_service.get_user_by_id(cart.user_id)
        if not user_info:
            return False, "User not found", None
        
        # Convert cart items to the format expected by create_with_items
        items_data = [
            {
                'store_product_id': item.store_product_id,
                'quantity': item.quantity,
                'product_name': item.product_name,
                'product_image_url': item.product_image_url,
                'product_image_thumbnail': item.product_image_thumbnail,
                'product_price': item.product_price,
                'product_description': item.product_description,
                'item_total_price': item.item_total_price
            } for item in cart.items
        ]
        
        # Create order with items in a single transaction
        order = self.order_repository.create_with_items(
            user_id=cart.user_id,
            store_brand_id=cart.store_brand_id,
            items_data=items_data,
            cart_total_price=cart.cart_total_price,
            cart_total_items=cart.cart_total_items,
            status=OrderStatus.PENDING,
            payment_id=None,
            cart_id=cart_id,
            store_brand_name=cart.store_brand_name,
            store_brand_image_logo=cart.store_brand_image_logo,
            user_store_distance=user_store_distance,
            store_brand_address=store_brand_address,
        )
        
        # Create timeline event
        self.order_timeline_repository.create(
            order.id,
            OrderEventType.CREATED,
            f"Order created from cart with {len(cart.items)} items"
        )
        
        # Publish domain event
        event_bus.publish(OrderCreatedEvent.create(
            order_id=order.id
        ))
        
        # Note: We no longer clear the cart here - it will be cleared when the order is processed
        
        return True, "Order created successfully", order
    
    def update_order_status(
        self, 
        order_id: uuid.UUID, 
        new_status: str
    ) -> Tuple[bool, str, Optional[Order]]:
        """
        Update the status of an order
        
        Args:
            order_id: ID of the order to update
            new_status: New status for the order
            
        Returns:
            Tuple of (success, message, order)
        """
        # Get order
        order = self.order_repository.get_by_id(order_id)
        if not order:
            return False, "Order not found", None
        
        # Validate status transition
        if not order.can_transition_to(new_status):
            return False, f"Cannot transition from {order.status} to {new_status}", None
        
        # Update status
        updated_order = self.order_repository.update_status(order_id, new_status)
        
        # Create timeline event
        self.order_timeline_repository.create(
            order_id,
            new_status,
            f"Order status updated to {new_status}"
        )
        
        # Publish domain event
        event_bus.publish(OrderStatusChangedEvent.create(
            order_id=order_id,
            previous_status=order.status,
            new_status=new_status
        ))
        
        return True, f"Order status updated to {new_status}", updated_order
    
    def add_notes_for_driver(self, order_id: uuid.UUID, notes_for_driver: str) -> Tuple[bool, str, Optional[Order]]:

        # Add notes for driver
        updated_order = self.order_repository.add_notes_for_driver(order_id, notes_for_driver)
        
        if not updated_order:
            return False, "Failed to add notes for driver", None

        return True, f"Notes for driver added: {notes_for_driver}", updated_order
    
    def add_scheduled_time(self, order_id: uuid.UUID, scheduled_time: datetime) -> Tuple[bool, str, Optional[Order]]:

        # Add scheduled time
        updated_order = self.order_repository.add_schedule_for(order_id, scheduled_time)
        
        if not updated_order:
            return False, "Failed to add scheduled time", None

        return True, f"Scheduled time added: {scheduled_time}", updated_order

    def get_order_with_items(self, order_id: uuid.UUID) -> Optional[Order]:
        """
        Get an order with all its items
        
        Args:
            order_id: ID of the order
            
        Returns:
            Order with items or None if not found
        """
        # Get order
        order = self.order_repository.get_by_id(order_id)
        if not order:
            return None

        # Validate user exists
        user_info = self.user_service.get_user_by_id(order.user_id)
        if not user_info:
            return "User not found"
        
        # Get items for the order
        items = self.order_item_repository.list_by_order(order_id)
        order.items = items
        
        return order
    
    def get_order_history(self, user_id: uuid.UUID) -> List[Order]:
        """
        Get order history for a user
        
        Args:
            user_id: ID of the user
            
        Returns:
            List of orders for the user
        """
        # Validate user exists
        user_info = self.user_service.get_user_by_id(user_id)
        if not user_info:
            return "User not found"

        # Get orders for the user
        orders = self.order_repository.list_by_user(user_id)
        if not orders:
            return []

        return orders
    
    def cancel_order(self, order_id: uuid.UUID) -> Tuple[bool, str, Optional[Order]]:
        """
        Cancel an order
        
        Args:
            order_id: ID of the order to cancel
            
        Returns:
            Tuple of (success, message, order)
        """
        return self.update_order_status(order_id, OrderStatus.CANCELLED)
    
    def set_order_payment(
        self, 
        order_id: uuid.UUID, 
        payment_id: uuid.UUID
    ) -> Tuple[bool, str, Optional[Order]]:
        """
        Set payment for an order
        
        Args:
            order_id: ID of the order
            payment_id: ID of the payment
            
        Returns:
            Tuple of (success, message, order)
        """
        # Get order
        order = self.order_repository.get_by_id(order_id)
        if not order:
            return False, "Order not found", None
        
        # Set payment
        updated_order = self.order_repository.set_payment(order_id, payment_id)
        
        # Create timeline event
        self.order_timeline_repository.create(
            order_id,
            OrderEventType.PAYMENT_RECEIVED,
            f"Payment {payment_id} received for order"
        )
        
        # Publish domain event
        event_bus.publish(OrderPaidEvent.create(
            order_id=order_id,
            payment_id=payment_id,
            amount=float(order.cart_total_price),
            cart_id=order.cart_id,
            delivery_address=order.user.address
        ))
        
        # If order is in pending state, move to processing
        if updated_order.status == OrderStatus.PENDING:
            return self.update_order_status(order_id, OrderStatus.PROCESSING)
        
        return True, "Payment set for order", updated_order
