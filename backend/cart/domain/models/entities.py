from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional
import uuid
from datetime import datetime

@dataclass
class CartItem:
    """Domain model representing a cart item"""
    store_product_id: uuid.UUID
    quantity: int
    # Optional product details for direct use in UI
    product_details: Optional[Dict[str, Any]] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    added_at: datetime = field(default_factory=datetime.now)
    
    def calculate_item_price_total(self) -> float:
        """Calculate the total price for this cart item (price × quantity)"""
        if self.product_details and 'price' in self.product_details:
            return self.product_details['price'] * self.quantity
        return 0

@dataclass
class Cart:
    """Domain model representing a shopping cart with product details"""
    user_id: uuid.UUID
    store_brand_id: uuid.UUID
    # Store details for direct use in UI
    store_brand_name: Optional[str] = None
    store_brand_slug: Optional[str] = None
    items: List[CartItem] = field(default_factory=list)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    
    def calculate_cart_price_total(self) -> float:
        """Calculate the total price of all items in the cart"""
        return sum(item.calculate_item_price_total() for item in self.items)
    
    def total_items(self) -> int:
        """Count the total number of items in the cart"""
        return sum(item.quantity for item in self.items)
    
    def is_empty(self) -> bool:
        """Check if the cart is empty"""
        return self.total_items() == 0
        
    def get_totals(self) -> Dict[str, Any]:
        """Get both total price and total items count
        
        Returns:
            Dictionary with total_price and total_items
        """
        return {
            'total_price': self.calculate_cart_price_total(),
            'total_items': self.total_items()
        }
