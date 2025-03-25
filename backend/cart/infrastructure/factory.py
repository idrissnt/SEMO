from cart.application.services.cart_service import CartApplicationService
from cart.domain.repositories.repository_interfaces import CartRepository, CartItemRepository
from cart.infrastructure.django_repositories.django_cart_repository import DjangoCartRepository
from cart.infrastructure.django_repositories.django_cart_item_repository import DjangoCartItemRepository

class CartFactory:
    """Factory for creating cart-related services and repositories"""
    
    @staticmethod
    def create_cart_repository() -> CartRepository:
        """Create a cart repository instance
        
        Returns:
            CartRepository implementation
        """
        return DjangoCartRepository()
    
    @staticmethod
    def create_cart_item_repository() -> CartItemRepository:
        """Create a cart item repository instance
        
        Returns:
            CartItemRepository implementation
        """
        return DjangoCartItemRepository()
    
    @staticmethod
    def create_cart_service() -> CartApplicationService:
        """Create a cart service instance
        
        Returns:
            CartApplicationService instance
        """
        cart_repository = CartFactory.create_cart_repository()
        cart_item_repository = CartFactory.create_cart_item_repository()
        return CartApplicationService(cart_repository, cart_item_repository)
