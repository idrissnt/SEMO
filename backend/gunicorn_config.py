"""
Gunicorn configuration for Django Channels application.

This configuration uses Uvicorn workers to handle both HTTP and WebSocket connections.
"""
import multiprocessing

# Bind to this socket
bind = "0.0.0.0:8000"

# Number of worker processes
# A good rule of thumb is 2-4 x number of CPU cores
workers = multiprocessing.cpu_count() * 2 + 1

# Use Uvicorn worker
worker_class = "uvicorn.workers.UvicornWorker"

# Timeout for worker processes (in seconds)
timeout = 120

# Maximum number of simultaneous clients
worker_connections = 1000

# Maximum number of requests a worker will process before restarting
max_requests = 1000
max_requests_jitter = 50

# Process name
proc_name = "django_channels"

# Access log - records incoming HTTP requests
accesslog = "-"  # Log to stdout
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Error log - records Gunicorn server errors
errorlog = "-"  # Log to stderr
loglevel = "info"

# Whether to send Django output to the error log
capture_output = True

# Daemonize the Gunicorn process (detach & enter background)
daemon = False

# Reload the application if any of the watched files change
reload = False  # Set to True for development
