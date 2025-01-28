# Product Views API Documentation

## Overview
This module provides comprehensive API endpoints for managing products and product categories in the application. It offers flexible querying, filtering, and retrieval of product and category information.

## Authentication
- All endpoints require authentication
- Include `Authorization` header in your requests

## Endpoints

### 1. Product Listing
- **Endpoint**: `GET /api/v1/products/`
- **Description**: Retrieve a list of products with advanced filtering capabilities
- **Query Parameters**:
  - `store_id`: Filter products by specific store
  - `category_id`: Filter products by category (including subcategories)
  - `parent_category_id`: Filter products by parent category
  - `search`: Search products by name or description
  - `min_price`: Minimum product price
  - `max_price`: Maximum product price
  - `is_available`: Filter by product availability (true/false)
  - `is_seasonal`: Filter by seasonal status (true/false)

#### Example Requests
```
# Get all products in a specific store
GET /api/v1/products/?store_id=123

# Get seasonal products in a parent category
GET /api/v1/products/?parent_category_id=fruits&is_seasonal=true

# Search and filter products
GET /api/v1/products/?search=organic&min_price=10.00&max_price=50.00&is_available=true
```

#### Response Example
```json
[
  {
    "id": "product-uuid",
    "name": "Organic Apples",
    "image_url": "http://example.com/apple.jpg",
    "category_name": "Fruits",
    "parent_category": {
      "id": "produce-uuid",
      "name": "Produce"
    },
    "is_seasonal": true,
    "unit": "kg",
    "price_range": [12.0, 45.0],
    "available_store_count": 3,
    "stores": [
      {
        "id": "store-uuid-1",
        "name": "Fresh Market"
      }
    ]
  }
]
```

### 2. Product Availability
- **Endpoint**: `GET /api/v1/products/{product_uuid}/availability/`
- **Description**: Check product availability across different stores

#### Example Request
```
GET /api/v1/products/abc-123-def/availability/
```

#### Response Example
```json
[
  {
    "store_id": "store-uuid",
    "store_name": "Fresh Market",
    "price": 15.99,
    "stock": 50,
    "is_available": true
  }
]
```

### 3. Category Listing
- **Endpoint**: `GET /api/v1/categories/`
- **Query Parameters**:
  - `store_id`: Filter categories by store
  - `root_only`: Show only root categories (true/false)

#### Example Request
```
GET /api/v1/categories/?store_id=123&root_only=true
```

### 4. Category Products
- **Endpoint**: `GET /api/v1/categories/{category_uuid}/products/`
- **Description**: Retrieve all products in a specific category and its subcategories

#### Example Request
```
GET /api/v1/categories/fruits-category/products/
```

### 5. Category Subcategories
- **Endpoint**: `GET /api/v1/categories/{category_uuid}/subcategories/`
- **Description**: Retrieve all subcategories for a given category

#### Example Request
```
GET /api/v1/categories/fruits-category/subcategories/
```

## Error Handling
- `400 Bad Request`: Invalid query parameters
- `401 Unauthorized`: Authentication required
- `404 Not Found`: Resource not found

## Performance Considerations
- Results are paginated
- Use query parameters to filter and reduce response size
- Indexes are created on frequently queried fields

## Development Notes
- Implemented using Django REST Framework
- Supports dynamic serializer selection
- Comprehensive filtering and querying capabilities

## Future Improvements
- Add more advanced search capabilities
- Implement caching for frequently accessed resources
- Enhance filtering options

## Troubleshooting
- Ensure proper authentication
- Validate query parameter types and values
- Check database relationships

## Testing
- Use Postman or curl for API testing
- Verify authentication and permissions
- Test various filter combinations

## Contact
For issues or improvements, contact the backend development team.
