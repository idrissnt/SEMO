# Domain Events with Celery and RabbitMQ

This module provides a robust implementation of the domain events pattern using Celery and RabbitMQ as the message broker. This replaces the previous in-memory event bus implementation to provide better reliability, persistence, and support for distributed systems.

## Features

- **Event Persistence**: Events survive application restarts
- **Distributed Processing**: Events can be processed by any application instance
- **Automatic Retries**: Failed event processing is automatically retried with exponential backoff
- **Scalability**: Better scalability for high-volume systems
- **Backward Compatibility**: Compatible with existing code that uses the previous event bus

## Usage

### Publishing Events

```python
from core.domain_events.events import OrderCreatedEvent
from core.domain_events.event_bus import event_bus
import uuid
from datetime import datetime

# Create an event
event = OrderCreatedEvent.create(
    order_id=uuid.uuid4(),
    user_id=uuid.uuid4(),
    store_brand_id=uuid.uuid4(),
    total_amount=100.0,
    delivery_address="123 Main St, City"
)

# Publish the event
event_bus.publish(event)
```

### Subscribing to Events

#### Method 1: Using the event_bus directly

```python
from core.domain_events.events import OrderCreatedEvent
from core.domain_events.event_bus import event_bus

def handle_order_created(event):
    # Process the event
    print(f"Order created: {event.order_id}")

# Register the handler
event_bus.register(OrderCreatedEvent, handle_order_created)
```

#### Method 2: Using the decorator (recommended)

```python
from core.domain_events.events import OrderCreatedEvent
from core.domain_events.decorators import event_handler

@event_handler(OrderCreatedEvent)
def handle_order_created(event):
    # Process the event
    print(f"Order created: {event.order_id}")
```

## Running Celery Workers

To process events, you need to run Celery workers:

```bash
# Start a Celery worker
cd backend
celery -A core worker -l info
```

## Running RabbitMQ

RabbitMQ must be running for the event bus to work. You can run it using Docker:

```bash
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
```

## Configuration

The Celery configuration is defined in `backend/settings/base.py`. The default configuration uses RabbitMQ as the message broker:

```python
CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL', 'amqp://guest:guest@localhost:5672//')
CELERY_RESULT_BACKEND = 'django-db'
```

You can override these settings in your environment variables if needed.

## Creating New Event Types

To create a new event type, define a new class that inherits from `DomainEvent`:

```python
from dataclasses import dataclass
from uuid import UUID
from core.domain_events.events import DomainEvent

@dataclass
class ProductCreatedEvent(DomainEvent):
    """Event fired when a new product is created"""
    product_id: UUID
    name: str
    price: float
    category_id: UUID
```

## Testing

You can test the event bus using the provided test script:

```bash
cd backend
python -m core.domain_events.test_event_bus
```
