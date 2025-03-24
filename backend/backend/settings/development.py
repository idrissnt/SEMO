from .base import *
from decouple import config  # Install python-decouple first: pip install python-decouple


DEBUG = True

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '10.0.2.2',  
    'localhost',
    '172.20.10.5', # Physical device IP
    '172.20.10.10',  # Physical device IP
    '192.168.187.184',  # Physical device IP
]

# Database
DATABASES = {

    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST'),
        'PORT': config('DB_PORT'),
    }


    # 'default': {
    #     'ENGINE': 'django.db.backends.sqlite3',
    #     'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    # }
}

# CORS settings for development
CORS_ALLOW_ALL_ORIGINS = True  # Only for development!

# Stripe settings
STRIPE_SECRET_KEY = config('STRIPE_SECRET_KEY', default='sk_test_your_test_key_here')
STRIPE_WEBHOOK_SECRET = config('STRIPE_WEBHOOK_SECRET', default='whsec_your_webhook_secret_here')

# Google Maps API
GOOGLE_MAPS_API_KEY = config('GOOGLE_MAPS_API_KEY')