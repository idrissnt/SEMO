from typing import List, Optional, Tuple, Dict, Any
import uuid
import logging

from cart.domain.models.entities import CartItem
from cart.domain.repositories.repository_interfaces import CartItemRepository
from cart.infrastructure.django_models.orm_models import CartItemModel
from store.models import StoreProduct

from .django_cart_repository import _get_product_details

logger = logging.getLogger(__name__)


class DjangoCartItemRepository(CartItemRepository):
    """Django ORM implementation of CartItemRepository
    
    Responsible for operations on cart items, such as adding,
    updating, and removing items from a cart.
    """
    
    def add_item(self, cart_id: uuid.UUID, store_product_id: uuid.UUID, 
                quantity: int, product_details: Dict[str, Any] = None) -> Tuple[Optional[CartItem], str]:
        """Add an item to a cart
        
        Args:
            cart_id: UUID of the cart
            store_product_id: UUID of the store product
            quantity: Quantity of the item to add
            product_details: Optional product details for display
            
        Returns:
            Tuple of (cart_item, error_message)
            cart_item is a CartItem object if successful, None otherwise
            error_message is empty if successful, otherwise contains the error
        """
        # Validate store product exists
        try:
            store_product = StoreProduct.objects.get(id=store_product_id)
        except StoreProduct.DoesNotExist:
            return None, "Store product not found"
            
        # Check if item already exists
        existing_item = CartItemModel.objects.filter(
            cart_id=cart_id,
            store_product_id=store_product_id
        ).first()
        
        if existing_item:
            # Update quantity
            existing_item.quantity += quantity
            existing_item.save()
            
            # If product_details is not provided, try to fetch it
            if product_details is None:
                product_details = _get_product_details(store_product_id)
                
            return CartItem(
                id=existing_item.id,
                store_product_id=existing_item.store_product_id,
                quantity=existing_item.quantity,
                product_details=product_details,
                added_at=existing_item.added_at
            ), ""
        else:
            # Create new item
            item_model = CartItemModel(
                cart_id=cart_id,
                store_product_id=store_product_id,
                quantity=quantity
            )
            item_model.save()
            
            # If product_details is not provided, try to fetch it
            if product_details is None:
                product_details = _get_product_details(store_product_id)
                
            return CartItem(
                id=item_model.id,
                store_product_id=item_model.store_product_id,
                quantity=item_model.quantity,
                product_details=product_details,
                added_at=item_model.added_at
            ), ""
    
    def get_item(self, item_id: uuid.UUID) -> Optional[CartItem]:
        """Get a cart item by ID"""
        try:
            item_model = CartItemModel.objects.get(id=item_id)
            return self._to_domain(item_model)
        except CartItemModel.DoesNotExist:
            logger.debug(f"Cart item with ID {item_id} not found")
            return None
    
    def get_items_for_cart(self, cart_id: uuid.UUID, include_product_details: bool = True) -> List[CartItem]:
        """Get all items for a cart"""
        item_models = CartItemModel.objects.filter(cart_id=cart_id)
        items = []
        
        for item_model in item_models:
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
            
        return items
    
    def update_item_quantity(self, item_id: uuid.UUID, quantity: int) -> Tuple[Optional[CartItem], bool]:
        """Update the quantity of a cart item"""
        try:
            item_model = CartItemModel.objects.get(id=item_id)
            
            # Delete item if quantity is less than 1
            if quantity < 1:
                item_model.delete()
                return None, True
            
            # Update quantity otherwise
            item_model.quantity = quantity
            item_model.save()
            return self._to_domain(item_model), False
        except CartItemModel.DoesNotExist:
            logger.error(f"Cart item with ID {item_id} not found")
            return None, False
    
    def remove_item(self, item_id: uuid.UUID) -> bool:
        """Remove an item from a cart"""
        try:
            item_model = CartItemModel.objects.get(id=item_id)
            item_model.delete()
            return True
        except CartItemModel.DoesNotExist:
            logger.error(f"Cart item with ID {item_id} not found")
            return False
    
    def _to_domain(self, model: CartItemModel) -> CartItem:
        """Convert ORM model to domain model"""
        # Get product details if available
        product_details = _get_product_details(model.store_product_id)
        
        return CartItem(
            id=model.id,
            store_product_id=model.store_product_id,
            quantity=model.quantity,
            product_details=product_details,
            added_at=model.added_at
        )
