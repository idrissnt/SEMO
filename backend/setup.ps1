# Create and activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Set environment variable for Django settings
$env:DJANGO_SETTINGS_MODULE = "backend.settings.development"

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Setup development environment (creates superuser)
python manage.py setup_dev

# Run the development server
python manage.py runserver 0.0.0.0:8000 # to allow all apps to connect

# Access the development server
http://127.0.0.1:8000/admin/the_user_app/customuser/