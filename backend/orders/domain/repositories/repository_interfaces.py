from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime

from orders.domain.models.entities import Order, OrderItem, OrderTimeline


class OrderRepository(ABC):
    """Interface for order repository"""
    
    @abstractmethod
    def get_by_id(self, order_id: UUID) -> Optional[Order]:
        """Get an order by ID"""
        pass
    
    @abstractmethod
    def list_by_user(self, user_id: UUID) -> List[Order]:
        """List all orders for a user"""
        pass
    
    @abstractmethod
    def list_by_store_brand(self, store_brand_id: UUID) -> List[Order]:
        """List all orders for a store brand"""
        pass
    
    @abstractmethod
    def list_by_status(self, status: str) -> List[Order]:
        """List all orders with a specific status"""
        pass
    
    @abstractmethod
    def create_with_items(self, 
                         user_id: UUID, 
                         store_brand_id: UUID, 
                         items_data: List[Dict[str, Any]],
                         cart_total_price: float = 0.0, 
                         cart_total_items: int = 0, 
                         status: str = 'pending',
                         payment_id: Optional[UUID] = None,
                         cart_id: Optional[UUID] = None,
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
        pass
    
    @abstractmethod
    def update_status(self, order_id: UUID, status: str) -> Optional[Order]:
        """Update order status"""
        pass

    @abstractmethod
    def add_notes_for_driver(self, order_id: UUID, notes_for_driver: str) -> Optional[Order]:
        """Update order notes for driver"""
        pass

    @abstractmethod
    def add_schedule_for(self, order_id: UUID, schedule_for: datetime) -> Optional[Order]:
        """Update order schedule for"""
        pass

    @abstractmethod
    def set_payment(self, order_id: UUID, payment_id: UUID) -> Optional[Order]:
        """Set payment for an order"""
        pass
        
    @abstractmethod
    def get_by_cart_id(self, cart_id: UUID) -> Optional[Order]:
        """Get an order by cart ID"""
        pass
    
    @abstractmethod
    def delete(self, order_id: UUID) -> bool:
        """Delete an order"""
        pass


class OrderItemRepository(ABC):
    """Interface for order item repository"""
    
    @abstractmethod
    def get_by_id(self, item_id: UUID) -> Optional[OrderItem]:
        """Get an order item by ID"""
        pass
    
    @abstractmethod
    def list_by_order(self, order_id: UUID) -> List[OrderItem]:
        """List all items for an order"""
        pass
    
    # @abstractmethod
    # def create(self, order_id: UUID, store_product_id: UUID, 
    #     quantity: int, product_name: str, product_image_url: str,
    #     product_image_thumbnail: str, product_price: float,
    #     product_description: str, item_total_price: float
    #     ) -> OrderItem:
    #     """Create a new order item with all product details"""
    #     pass
    
    @abstractmethod
    def delete(self, item_id: UUID) -> bool:
        """Delete an order item"""
        pass


class OrderTimelineRepository(ABC):
    """Interface for order timeline repository
    Use to track the history of order events"""
    
    @abstractmethod
    def get_by_id(self, timeline_id: UUID) -> Optional[OrderTimeline]:
        """Get a timeline event by ID"""
        pass
    
    @abstractmethod
    def list_by_order(self, order_id: UUID) -> List[OrderTimeline]:
        """List all timeline events for an order"""
        pass
    
    @abstractmethod
    def create(self, order_id: UUID, event_type: str, notes: Optional[str] = None) -> OrderTimeline:
        """Create a new timeline event"""
        pass
