
to make this file executable run the following command in the terminal:
chmod +x run_server.sh


#!/bin/bash
# Run Django Channels with Gunicorn and Uvicorn workers
set -e

# Configuration
SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-backend.settings.dev}
PORT=${PORT:-8000}
HOST=${HOST:-0.0.0.0}
WORKERS=${WORKERS:-0}  # 0 means auto-configure based on CPU cores

# Activate virtual environment if using one
# source /path/to/venv/bin/activate

# Set environment variables
export DJANGO_SETTINGS_MODULE=$SETTINGS_MODULE

# Check for required dependencies
if ! command -v gunicorn &> /dev/null; then
    echo "Error: gunicorn is not installed. Please install it with: pip install gunicorn"
    exit 1
fi

if ! command -v uvicorn &> /dev/null; then
    echo "Error: uvicorn is not installed. Please install it with: pip install uvicorn"
    exit 1
fi

# Run migrations if requested
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running migrations..."
    python manage.py migrate
fi

# Start Gunicorn with Uvicorn workers
echo "Starting Django Channels with Gunicorn and Uvicorn workers..."
echo "Settings: $SETTINGS_MODULE"
echo "Server: $HOST:$PORT"

# Use the gunicorn config file if it exists, otherwise use command line args
if [ -f "gunicorn_config.py" ]; then
    echo "Using gunicorn_config.py"
    gunicorn backend.asgi:application -c gunicorn_config.py
else
    echo "Using command line arguments (gunicorn_config.py not found)"
    WORKER_OPTS=""
    if [ "$WORKERS" -gt 0 ]; then
        WORKER_OPTS="--workers $WORKERS"
    fi
    
    gunicorn backend.asgi:application \
        --bind $HOST:$PORT \
        --worker-class uvicorn.workers.UvicornWorker \
        $WORKER_OPTS \
        --log-level info
fi
