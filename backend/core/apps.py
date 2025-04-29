from django.apps import AppConfig


class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'core'
    
    def ready(self):
        # Import signals to register them
        import core.infrastructure.django_models.signals

    def get_exception_mappings(self):
        from core.interface.api.exception.exception_mapping import CORE_EXCEPTION_MAPPING
        return CORE_EXCEPTION_MAPPING
