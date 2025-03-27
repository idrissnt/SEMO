from django.apps import AppConfig
import stripe
from django.conf import settings


class PaymentsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'payments'
    
    def ready(self):
        # Initialize Stripe
        stripe.api_key = settings.STRIPE_SECRET_KEY
        
        # Initialize event handlers
        self._init_event_handlers()
    
    def _init_event_handlers(self):
        """Initialize event handlers for the payments app"""
        # Import here to avoid circular imports
        from core.domain_events.events import OrderCreatedEvent, OrderStatusChangedEvent
        from payments.infrastructure.factory import RepositoryFactory
        from payments.application.services.payment_service import PaymentApplicationService
        
        # Create repositories
        payment_repository = RepositoryFactory.create_payment_repository()
        payment_method_repository = RepositoryFactory.create_payment_method_repository()
        payment_transaction_repository = RepositoryFactory.create_payment_transaction_repository()
        
        # Create service
        payment_service = PaymentApplicationService(
            payment_repository=payment_repository,
            payment_method_repository=payment_method_repository,
            payment_transaction_repository=payment_transaction_repository
        )
