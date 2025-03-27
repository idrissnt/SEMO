from django.apps import AppConfig
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

class CartConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'cart'
    
    def ready(self):
        """Initialize app when Django starts"""
        # Initialize event handlers
        try:
            # Import event handlers
            from cart.application.event_handlers import order_event_handler
            from cart.infrastructure.factory import CartFactory
            
            # Initialize the event handler with the cart service
            cart_service = CartFactory.create_cart_service()
            order_event_handler.initialize(cart_service)
            logger.info("Initialized order event handlers for cart service")
        except Exception as e:
            logger.error(f"Error initializing event handlers: {str(e)}")
            
        # Import and register tasks with Celery
        try:
            # Only register celery tasks if celery is configured
            if hasattr(settings, 'CELERY_BEAT_SCHEDULE'):
                from cart.tasks import process_cart_recoveries
                
                # Add the task to the celery beat schedule if not already there
                if 'cart.tasks.process_cart_recoveries' not in settings.CELERY_BEAT_SCHEDULE:
                    settings.CELERY_BEAT_SCHEDULE['cart.tasks.process_cart_recoveries'] = {
                        'task': 'cart.tasks.process_cart_recoveries',
                        'schedule': 3600.0,  # Run every hour
                        'options': {'expires': 3540},  # Expire after 59 minutes
                    }
                    logger.info("Registered cart recovery task with Celery Beat")
        except ImportError:
            logger.warning("Celery not installed, skipping task registration")
        except Exception as e:
            logger.error(f"Error registering cart tasks: {str(e)}")
