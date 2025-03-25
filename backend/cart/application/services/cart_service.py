from typing import List, Optional, Tuple, Dict, Any
import uuid
import logging

from cart.domain.models.entities import Cart, CartItem
from cart.domain.repositories.repository_interfaces import CartRepository, CartItemRepository

logger = logging.getLogger(__name__)

class CartApplicationService:
    """Application service for cart-related use cases"""
    
    def __init__(self, cart_repository: CartRepository, cart_item_repository: CartItemRepository):
        self.cart_repository = cart_repository
        self.cart_item_repository = cart_item_repository
    
    def get_cart(self, cart_id: uuid.UUID = None, user_id: uuid.UUID = None, 
                store_brand_id: uuid.UUID = None, include_product_details: bool = True) -> Optional[Cart]:
        """Get a cart with optional product details
        
        Args:
            cart_id: UUID of the cart (optional)
            user_id: UUID of the user (optional)
            store_brand_id: UUID of the store brand (optional)
            include_product_details: Whether to include product details
            
        Returns:
            Cart object if found, None otherwise
        """
        return self.cart_repository.get_cart(
            cart_id=cart_id,
            user_id=user_id,
            store_brand_id=store_brand_id,
            include_product_details=include_product_details
        )
    
    def get_all_carts_for_user(self, user_id: uuid.UUID, include_product_details: bool = True) -> List[Cart]:
        """Get all carts for a user
        
        Args:
            user_id: UUID of the user
            include_product_details: Whether to include product details
            
        Returns:
            List of Cart objects
        """
        return self.cart_repository.get_all_for_user(user_id, include_product_details)
    
    def get_or_create_cart(self, user_id: uuid.UUID, store_brand_id: uuid.UUID) -> Cart:
        """Get an existing cart or create a new one
        
        Args:
            user_id: UUID of the user
            store_brand_id: UUID of the store brand
            
        Returns:
            Cart object
        """
        return self.cart_repository.create_or_get_cart(user_id, store_brand_id)
    
    def clear_cart(self, cart_id: uuid.UUID) -> Tuple[bool, str]:
        """Remove all items from a cart
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            Tuple of (success, error_message)
            success is True if cart was cleared successfully
            error_message is empty if successful, otherwise contains the error
        """
        try:
            success = self.cart_repository.clear(cart_id)
            if success:
                return True, ""
            else:
                return False, "Failed to clear cart"
        except Exception as e:
            logger.error(f"Error clearing cart: {str(e)}")
            return False, f"Error clearing cart: {str(e)}"
    
    def add_item_to_cart(self, user_id: uuid.UUID, store_brand_id: uuid.UUID, 
                         store_product_id: uuid.UUID, quantity: int = 1,
                         product_details: Dict[str, Any] = None) -> Tuple[Optional[CartItem], str]:
        """Add an item to a cart
        
        Args:
            user_id: UUID of the user
            store_brand_id: UUID of the store brand
            store_product_id: UUID of the store product
            quantity: Quantity of the item to add
            product_details: Optional product details for display
            
        Returns:
            Tuple of (cart_item, error_message)
            cart_item is a CartItem object if successful, None otherwise
            error_message is empty if successful, otherwise contains the error
        """
        try:
            # Get or create cart
            cart = self.get_or_create_cart(user_id, store_brand_id)
            
            # Add item to cart
            result_item, error = self.cart_item_repository.add_item(
                cart_id=cart.id,
                store_product_id=store_product_id,
                quantity=quantity,
                product_details=product_details
            )
            
            if not result_item:
                return None, error
                
            return result_item, ""
        except Exception as e:
            logger.error(f"Error adding item to cart: {str(e)}")
            return None, f"Error adding item to cart: {str(e)}"
    
    def update_item_quantity(self, item_id: uuid.UUID, quantity: int) -> Tuple[Optional[CartItem], str, bool]:
        """Update the quantity of a cart item
        
        Args:
            item_id: UUID of the cart item
            quantity: New quantity
            
        Returns:
            Tuple of (cart_item, error_message, was_deleted)
            cart_item is a CartItem object if successful and not deleted, None otherwise
            error_message is empty if successful, otherwise contains the error
            was_deleted is True if the item was deleted, False otherwise
        """
        try:
            # Update quantity
            cart_item, was_deleted = self.cart_item_repository.update_item_quantity(item_id, quantity)
            
            if was_deleted:
                return None, "", True
            
            if cart_item:
                return cart_item, "", False
            else:
                return None, "Failed to update item quantity", False
        except Exception as e:
            logger.error(f"Error updating item quantity: {str(e)}")
            return None, f"Error updating item quantity: {str(e)}", False
    
    def remove_item_from_cart(self, item_id: uuid.UUID) -> Tuple[bool, str]:
        """Remove an item from a cart
        
        Args:
            item_id: UUID of the cart item
            
        Returns:
            Tuple of (success, error_message)
            success is True if item was removed successfully
            error_message is empty if successful, otherwise contains the error
        """
        try:
            success = self.cart_item_repository.remove_item(item_id)
            if success:
                return True, ""
            else:
                return False, "Failed to remove item from cart"
        except Exception as e:
            logger.error(f"Error removing item from cart: {str(e)}")
            return False, f"Error removing item from cart: {str(e)}"
            
    def delete_cart(self, cart_id: uuid.UUID) -> Tuple[bool, str]:
        """Delete a cart
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            Tuple of (success, error_message)
            success is True if cart was deleted successfully
            error_message is empty if successful, otherwise contains the error
        """
        try:    
            success = self.cart_repository.delete(cart_id)
            if success:
                return True, ""
            else:
                return False, "Failed to delete cart"
        except Exception as e:
            logger.error(f"Error deleting cart: {str(e)}")
            return False, f"Error deleting cart: {str(e)}"
