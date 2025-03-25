from re import T
from typing import List, Optional, Dict, Any
import uuid
import logging

from cart.domain.models.entities import Cart, CartItem
from cart.domain.repositories.repository_interfaces import CartRepository
from cart.infrastructure.django_models.orm_models import CartModel
from store.models import StoreProduct, StoreBrand

logger = logging.getLogger(__name__)

class DjangoCartRepository(CartRepository):
    """Django ORM implementation of CartRepository
    
    Responsible for operations on the cart entity itself.
    """
    
    def _to_domain(self, cart_model: CartModel, include_product_details: bool = True) -> Cart:
        """Convert ORM model to domain model
        
        Args:
            cart_model: CartModel instance
            include_product_details: Whether to include product details
            
        Returns:
            Cart domain entity
        """
        # Get store brand details if needed
        store_brand_name = None
        store_brand_slug = None
        if include_product_details:
            try:
                store_brand = StoreBrand.objects.get(id=cart_model.store_brand_id)
                store_brand_name = store_brand.name
                store_brand_slug = store_brand.slug
            except StoreBrand.DoesNotExist:
                store_brand_name = "Unknown"
                store_brand_slug = "unknown"
        
        # Convert cart items to domain entities
        items = []
        for item_model in cart_model.cart_items.all():
            product_details = None
            if include_product_details:
                product_details = _get_product_details(item_model.store_product_id)
            
            items.append(CartItem(
                id=item_model.id,
                store_product_id=item_model.store_product_id,
                quantity=item_model.quantity,
                product_details=product_details,
                added_at=item_model.added_at
            ))
        
        return Cart(
            id=cart_model.id,
            user_id=cart_model.user_id,
            store_brand_id=cart_model.store_brand_id,
            store_brand_name=store_brand_name,
            store_brand_slug=store_brand_slug,
            items=items,
            created_at=cart_model.created_at,
            updated_at=cart_model.updated_at
        )
    
    def get_cart(self, cart_id: uuid.UUID = None, user_id: uuid.UUID = None, 
               store_brand_id: uuid.UUID = None, include_product_details: bool = True) -> Optional[Cart]:
        """Get a cart with options to include product details"""
        try:
            # Build query based on provided parameters
            query = {}
            if cart_id is not None:
                query['id'] = cart_id
            elif user_id is not None and store_brand_id is not None:
                query['user_id'] = user_id
                query['store_brand_id'] = store_brand_id
            else:
                raise ValueError("Either cart_id or both user_id and store_brand_id must be provided")
            
            # Get cart model
            cart_model = CartModel.objects.prefetch_related('cart_items').get(**query)
            
            # Convert to domain entity
            return self._to_domain(cart_model, include_product_details)
        except CartModel.DoesNotExist:
            logger.debug(f"Cart not found with query: {query}")
            return None
    
    def get_all_for_user(self, user_id: uuid.UUID, include_product_details: bool = True) -> List[Cart]:
        """Get all carts for a user"""
        cart_models = CartModel.objects.prefetch_related('cart_items').filter(user_id=user_id)
        return [self._to_domain(cart_model, include_product_details) for cart_model in cart_models]
    
    def create_or_get_cart(self, user_id: uuid.UUID, store_brand_id: uuid.UUID) -> Cart:
        """Create a new cart or get existing one"""
        # Try to get existing cart
        cart = self.get_cart(user_id=user_id, store_brand_id=store_brand_id, include_product_details=True)
        
        # If no cart exists, create a new one
        if not cart:
            cart_model = CartModel(
                user_id=user_id,
                store_brand_id=store_brand_id
            )
            cart_model.save()
            cart = Cart(
                id=cart_model.id,
                user_id=cart_model.user_id,
                store_brand_id=cart_model.store_brand_id,
                items=[],
                created_at=cart_model.created_at,
                updated_at=cart_model.updated_at
            )
        
        return cart
    
    def delete(self, cart_id: uuid.UUID) -> bool:
        """Delete a cart"""
        try:
            cart_model = CartModel.objects.get(id=cart_id)
            cart_model.delete()
            return True
        except CartModel.DoesNotExist:
            logger.error(f"Cart with ID {cart_id} not found")
            return False
    
    def clear(self, cart_id: uuid.UUID) -> bool:
        """Remove all items from a cart"""
        try:
            cart_model = CartModel.objects.get(id=cart_id)
            cart_model.cart_items.all().delete()
            return True
        except CartModel.DoesNotExist:
            logger.error(f"Cart with ID {cart_id} not found")
            return False

def _get_product_details(store_product_id: uuid.UUID) -> Optional[Dict[str, Any]]:
    """Helper function to get product details
    
    Args:
        store_product_id: UUID of the store product
        
    Returns:
        Dictionary with product details if found, None otherwise
    """
    try:
        from store.infrastructure.mappers import store_product_to_product_details
        
        # Get the store product with all related objects
        store_product = StoreProduct.objects.select_related(
            'store_brand', 'product', 'category'
        ).get(id=store_product_id)
        
        # Use the mapper to get full product details
        product_details = store_product_to_product_details(store_product)
        
        # Return a simplified version for cart items
        # This keeps the existing API contract while using the new mapper
        return product_details
    except StoreProduct.DoesNotExist:
        logger.error(f"Product with ID {store_product_id} not found")
        return None

