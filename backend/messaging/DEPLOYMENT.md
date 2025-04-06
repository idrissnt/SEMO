# Messaging System Deployment Guide

This guide provides instructions for deploying the real-time messaging system in different environments.

## Prerequisites

- Python 3.8+
- Redis 6.0+
- Django 4.0+
- ASGI server (Daphne, Uvicorn, or Hypercorn)

## Installation

1. Install the required dependencies:

```bash
pip install channels>=4.0.0 channels-redis>=4.1.0 django-redis>=5.2.0 djangorestframework>=3.14.0 PyJWT>=2.6.0
```

2. Add the messaging app to your Django project's `INSTALLED_APPS`:

```python
INSTALLED_APPS = [
    # ... other apps
    'channels',
    'messaging',
]
```

3. Configure the ASGI application in your project's settings:

```python
ASGI_APPLICATION = 'messaging.asgi.application'
```

## Redis Configuration

The messaging system uses Redis for the channel layer, which enables real-time communication across multiple server instances.

### Development Environment

For development, you can use a simple Redis configuration:

```python
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": ["redis://localhost:6379/0"],
        },
    },
}

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://localhost:6379/1",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        }
    }
}
```

### Production Environment

For production, use a more robust configuration:

```python
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [os.environ.get('REDIS_URL', 'redis://localhost:6379/0')],
            "capacity": 1500,
            "expiry": 60,
            "group_expiry": 86400,  # 1 day in seconds
        },
    },
}

CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": os.environ.get('REDIS_URL', 'redis://localhost:6379/1'),
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "SOCKET_CONNECT_TIMEOUT": 5,
            "SOCKET_TIMEOUT": 5,
            "CONNECTION_POOL_KWARGS": {"max_connections": 100},
            "COMPRESSOR": "django_redis.compressors.zlib.ZlibCompressor",
            "IGNORE_EXCEPTIONS": True,
        }
    }
}
```

## ASGI Server Deployment

The messaging system requires an ASGI server to handle both HTTP and WebSocket connections.

### Daphne

To run the application with Daphne:

```bash
daphne -b 0.0.0.0 -p 8000 your_project.asgi:application
```

### Uvicorn

To run the application with Uvicorn:

```bash
uvicorn your_project.asgi:application --host 0.0.0.0 --port 8000
```

## Docker Deployment

Here's a sample Dockerfile for deploying the messaging system:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose port for the ASGI server
EXPOSE 8000

# Run the ASGI server
CMD ["daphne", "-b", "0.0.0.0", "-p", "8000", "your_project.asgi:application"]
```

And a docker-compose.yml file for local development:

```yaml
version: '3'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    depends_on:
      - redis
    environment:
      - REDIS_URL=redis://redis:6379/0
      - DJANGO_ENV=development

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

## Scaling

For high-traffic applications, you can scale the messaging system horizontally by running multiple instances of the ASGI server behind a load balancer. Redis will handle the communication between instances.

### Kubernetes Deployment

For Kubernetes deployments, use a StatefulSet for Redis and a Deployment for the ASGI server:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: messaging-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: messaging-app
  template:
    metadata:
      labels:
        app: messaging-app
    spec:
      containers:
      - name: messaging-app
        image: your-registry/messaging-app:latest
        ports:
        - containerPort: 8000
        env:
        - name: REDIS_URL
          value: redis://redis-service:6379/0
        - name: DJANGO_ENV
          value: production
```

## Security Considerations

1. **JWT Authentication**: Ensure your JWT secret key is securely stored and not hardcoded in your codebase.

2. **HTTPS**: Always use HTTPS in production to secure WebSocket connections (WSS).

3. **Rate Limiting**: Implement rate limiting to prevent abuse of the messaging API.

4. **Input Validation**: Validate all user input to prevent injection attacks.

## Monitoring

Monitor your messaging system using:

1. **Redis Metrics**: Monitor Redis memory usage, connections, and command execution.

2. **Application Metrics**: Track message throughput, WebSocket connections, and API usage.

3. **Error Logging**: Set up proper error logging to catch and diagnose issues.

## Troubleshooting

Common issues and solutions:

1. **WebSocket Connection Failures**: Check that your proxy/load balancer is configured to handle WebSocket connections.

2. **Redis Connection Issues**: Verify Redis is running and accessible from your application servers.

3. **Message Delivery Delays**: Check Redis performance and consider scaling your Redis instance.

## Using the Helper Configuration

The messaging system provides a helper class to simplify configuration:

```python
from messaging.config import MessagingConfig

# In your Django settings.py
MessagingConfig.configure_django_settings(globals())
```

This will automatically configure all the necessary settings for the messaging system.
