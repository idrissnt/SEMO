from dataclasses import dataclass
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from dataclasses import field
import uuid

from orders.domain.models.constants import OrderStatus, OrderEventType

@dataclass
class OrderItem:
    """Order item domain entity"""
    order_id: UUID
    store_product_id: UUID
    quantity: int
    product_name: str
    product_image_url: str
    product_image_thumbnail: str
    product_price: float
    product_description: str
    item_total_price: float
    id: UUID = field(default_factory=uuid.uuid4)

@dataclass
class Order:
    """Order domain entity"""
    user_id: UUID
    store_brand_id: UUID
    cart_id: UUID
    store_brand_name: str
    store_brand_image_logo: str
    store_brand_address: str
    items: List[OrderItem]
    cart_total_price: float
    cart_total_items: int
    status: str
    fee: float
    order_total_price: float
    total_time: float
    schedule_for: Optional[datetime] = None
    notes_for_driver: Optional[str] = None
    user_store_distance: float # Distance in meters
    payment_id: Optional[UUID] = None
    id: UUID = field(default_factory=uuid.uuid4)

    def calculate_order_total_price(self) -> float:
        """Calculate the total price with fee
           we estimate that 
           - 60 euros of groceries take allmost 30 mins to make in store
           - 2 000 meters of distance take allmost 20 mins to drive (go and back)
           - for a driver 50 minutes of his/her time is 10 euros

           so, for each order we have to find the time (minutes) 
           - based on the price of the order (time_based_on_price)
           - based on the distance of the user from the store (time_based_on_distance)

           and then combine them to get the total minutes
           a driver will take to deliver the order 
           since 50 minutes of his/her time is 10 euros, 
           we will use this to calculate the fee
           
        """
        time_based_on_price = 30 * (self.cart_total_price / 60)
        time_based_on_distance = 20 * (self.user_store_distance / 2000)
        total_time = time_based_on_price + time_based_on_distance
        fee = 10 * (total_time / 50)
        self.fee = fee
        self.order_total_price = self.cart_total_price + fee
        self.total_time = total_time
        return self.order_total_price
    
    def can_transition_to(self, new_status: str) -> bool:
        """Check if the order can transition to the new status"""
        # Special case: orders can be cancelled from any state except 'delivered'
        if new_status == OrderStatus.CANCELLED and self.status != OrderStatus.DELIVERED:
            return True
            
        # Normal case: can only move forward in the workflow
        try:
            current_index = OrderStatus.PROGRESSION.index(self.status)
            new_index = OrderStatus.PROGRESSION.index(new_status)
            return new_index > current_index
        except ValueError:
            return False  # Invalid status
    
    def is_paid(self) -> bool:
        """Check if the order has been paid"""
        return self.payment_id is not None
    
    def can_be_delivered(self) -> bool:
        """Check if the order can be delivered"""
        return self.status == 'processing' and self.is_paid()


@dataclass
class OrderTimeline:
    """Order timeline event for tracking order history"""
    order_id: UUID
    event_type: str  # Use values from OrderEventType
    timestamp: datetime
    notes: Optional[str] = None
    id: UUID = field(default_factory=uuid.uuid4)
    
    def is_valid_event_type(self) -> bool:
        """Check if the event type is valid"""
        return self.event_type in OrderEventType.ALL
