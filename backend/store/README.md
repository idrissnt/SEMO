# Store App: Domain-Driven Design Architecture

## Architecture Overview

This application follows Domain-Driven Design (DDD) principles to create a clean, maintainable architecture with clear separation of concerns. The architecture is divided into four main layers:

1. **Domain Layer**: Core business logic and rules
2. **Infrastructure Layer**: Technical implementations and external integrations
3. **Application Layer**: Orchestration of use cases
4. **Interface Layer**: API endpoints and serialization

## Directory Structure

### Domain Layer (store/domain/)

The core business logic, independent of any framework or infrastructure.

```
store/domain/
├── models/              # Business entities
│   ├── entities.py      # Core domain entities
│
├── value_objects/       # Immutable objects
│   ├── address.py       # Physical address
│   ├── pagination.py    # Pagination parameters
│
├── repositories/        # Repository interfaces
│   └── repository_interfaces.py  # All repository interfaces
│
└── services/           # Domain-specific services
    └── cache_service.py  # Caching interface
```

### Infrastructure Layer (store/infrastructure/)

Contains implementation details of repositories and external services.

```
store/infrastructure/
├── django_models/       # Django ORM models
│   └── orm_models.py    # All Django models
│
├── django_repositories/ # Repository implementations
│   ├── django_product_repository.py
│   └── repository_utils.py
│
├── external_services/   # External service integrations
│   └── google_maps_service.py
│
├── search/             # Search functionality
│   └── search_strategies_implement.py
│
└── migrations/         # Custom/manual migrations (see note below)
```

### Application Layer (store/application/)

Coordinates between domain and infrastructure layers.

```
store/application/
└── services/
    ├── search_products_service.py
    ├── store_brand_location_service.py
    └── store_products_service.py
```

### Interface Layer (store/interfaces/)

Handles how the outside world interacts with the application.

```
store/interfaces/
└── api/
    ├── views.py        # API endpoints
    ├── serializers.py  # Data serialization
    └── urls.py         # API routing
```

## Working with Migrations

### Standard Migrations (store/migrations/)

This is the primary migrations directory that Django uses by default. All model changes should be migrated through this directory using standard Django commands:

```bash
# Generate migrations after model changes
python manage.py makemigrations store

# Apply migrations to the database
python manage.py migrate store
```

### Infrastructure Migrations (store/infrastructure/migrations/)

This secondary directory serves specialized purposes:

1. **Custom Database Operations**: For complex database operations not directly tied to model changes (like creating custom indexes, triggers, or stored procedures)
2. **Manual Migrations**: For migrations that need to be run manually or through custom management commands
3. **Organizational Structure**: Maintains DDD folder structure consistency

To use these migrations, you would typically create a custom management command or explicitly reference them in your code.

## Django Integration

### Bridge Pattern

To connect our DDD architecture with Django's conventions, we use a bridge pattern:

1. **models.py**: Re-exports models from the infrastructure layer with simplified names
2. **admin.py**: Uses the re-exported models for Django admin integration
3. **apps.py**: Standard Django app configuration

This approach allows us to maintain DDD principles while still leveraging Django's powerful features.

## Search Functionality

The store app uses PostgreSQL's full-text search capabilities with:

1. **SearchVectorField**: For storing pre-computed search vectors
2. **GinIndex**: For efficient full-text search operations
3. **GistIndex**: For similarity and trigram searches

These are implemented in the ORM models and utilized in the repository layer for efficient search operations.

## Creating a New Feature

Follow these steps to add a new feature to the application:

1. **Define Domain Entities**: Start by defining entities and value objects in the domain layer
2. **Create Repository Interfaces**: Define repository interfaces for data access
3. **Implement ORM Models**: Create Django models in the infrastructure layer
4. **Implement Repositories**: Create repository implementations that transform between ORM models and domain entities
5. **Create Application Services**: Implement use cases in application services
6. **Add API Endpoints**: Create API views and serializers in the interface layer

## Integrating with Other Bounded Contexts

To integrate with other bounded contexts (e.g., cart, orders, payments):

### 1. Using Foreign Keys (Infrastructure Layer)

```python
# In cart/infrastructure/django_models/orm_models.py
class CartItemModel(models.Model):
    # ...
    store_product = models.ForeignKey('store.StoreProduct', on_delete=models.CASCADE)
    # ...
```

### 2. Using UUIDs for References (Domain Layer)

```python
# In cart/domain/models/entities.py
class CartItem:
    def __init__(self, store_product_id: uuid.UUID, quantity: int, ...):
        self.store_product_id = store_product_id
        # ...
```

### 3. Repository Pattern for Cross-Context Queries

```python
# In orders/application/services/create_order_service.py
def create_order(self, cart_id, ...):
    cart = self.cart_repository.get_by_id(cart_id)
    store_products = self.store_product_repository.get_by_ids(
        [item.store_product_id for item in cart.items]
    )
    # ...
```

## Best Practices

1. **Keep Domain Logic Pure**: Domain entities and services should not depend on infrastructure
2. **Use Value Objects**: For immutable concepts like Address, Money, etc.
3. **Repository Pattern**: Abstract data access through repository interfaces
4. **Factory Pattern**: Use factories for dependency injection
5. **CQRS for Complex Queries**: Separate command and query responsibilities for better performance

## Testing

The architecture supports different testing strategies for each layer:

1. **Domain Tests**: Unit tests for domain logic
2. **Application Tests**: Tests for application services with mocked repositories
3. **Infrastructure Tests**: Tests for repository implementations
4. **Integration Tests**: End-to-end tests for complete features