from typing import Optional
from uuid import UUID

from orders.domain.services.cart_service_interface import CartServiceInterface, CartInfo, CartItemInfo
from cart.domain.repositories.repository_interfaces import CartRepository


class CartService(CartServiceInterface):
    """Implementation of CartServiceInterface that uses the actual CartRepository"""
    
    def __init__(self, cart_repository: CartRepository):
        self.cart_repository = cart_repository
    
    def get_cart(self, cart_id: UUID) -> Optional[CartInfo]:
        """Get minimal cart information by ID
        
        Args:
            cart_id: ID of the cart
            
        Returns:
            CartInfo if found, None otherwise
        """
        # Get the cart using the repository (no need for include_product_details parameter)
        cart = self.cart_repository.get_cart(cart_id=cart_id)
        if not cart:
            return None
            
        # Convert cart items to CartItemInfo objects with direct product fields
        cart_items = []
        for item in cart.items:
            cart_items.append(CartItemInfo(
                id=item.id,
                store_product_id=item.store_product_id,
                quantity=item.quantity,
                product_name=item.product_name,
                product_image_thumbnail=item.product_image_thumbnail,
                product_image_url=item.product_image_url,
                product_price=item.product_price,
                product_description=item.product_description,
                item_total_price=item.item_total_price
            ))
            
        # Create CartInfo using direct cart fields
        return CartInfo(
            id=cart.id,
            user_id=cart.user_id,
            store_brand_id=cart.store_brand_id,
            store_brand_name=cart.store_brand_name,
            store_brand_image_logo=cart.store_brand_logo,            
            items=cart_items,
            cart_total_price=cart.cart_total_price,
            cart_total_items=cart.cart_total_items
        )
        
    def clear_cart(self, cart_id: UUID) -> bool:
        """Clear all items from a cart
        
        Args:
            cart_id: ID of the cart
            
        Returns:
            True if cart was cleared successfully, False otherwise
        """
        success, _ = self.cart_repository.clear(cart_id)
        return success
