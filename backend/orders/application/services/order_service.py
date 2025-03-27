import uuid
from typing import List, Tuple, Optional
from decimal import Decimal

from orders.domain.models.entities import Order
from orders.domain.repositories.repository_interfaces import (
    OrderRepository, OrderItemRepository, OrderTimelineRepository
)
from orders.domain.services.user_service_interface import UserServiceInterface
from orders.domain.services.cart_service_interface import CartServiceInterface
from core.domain_events.event_bus import event_bus
from core.domain_events.events import (
    OrderCreatedEvent, OrderStatusChangedEvent, OrderPaidEvent, CartCheckedOutEvent
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
        cart_id: Optional[uuid.UUID] = None
    ) -> Tuple[bool, str, Optional[Order]]:
        """
        Create a new order with items
        
        Args:
            user_id: ID of the user placing the order
            store_brand_id: ID of the store brand
            items: List of dicts with store_product_id, quantity, and price
            
        Returns:
            Tuple of (success, message, order)
        """
        # Validate user exists
        user_info = self.user_service.get_user_by_id(user_id)
        if not user_info:
            return False, "User not found", None
        
        # Calculate total amount
        total_amount = sum(Decimal(str(item['price'])) * item['quantity'] for item in items)
        
        # Create order
        order = self.order_repository.create(user_id, store_brand_id, float(total_amount), cart_id=cart_id)
        
        # Create order items
        for item in items:
            self.order_item_repository.create(
                order.id,
                item['store_product_id'],
                item['quantity'],
                item['price']
            )
        
        # Create timeline event
        self.order_timeline_repository.create(
            order.id,
            'created',
            f"Order created with {len(items)} items"
        )
        
        # Publish domain event
        event_bus.publish(OrderCreatedEvent.create(
            order_id=order.id,
            user_id=user_id,
            store_brand_id=store_brand_id,
            total_amount=float(total_amount),
            delivery_address=user_info.address or "No address provided"
        ))
        
        return True, "Order created successfully", order
        
    def create_order_from_cart(self, cart_id: uuid.UUID) -> Tuple[bool, str, Optional[Order]]:
        """
        Create a new order from an existing cart
        
        Args:
            cart_id: UUID of the cart to convert
            
        Returns:
            Tuple of (success, message, order)
        """
        # Get cart with items using the cart service
        cart = self.cart_service.get_cart(cart_id)
        if not cart:
            return False, "Cart not found", None
            
        if cart.is_empty():
            return False, "Cart is empty", None
        
        # Convert cart items to order items format
        items = []
        for item in cart.items:
            # Extract price from product_details or use a default
            price = 0
            if item.product_details and 'price' in item.product_details:
                price = item.product_details['price']
            
            items.append({
                'store_product_id': item.store_product_id,
                'quantity': item.quantity,
                'price': price
            })
        
        # Create order
        success, message, order = self.create_order(
            user_id=cart.user_id,
            store_brand_id=cart.store_brand_id,
            items=items,
            cart_id=cart_id
        )
        
        # Publish cart checked out event if order was created successfully
        if success:
            # Publish cart checked out event
            event_bus.publish(CartCheckedOutEvent.create(
                cart_id=cart_id,
                user_id=cart.user_id,
                store_brand_id=cart.store_brand_id,
                total_amount=float(order.total_amount)
            ))
            # Note: We no longer clear the cart here - it will be cleared when the order is processed
        
        return success, message, order
    
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
    
    def get_order_with_items(self, order_id: uuid.UUID) -> Optional[Order]:
        """
        Get an order with all its items
        
        Args:
            order_id: ID of the order
            
        Returns:
            Order with items or None if not found
        """
        order = self.order_repository.get_by_id(order_id)
        if not order:
            return None
        
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
        return self.order_repository.list_by_user(user_id)
    
    def cancel_order(self, order_id: uuid.UUID) -> Tuple[bool, str, Optional[Order]]:
        """
        Cancel an order
        
        Args:
            order_id: ID of the order to cancel
            
        Returns:
            Tuple of (success, message, order)
        """
        return self.update_order_status(order_id, 'cancelled')
    
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
            'payment_received',
            f"Payment {payment_id} received for order"
        )
        
        # Publish domain event
        event_bus.publish(OrderPaidEvent.create(
            order_id=order_id,
            payment_id=payment_id,
            amount=float(order.total_amount)
        ))
        
        # If order is in pending state, move to processing
        if updated_order.status == 'pending':
            return self.update_order_status(order_id, 'processing')
        
        return True, "Payment set for order", updated_order
