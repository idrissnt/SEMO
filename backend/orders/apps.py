from django.apps import AppConfig


class OrdersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'orders'
    
    def ready(self):
        # Initialize event handlers
        self._init_event_handlers()
    
    def _init_event_handlers(self):
        """Initialize event handlers for the orders app"""
        # Import here to avoid circular imports
        from orders.infrastructure.factory import RepositoryFactory
        from orders.application.services.order_service import OrderApplicationService
        from orders.application.event_handlers.payment_event_handler import initialize as init_payment_handlers
        from the_user_app.infrastructure.factory import UserFactory
        from cart.infrastructure.factory import CartFactory
        
        # Create repositories
        order_repository = RepositoryFactory.create_order_repository()
        order_item_repository = RepositoryFactory.create_order_item_repository()
        order_timeline_repository = RepositoryFactory.create_order_timeline_repository()
        user_service = UserFactory.create_user_service()
        cart_service = CartFactory.create_cart_service()
        
        # Create service
        order_service = OrderApplicationService(
            order_repository=order_repository,
            order_item_repository=order_item_repository,
            order_timeline_repository=order_timeline_repository,
            user_service=user_service,
            cart_service=cart_service
        )
        
        # Initialize event handlers
        init_payment_handlers(order_service=order_service)
