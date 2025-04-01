from typing import List, Optional, Tuple
import uuid
import logging
from django.utils import timezone
from django.core.cache import cache

from cart.domain.models.entities import Cart, CartItem
from cart.domain.repositories.repository_interfaces import CartRepository, CartItemRepository

logger = logging.getLogger(__name__)

class CartApplicationService:
    """Application service for cart-related use cases"""
    
    def __init__(self, cart_repository: CartRepository, cart_item_repository: CartItemRepository):
        self.cart_repository = cart_repository
        self.cart_item_repository = cart_item_repository
    
    def get_cart(self, cart_id: uuid.UUID = None, user_id: uuid.UUID = None, 
                store_brand_id: uuid.UUID = None) -> Optional[Cart]:
        """Get a cart
        
        Args:
            cart_id: UUID of the cart (optional)
            user_id: UUID of the user (optional)
            store_brand_id: UUID of the store brand (optional)
            
        Returns:
            Cart object if found, None otherwise
        """
        return self.cart_repository.get_cart(
            cart_id=cart_id,
            user_id=user_id,
            store_brand_id=store_brand_id
        )
    
    def get_all_carts_for_user(self, user_id: uuid.UUID) -> List[Cart]:
        """Get all carts for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Cart objects
        """
        return self.cart_repository.get_all_for_user(user_id)
    
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
                         store_product_id: uuid.UUID, quantity: int = 1) -> Tuple[Optional[CartItem], str]:
        """Add an item to a cart
        
        Args:
            user_id: UUID of the user
            store_brand_id: UUID of the store brand
            store_product_id: UUID of the store product
            quantity: Quantity of the item to add
            
        Returns:
            Tuple of (cart_item, error_message)
            cart_item is a CartItem object if successful, None otherwise
            error_message is empty if successful, otherwise contains the error
        """
        try:
            # Get or create cart
            cart = self.get_or_create_cart(user_id, store_brand_id)
            
            # Add item to cart using the cart repository's aggregate method
            cart, cart_item = self.cart_repository.add_item_to_cart(
                cart_id=cart.id,
                store_product_id=store_product_id,
                quantity=quantity
            )
            
            if not cart or not cart_item:
                return None, "Failed to add item to cart"
                
            # Return the cart item from the result tuple (cart, item)
            return cart, ""
        except Exception as e:
            logger.error(f"Error adding item to cart: {str(e)}")
            return None, f"Error adding item to cart: {str(e)}"
    
    def update_item_quantity(self, cart_id: uuid.UUID, 
                             item_id: uuid.UUID, quantity: int
                             ) -> Tuple[Optional[CartItem], str, bool]:
        """Update the quantity of a cart item
        
        Args:
            cart_id: UUID of the cart
            item_id: UUID of the cart item
            quantity: New quantity
            
        Returns:
            Tuple of (cart_item, error_message, was_deleted)
            cart_item is a CartItem object if successful and not deleted, None otherwise
            error_message is empty if successful, otherwise contains the error
            was_deleted is True if the item was deleted, False otherwise
        """
        try:
            # Use the cart repository's aggregate method
            cart, cart_item = self.cart_repository.update_item_in_cart(cart_id, item_id, quantity)
            
            if not cart or not cart_item:
                return None, "Failed to update item", False
                
            was_deleted = cart_item is None
            
            if was_deleted:
                return None, "", True
            
            return cart_item, "", False
        except Exception as e:
            logger.error(f"Error updating item quantity: {str(e)}")
            return None, f"Error updating item quantity: {str(e)}", False
    
    def remove_item_from_cart(self, cart_id: uuid.UUID, 
                             item_id: uuid.UUID
                             ) -> Tuple[bool, str]:
        """Remove an item from a cart
        
        Args:
            cart_id: UUID of the cart
            item_id: UUID of the cart item
            
        Returns:
            Tuple of (success, error_message)
            success is True if item was removed successfully
            error_message is empty if successful, otherwise contains the error
        """
        try:
            # First get the cart item to confirm it exists
            item = self.cart_item_repository.get_item(item_id)
            if not item:
                return False, "Item not found"
                
            # Remove the item
            success = self.cart_item_repository.remove_item(item_id)
            if not success:
                return False, "Failed to remove item from cart"
                
            # Recalculate cart totals
            self.cart_repository.recalculate_cart_totals(cart_id)
                
            return True, ""
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
            
    def reserve_cart(self, cart_id: uuid.UUID, minutes: int = 3600) -> Tuple[bool, str]:
        """Reserve a cart for checkout
        
        Args:
            cart_id: UUID of the cart
            minutes: Number of minutes to reserve the cart for
            
        Returns:
            Tuple of (success, error_message)
            success is True if cart was reserved successfully
            error_message is empty if successful, otherwise contains the error
        """
        try:
            cart = self.cart_repository.get_cart(cart_id=cart_id)
            if not cart:
                return False, "Cart not found"
                
            # Update the cart model
            self.cart_repository.reserve(cart_id, minutes)
            
            return True, ""
        except Exception as e:
            logger.error(f"Error reserving cart: {str(e)}")
            return False, f"Error reserving cart: {str(e)}"
    
    def release_cart_reservation(self, cart_id: uuid.UUID) -> Tuple[bool, str]:
        """Release a cart reservation
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            Tuple of (success, error_message)
            success is True if reservation was released successfully
            error_message is empty if successful, otherwise contains the error
        """
        try:
            cart = self.cart_repository.get_cart(cart_id=cart_id)
            if not cart:
                return False, "Cart not found"
                
            # Update the cart model
            self.cart_repository.release_reservation(cart_id)
            
            return True, ""
        except Exception as e:
            logger.error(f"Error releasing cart reservation: {str(e)}")
            return False, f"Error releasing cart reservation: {str(e)}"
    
    def mark_cart_for_recovery(self, cart_id: uuid.UUID) -> bool:
        """Mark a cart for recovery email
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            True if cart was marked successfully
        """
        # Get cart
        cart = self.cart_repository.get_cart(cart_id=cart_id)
        if not cart or cart.is_empty():
            return False
        
        # Add to recovery queue (implementation depends on the email system)
        recovery_time = timezone.now() + timezone.timedelta(hours=24)
        
        # Example implementation using Django's cache
        cache.set(f"cart_recovery:{cart_id}", str(recovery_time), 86400)  # 24 hours
        
        return True
