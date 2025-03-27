from dataclasses import dataclass
from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime

@dataclass
class OrderItem:
    """Order item domain entity"""
    id: UUID
    order_id: UUID
    store_product_id: UUID
    quantity: int
    item_total_price: float
    product_details: Optional[Dict[str, Any]] = None

@dataclass
class Order:
    """Order domain entity"""
    id: UUID
    user_id: UUID
    store_brand_id: UUID
    store_brand_name: str
    store_brand_image_logo: str
    cart_total_price: float
    cart_total_items: int
    status: str
    payment_id: Optional[UUID] = None
    cart_id: Optional[UUID] = None
    items: List[OrderItem] = None
    
    def can_transition_to(self, new_status: str) -> bool:
        """Check if the order can transition to the new status"""
        status_order = ['pending', 'processing', 'delivered', 'cancelled']
        
        # Special case: orders can be cancelled from any state except 'delivered'
        if new_status == 'cancelled' and self.status != 'delivered':
            return True
            
        # Normal case: can only move forward in the workflow
        try:
            current_index = status_order.index(self.status)
            new_index = status_order.index(new_status)
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
    id: UUID
    order_id: UUID
    event_type: str  # 'created', 'payment_received', 'processing', 'out_for_delivery', 'delivered', 'cancelled'
    timestamp: datetime
    notes: Optional[str] = None
