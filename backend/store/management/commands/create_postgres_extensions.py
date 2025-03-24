from django.core.management.base import BaseCommand
from django.db import connection

class Command(BaseCommand):
    help = 'Creates PostgreSQL extensions needed for full-text search and trigram similarity'

    def handle(self, *args, **options):
        with connection.cursor() as cursor:
            # Create unaccent extension for better text search with accented characters
            self.stdout.write('Creating unaccent extension...')
            cursor.execute('CREATE EXTENSION IF NOT EXISTS unaccent;')
            
            # Create pg_trgm extension for trigram similarity search
            self.stdout.write('Creating pg_trgm extension...')
            cursor.execute('CREATE EXTENSION IF NOT EXISTS pg_trgm;')
            
            # Create btree_gin extension for GIN indexes on more data types
            self.stdout.write('Creating btree_gin extension...')
            cursor.execute('CREATE EXTENSION IF NOT EXISTS btree_gin;')
            
        self.stdout.write(self.style.SUCCESS('Successfully created PostgreSQL extensions'))
