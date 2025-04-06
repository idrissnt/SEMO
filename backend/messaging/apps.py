"""
Django app configuration for the messaging system.
"""
from django.apps import AppConfig


class MessagingConfig(AppConfig):
    """
    Django app configuration for the messaging system.
    """
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'messaging'
    verbose_name = 'Messaging System'
    
    def ready(self):
        """
        Perform initialization tasks when the app is ready.
        """
        # Import signal handlers to register them
        import messaging.infrastructure.signals  # noqa
