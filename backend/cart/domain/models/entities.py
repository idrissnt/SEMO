from dataclasses import dataclass, field
from typing import List, Dict, Any
import uuid
from datetime import datetime

@dataclass
class CartItem:
    """Domain model representing a cart item"""
    store_product_id: uuid.UUID
    quantity: int
    product_name: str 
    product_image_thumbnail: str 
    product_image_url: str
    product_price: float
    product_description: str
    item_total_price: float = 0.0
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    added_at: datetime = field(default_factory=datetime.now)

    def calculate_item_price_total(self) -> float:
        """Calculate the total price for this cart item (price × quantity)"""
        self.item_total_price = self.product_price * self.quantity
        return self.item_total_price

@dataclass
class Cart:
    """Domain model representing a shopping cart with product details"""
    user_id: uuid.UUID
    store_brand_id: uuid.UUID
    store_brand_name: str
    store_brand_logo: str
    items: List[CartItem] = field(default_factory=list)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    # Cart totals for direct use in UI and validation
    cart_total_price: float = 0.0
    cart_total_items: int = 0
    
    def calculate_cart_price_total(self) -> float:
        """Calculate the total price of all items in the cart"""
        return sum(item.calculate_item_price_total() for item in self.items)
    
    def calculate_cart_total_items(self) -> int:
        """Count the total number of items in the cart"""
        return sum(item.quantity for item in self.items)
    
    def is_empty(self) -> bool:
        """Check if the cart is empty"""
        return self.calculate_cart_total_items() == 0
        
    def get_cart_totals(self) -> Dict[str, Any]:
        """Get both total price and total items count
        
        Returns:
            Dictionary with total_price and total_items
        """
        return {
            'total_price': self.calculate_cart_price_total(),
            'total_items': self.calculate_cart_total_items()
        }
