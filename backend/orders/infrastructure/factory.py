from orders.domain.repositories.repository_interfaces import OrderRepository, OrderItemRepository, OrderTimelineRepository
from orders.infrastructure.django_repositories.order_repository import DjangoOrderRepository
from orders.infrastructure.django_repositories.order_item_repository import DjangoOrderItemRepository
from orders.infrastructure.django_repositories.order_timeline_repository import DjangoOrderTimelineRepository
from orders.domain.services.user_service_interface import UserServiceInterface
from orders.infrastructure.services.user_service import UserService
from orders.domain.services.cart_service_interface import CartServiceInterface
from orders.infrastructure.services.cart_service import CartService


class RepositoryFactory:
    """Factory for creating repository instances"""
    
    @staticmethod
    def create_order_repository() -> OrderRepository:
        """Create an instance of OrderRepository"""
        return DjangoOrderRepository()
    
    @staticmethod
    def create_order_item_repository() -> OrderItemRepository:
        """Create an instance of OrderItemRepository"""
        return DjangoOrderItemRepository()
    
    @staticmethod
    def create_order_timeline_repository() -> OrderTimelineRepository:
        """Create an instance of OrderTimelineRepository"""
        return DjangoOrderTimelineRepository()
        
    @staticmethod
    def create_user_service() -> UserServiceInterface:
        """Create a UserServiceInterface implementation"""
        from the_user_app.infrastructure.factory import UserFactory
        user_repository = UserFactory.create_user_repository()
        return UserService(user_repository)
        
    @staticmethod
    def create_cart_service() -> CartServiceInterface:
        """Create a CartServiceInterface implementation"""
        from cart.infrastructure.factory import RepositoryFactory as CartRepositoryFactory
        cart_repository = CartRepositoryFactory.create_cart_repository()
        return CartService(cart_repository)
