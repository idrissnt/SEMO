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
        cart = self.cart_repository.get_cart(cart_id=cart_id, include_product_details=True)
        if not cart:
            return None
            
        # Convert cart items to CartItemInfo objects
        cart_items = []
        for item in cart.items:
            cart_items.append(CartItemInfo(
                store_product_id=item.store_product_id,
                quantity=item.quantity,
                product_details=item.product_details,
                item_total_price=item.calculate_item_price_total()
            ))
            
        return CartInfo(
            id=cart.id,
            user_id=cart.user_id,
            store_brand_id=cart.store_brand_id,
            store_brand_name=cart.store_brand_name,
            store_brand_image_logo=cart.store_brand_logo,            
            items=cart_items,
            cart_total_price=float(cart.calculate_cart_price_total()),
            cart_total_items=cart.total_items()
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
