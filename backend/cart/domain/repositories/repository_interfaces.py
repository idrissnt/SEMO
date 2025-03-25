from abc import ABC, abstractmethod
from typing import List, Optional, Tuple, Dict, Any
import uuid

from ..models.entities import Cart, CartItem

class CartRepository(ABC):
    """Repository interface for Cart domain model
    
    Responsible for operations on the cart entity itself, such as
    creating, retrieving, updating, and deleting carts.
    """
    
    @abstractmethod
    def get_cart(self, cart_id: uuid.UUID = None, user_id: uuid.UUID = None, 
               store_brand_id: uuid.UUID = None, include_product_details: bool = True) -> Optional[Cart]:
        """Get a cart with options to include product details
        
        At least one of cart_id, or (user_id and store_brand_id) must be provided.
        
        Args:
            cart_id: UUID of the cart (optional)
            user_id: UUID of the user (optional)
            store_brand_id: UUID of the store brand (optional)
            include_product_details: Whether to include product details
            
        Returns:
            Cart object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_all_for_user(self, user_id: uuid.UUID, include_product_details: bool = True) -> List[Cart]:
        """Get all carts for a user
        
        Args:
            user_id: UUID of the user
            include_product_details: Whether to include product details
            
        Returns:
            List of Cart objects
        """
        pass
    
    @abstractmethod
    def create_or_get_cart(self, user_id: uuid.UUID, store_brand_id: uuid.UUID) -> Cart:
        """Create a new cart or get existing one
        
        Args:
            user_id: UUID of the user
            store_brand_id: UUID of the store brand
            
        Returns:
            Cart object
        """
        pass
    
    @abstractmethod
    def delete(self, cart_id: uuid.UUID) -> bool:
        """Delete a cart
        
        Args:
            cart_id: UUID of the cart to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def clear(self, cart_id: uuid.UUID) -> bool:
        """Remove all items from a cart
        
        Args:
            cart_id: UUID of the cart to clear
            
        Returns:
            True if successful, False otherwise
        """
        pass


class CartItemRepository(ABC):
    """Repository interface for CartItem domain model
    
    Responsible for operations on cart items, such as adding,
    updating, and removing items from a cart.
    """    
    
    @abstractmethod
    def get_store_brand_for_product(self, store_product_id: uuid.UUID) -> Optional[uuid.UUID]:
        """Get the store brand ID for a store product
        
        Args:
            store_product_id: UUID of the store product
            
        Returns:
            UUID of the store brand if found, None otherwise
        """
        pass
    
    @abstractmethod
    def add_item(self, cart_id: uuid.UUID, store_product_id: uuid.UUID, 
                quantity: int, product_details: Dict[str, Any] = None) -> CartItem:
        """Add an item to a cart
        
        Args:
            cart_id: UUID of the cart
            store_product_id: UUID of the store product
            quantity: Quantity of the item
            product_details: Optional product details for display
            
        Returns:
            Created or updated CartItem
        """
        pass
    
    @abstractmethod
    def get_item(self, item_id: uuid.UUID) -> Optional[CartItem]:
        """Get a cart item by ID
        
        Args:
            item_id: UUID of the cart item
            
        Returns:
            CartItem if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_items_for_cart(self, cart_id: uuid.UUID, include_product_details: bool = True) -> List[CartItem]:
        """Get all items for a cart
        
        Args:
            cart_id: UUID of the cart
            include_product_details: Whether to include product details
            
        Returns:
            List of CartItem objects
        """
        pass
    
    @abstractmethod
    def update_item_quantity(self, item_id: uuid.UUID, quantity: int) -> Tuple[Optional[CartItem], bool]:
        """Update the quantity of a cart item
        
        If quantity is less than 1, the item should be removed.
        
        Args:
            item_id: UUID of the cart item
            quantity: New quantity
            
        Returns:
            Tuple of (CartItem, was_deleted)
            CartItem is the updated item if not deleted, None if deleted
            was_deleted is True if the item was deleted, False otherwise
        """
        pass
    
    @abstractmethod
    def remove_item(self, item_id: uuid.UUID) -> bool:
        """Remove an item from a cart
        
        Args:
            item_id: UUID of the cart item to remove
            
        Returns:
            True if successful, False otherwise
        """
        pass
