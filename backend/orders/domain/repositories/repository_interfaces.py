from abc import ABC, abstractmethod
from typing import List, Optional
from decimal import Decimal
from uuid import UUID

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
    def create(self, user_id: UUID, 
    store_brand_id: UUID, total_amount: float, cart_id: Optional[UUID] = None) -> Order:
        """Create a new order"""
        pass
    
    @abstractmethod
    def update_status(self, order_id: UUID, status: str) -> Optional[Order]:
        """Update order status"""
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
    
    @abstractmethod
    def create(self, order_id: UUID, product_image_url: str, 
        product_name: str, quantity: int, item_price: Decimal, 
        item_total_price: Decimal, product_details: dict,
        ) -> OrderItem:
        """Create a new order item"""
        pass
    
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
