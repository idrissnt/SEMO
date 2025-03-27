from typing import List, Optional, Dict, Any, Tuple
from decimal import Decimal
import uuid
import logging

from django.db import transaction

from cart.domain.models.entities import Cart, CartItem
from cart.domain.repositories.repository_interfaces import CartRepository
from cart.infrastructure.django_models.orm_models import CartModel
from store.models import StoreBrand

logger = logging.getLogger(__name__)

class DjangoCartRepository(CartRepository):
    """Django ORM implementation of CartRepository
    
    Responsible for operations on the cart entity itself.
    """
    def get_cart(self, cart_id: uuid.UUID = None, user_id: uuid.UUID = None, 
               store_brand_id: uuid.UUID = None
               ) -> Optional[Cart]:
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
            return self._to_domain(cart_model)
        except CartModel.DoesNotExist:
            logger.debug(f"Cart not found with query: {query}")
            return None
    
    def get_all_for_user(self, user_id: uuid.UUID) -> List[Cart]:
        """Get all carts for a user"""
        cart_models = CartModel.objects.prefetch_related('cart_items').filter(user_id=user_id)
        return [self._to_domain(cart_model) for cart_model in cart_models]
    
    def create_or_get_cart(self, user_id: uuid.UUID, store_brand_id: uuid.UUID) -> Cart:
        """Create a new cart or get existing one
        
        Args:
            user_id: UUID of the user
            store_brand_id: UUID of the store brand
            
        Returns:
            Cart object (either existing or newly created)
        """
        # Try to get existing cart
        cart = self.get_cart(user_id=user_id, store_brand_id=store_brand_id)
        
        # If no cart exists, create a new one
        if not cart:
            cart_model = CartModel(
                user_id=user_id,
                store_brand_id=store_brand_id
            )
            cart_model.save()
            cart = self._to_domain(cart_model)
        
        return cart

    def recalculate_cart_totals(self, cart_id: uuid.UUID) -> bool:
        """Recalculate and update cart totals
        
        This is useful when you need to ensure cart totals are up-to-date,
        such as after batch operations or when fixing inconsistencies.
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            True if successful, False otherwise
        """
        from .cart_utils import update_cart_totals
        return update_cart_totals(cart_id)
            
    def add_item_to_cart(self, cart_id: uuid.UUID, store_product_id: uuid.UUID,
                        quantity: int) -> Tuple[Optional[Cart], Optional[CartItem]]:
        """Add an item to a cart and return the updated cart
        
        This is a convenience method that adds an item and returns the updated cart.
        It ensures that cart totals are updated correctly.
        
        Args:
            cart_id: UUID of the cart
            store_product_id: UUID of the store product
            quantity: Quantity to add
            
        Returns:
            Tuple of (updated cart, added item) or (None, None) if failed
        """
        from django.db import transaction
        from .django_cart_item_repository import DjangoCartItemRepository
        
        cart_item_repo = DjangoCartItemRepository()
        
        with transaction.atomic():
            # Add the item
            cart_item = cart_item_repo.add_item(
                cart_id=cart_id,
                store_product_id=store_product_id,
                quantity=quantity
            )
            
            if not cart_item:
                return None, None
                
            # Get the updated cart
            cart = self.get_cart(
                cart_id=cart_id
            )
            
            return cart, cart_item
            
    def update_item_in_cart(self, cart_id: uuid.UUID, item_id: uuid.UUID, 
                           quantity: int) -> Tuple[Optional[Cart], Optional[CartItem]]:
        """Update an item in a cart and return the updated cart
        
        Args:
            cart_id: UUID of the cart
            item_id: UUID of the item to update
            quantity: New quantity
            
        Returns:
            Tuple of (updated cart, updated item) or (cart, None) if item was deleted
        """
        try:
            from .django_cart_item_repository import DjangoCartItemRepository
            cart_item_repo = DjangoCartItemRepository()
            
            with transaction.atomic():
                # Update the item
                cart_item, was_deleted = cart_item_repo.update_item_quantity(item_id, quantity)
                
                # Get the updated cart
                cart = self.get_cart(
                    cart_id=cart_id
                )
                
                return cart, cart_item
        except Exception as e:
            logger.error(f"Error updating item in cart: {str(e)}")
            return None, None

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
            
    def reserve(self, cart_id: uuid.UUID, minutes: int = 15) -> bool:
        """Reserve a cart for a specified time"""
        try:
            cart_model = CartModel.objects.get(id=cart_id)
            cart_model.reserve(minutes=minutes)
            return True
        except CartModel.DoesNotExist:
            logger.error(f"Cart with ID {cart_id} not found")
            return False
        except Exception as e:
            logger.error(f"Error reserving cart: {str(e)}")
            return False
            
    def release_reservation(self, cart_id: uuid.UUID) -> bool:
        """Release a cart reservation"""
        try:
            cart_model = CartModel.objects.get(id=cart_id)
            cart_model.release_reservation()
            return True
        except CartModel.DoesNotExist:
            logger.error(f"Cart with ID {cart_id} not found")
            return False
        except Exception as e:
            logger.error(f"Error releasing cart reservation: {str(e)}")
            return False
            
    def is_reserved(self, cart_id: uuid.UUID) -> bool:
        """Check if a cart is currently reserved"""
        try:
            cart_model = CartModel.objects.get(id=cart_id)
            return cart_model.is_reserved()
        except CartModel.DoesNotExist:
            logger.error(f"Cart with ID {cart_id} not found")
            return False
        except Exception as e:
            logger.error(f"Error checking cart reservation: {str(e)}")
            return False
    
    def _to_domain(self, cart_model: CartModel) -> Cart:
        """Convert ORM model to domain model
        
        Args:
            cart_model: CartModel instance
            
        Returns:
            Cart domain entity
        """
        # Get store brand details if needed
        if include_store_details:
            store_brand_name, store_brand_logo = self._get_store_brand_details(
                cart_model.store_brand.id)
        else:
            store_brand_name, store_brand_logo = None, None
        
        # Convert cart items to domain entities using a list comprehension
        items = self._get_cart_items(cart_model)
        
        # Create the cart domain entity
        cart = Cart(
            id=cart_model.id,
            user_id=cart_model.user.id,
            store_brand_id=cart_model.store_brand.id,
            store_brand_name=store_brand_name,
            store_brand_logo=store_brand_logo,
            items=items,
            created_at=cart_model.created_at,
            updated_at=cart_model.updated_at,
            cart_total_price=float(cart_model.cart_total_price),
            cart_total_items=cart_model.cart_total_items
        )
        
        # Validation: Ensure the domain entity's calculations match the ORM model
        self._validate_cart_totals(cart_model, cart, items)
            
        return cart
        
    def _get_store_brand_details(self, store_brand_id: uuid.UUID
    ) -> Tuple[Optional[str], Optional[str]]:
        """Get store brand name and logo
        
        Args:
            store_brand_id: UUID of the store brand
            
        Returns:
            Tuple of (name, logo)
        """
        try:
            store_brand = StoreBrand.objects.get(id=store_brand_id)
            return store_brand.name, store_brand.logo
        except StoreBrand.DoesNotExist:
            return "Unknown", None
            
    def _get_cart_items(self, cart_model: CartModel) -> List[CartItem]:
        """Convert cart item models to domain entities
        
        Args:
            cart_model: CartModel instance
            store_product_details: Optional store product details
            
        Returns:
            List of CartItem domain entities
        """
        items = []
        for item_model in cart_model.cart_items.all():
            cart_item = CartItem(
                id=item_model.id,
                store_product_id=item_model.store_product.id,
                quantity=item_model.quantity,
                product_name=item_model.store_product.product.name,
                product_image_thumbnail=item_model.store_product.product.image_thumbnail,
                product_image_url=item_model.store_product.product.image_url,
                product_price=float(item_model.store_product.price),
                product_description=item_model.store_product.product.description,
                item_total_price=float(item_model.item_total_price),
                added_at=item_model.added_at
            )
            items.append(cart_item)
        return items
        
    def _validate_cart_totals(self, cart_model: CartModel, cart: Cart, 
                             items: List[CartItem]) -> None:
        """Validate that cart totals match between ORM and domain
        
        Args:
            cart_model: CartModel instance
            cart: Cart domain entity
            items: List of CartItem domain entities
        """
        if not items:
            return
            
        orm_total = float(cart_model.cart_total_price)
        domain_total = cart.calculate_cart_price_total()
        
        if orm_total != domain_total:
            logger.warning(
                f"Cart {cart_model.id} total price mismatch: "
                f"ORM={orm_total}, Domain={domain_total}"
            )
            
    

