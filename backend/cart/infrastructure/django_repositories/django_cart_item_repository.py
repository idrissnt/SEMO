from typing import List, Optional, Tuple, Dict, Any
import uuid
import logging
from decimal import Decimal

from django.db import transaction

from cart.domain.models.entities import CartItem
from cart.domain.repositories.repository_interfaces import CartItemRepository
from cart.infrastructure.django_models.orm_models import CartItemModel, CartModel
from store.models import StoreProduct
from .cart_utils import update_cart_totals, calculate_item_total_price

logger = logging.getLogger(__name__)


class DjangoCartItemRepository(CartItemRepository):
    """Django ORM implementation of CartItemRepository
    
    Responsible for operations on cart items, such as adding,
    updating, and removing items from a cart.
    """
    
    def add_item(self, cart_id: uuid.UUID, store_product_id: uuid.UUID, 
                quantity: int) -> CartItem:
        """Add an item to a cart
        
        Args:
            cart_id: UUID of the cart
            store_product_id: UUID of the store product
            quantity: Quantity of the item to add
            
        Returns:
            CartItem object if successful, None otherwise
        """
        try:
            with transaction.atomic():
                # Validate store product exists
                try:
                    store_product = StoreProduct.objects.get(id=store_product_id)
                except StoreProduct.DoesNotExist:
                    logger.error(f"Store product with ID {store_product_id} not found")
                    return None
                    
                # Check if item already exists
                existing_item = CartItemModel.objects.filter(
                    cart_id=cart_id,
                    store_product_id=store_product_id
                ).first()
                
                if existing_item:
                    # Update quantity
                    existing_item.quantity += quantity
                    existing_item.save()
                    
                    # Update cart totals
                    update_cart_totals(cart_id)
                    
                    return self._to_domain(existing_item)
                else:
                    # Create new item
                    item_model = CartItemModel(
                        cart_id=cart_id,
                        store_product_id=store_product_id,
                        product_price=store_product.price,
                        quantity=quantity
                    )
                    
                    # Calculate item total price
                    item_model.item_total_price = calculate_item_total_price(item_model)
                    item_model.save()
                    
                    # Update cart totals
                    update_cart_totals(cart_id)
                    
                    return self._to_domain(item_model)
        except Exception as e:
            logger.error(f"Error adding item to cart: {str(e)}")
            return None
    
    def get_item(self, item_id: uuid.UUID) -> Optional[CartItem]:
        """Get a cart item by ID
        
        Args:
            item_id: UUID of the cart item
            
        Returns:
            CartItem if found, None otherwise
        """
        try:
            item_model = CartItemModel.objects.get(id=item_id)
            return self._to_domain(item_model)
        except CartItemModel.DoesNotExist:
            logger.debug(f"Cart item with ID {item_id} not found")
            return None
    
    def get_items_for_cart(self, cart_id: uuid.UUID) -> List[CartItem]:
        """Get all items for a cart
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            List of CartItem objects
        """
        item_models = CartItemModel.objects.filter(cart_id=cart_id)
        return [self._to_domain(item_model) for item_model in item_models]
    
    def update_item_quantity(self, item_id: uuid.UUID, 
                            quantity: int) -> Tuple[Optional[CartItem], bool]:
        """Update the quantity of a cart item
        
        Args:
            item_id: UUID of the item to update
            quantity: New quantity value
            
        Returns:
            Tuple of (CartItem, is_deleted) where is_deleted is True if the item was removed
        """
        try:
            with transaction.atomic():
                # Get the item
                try:
                    item_model = CartItemModel.objects.get(id=item_id)
                    cart_id = item_model.cart_id
                except CartItemModel.DoesNotExist:
                    logger.error(f"Cart item with ID {item_id} not found")
                    return None, False
                
                # Delete item if quantity is less than 1
                if quantity < 1:
                    item_model.delete()
                    update_cart_totals(cart_id)
                    return None, True
                
                # Update quantity
                item_model.quantity = quantity
                item_model.item_total_price = calculate_item_total_price(item_model)
                item_model.save()
                
                # Update cart totals
                update_cart_totals(cart_id)
                
                return self._to_domain(item_model), False
        except Exception as e:
            logger.error(f"Error updating item quantity: {str(e)}")
            return None, False
    
    def remove_item(self, item_id: uuid.UUID) -> bool:
        """Remove an item from a cart
        
        Args:
            item_id: UUID of the item to remove
            
        Returns:
            True if successful, False otherwise
        """
        try:
            with transaction.atomic():
                # Get the item
                try:
                    item_model = CartItemModel.objects.get(id=item_id)
                    cart_id = item_model.cart_id
                except CartItemModel.DoesNotExist:
                    logger.error(f"Cart item with ID {item_id} not found")
                    return False
                
                # Delete the item
                item_model.delete()
                
                # Update cart totals
                update_cart_totals(cart_id)
                
                return True
        except Exception as e:
            logger.error(f"Error removing item: {str(e)}")
            return False
    
    def _to_domain(self, item_model: CartItemModel) -> CartItem:
        """Convert ORM model to domain model
        
        Args:
            item_model: CartItemModel instance to convert
            
        Returns:
            CartItem domain entity  
        """

        return CartItem(
                id=item_model.id,
                store_product_id=item_model.store_product.id,
                quantity=item_model.quantity,
                product_name=item_model.store_product.product.name,
                product_image_thumbnail=item_model.store_product.product.image_thumbnail,
                product_image_url=item_model.store_product.product.image_url,
                product_price=float(item_model.product_price),
                product_description=item_model.store_product.product.description,
                item_total_price=float(item_model.item_total_price),
                added_at=item_model.added_at
            )
