from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.db import transaction

User = get_user_model()

class Command(BaseCommand):
    help = 'Sets up development environment'

    def handle(self, *args, **kwargs):
        self.stdout.write('Setting up development environment...')
        
        try:
            with transaction.atomic():
                # Create superuser if it doesn't exist
                if not User.objects.filter(username='admin').exists():
                    User.objects.create_superuser(
                        'admin',
                        'admin@example.com',
                        'admin123'
                    )
                    self.stdout.write(self.style.SUCCESS('Superuser created successfully'))
                else:
                    self.stdout.write('Superuser already exists')

                # Add any other development setup here
                
            self.stdout.write(self.style.SUCCESS('Development environment setup completed successfully'))
            
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Error setting up development environment: {str(e)}'))
