
# to connect to physical android device wirelessly
# first connect via USB
# Restart the TCP/IP connection
adb tcpip 5555
# Get your device's current IP address
adb shell ip addr show wlan0 | grep "inet "
# Connect wirelessly using the IP address:
adb connect 172.20.10.4:5555
# Verify the connection
adb devices





# Create and activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Set environment variable for Django settings
$env:DJANGO_SETTINGS_MODULE = "backend.settings.dev"

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Setup development environment (creates superuser)
python manage.py setup_dev

# Run the development server
python manage.py runserver 0.0.0.0:8000 # to allow all apps to connect

# Run the development server with gunicorn for asgi application
python -m gunicorn backend.asgi:application -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000 --reload

# Access the development server
http://127.0.0.1:8000/admin/the_user_app/customuser/