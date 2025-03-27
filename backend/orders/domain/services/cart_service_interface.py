from abc import ABC, abstractmethod
from typing import Optional, List, Dict, Any
from uuid import UUID
from dataclasses import dataclass


@dataclass
class CartItemInfo:
    """Minimal cart item information needed by the orders domain"""
    store_product_id: UUID
    quantity: int
    product_details: Optional[Dict[str, Any]] = None
    item_total_price: float


@dataclass
class CartInfo:
    """Minimal cart information needed by the orders domain"""
    id: UUID
    user_id: UUID
    store_brand_id: UUID
    store_brand_name: str
    store_brand_image_logo: str
    items: List[CartItemInfo]
    cart_total_price: float
    cart_total_items: int
    
    def is_empty(self) -> bool:
        """Check if the cart is empty"""
        return len(self.items) == 0


class CartServiceInterface(ABC):
    """Interface for cart-related operations needed by the orders domain"""
    
    @abstractmethod
    def get_cart(self, cart_id: UUID) -> Optional[CartInfo]:
        """Get minimal cart information by ID
        
        Args:
            cart_id: ID of the cart
            
        Returns:
            CartInfo if found, None otherwise
        """
        pass
        
    @abstractmethod
    def clear_cart(self, cart_id: UUID) -> bool:
        """Clear all items from a cart
        
        Args:
            cart_id: ID of the cart
            
        Returns:
            True if cart was cleared successfully, False otherwise
        """
        pass
