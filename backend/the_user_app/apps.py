from django.apps import AppConfig


class TheUserAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'the_user_app'
    
    def ready(self):
        # Import the models module to ensure Django can discover the models
        import the_user_app.models
