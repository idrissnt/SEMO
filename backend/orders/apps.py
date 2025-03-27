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
        from orders.application.event_handlers.cart_event_handler import initialize as init_cart_handlers
        from the_user_app.infrastructure.factory import UserRepositoryFactory
        
        # Create repositories
        order_repository = RepositoryFactory.create_order_repository()
        order_item_repository = RepositoryFactory.create_order_item_repository()
        order_timeline_repository = RepositoryFactory.create_order_timeline_repository()
        user_repository = UserRepositoryFactory.create_user_repository()
        
        # Create service
        order_service = OrderApplicationService(
            order_repository=order_repository,
            order_item_repository=order_item_repository,
            order_timeline_repository=order_timeline_repository,
            user_repository=user_repository
        )
        
        # Initialize event handlers
        init_payment_handlers(order_service=order_service)
        init_cart_handlers(order_service=order_service)
