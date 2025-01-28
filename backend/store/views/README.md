# Store Views API Documentation

## Overview
This module provides a comprehensive set of API endpoints for store-related operations, including store listings, product availability, delivery estimates, and detailed store information.

## Project Structure
```
store/views/
├── __init__.py          # Package initialization
├── store_viewset.py     # Main store operations
├── product_views.py     # Product-related store methods
└── delivery_views.py    # Delivery-related methods
```

## API Endpoints

### 1. List Stores
- **Endpoint**: `GET /api/v1/stores/`
- **Description**: Retrieve a list of stores with basic information
- **Query Parameters**:
  - Pagination supported
  - Filtering options available

### 2. Store Details
- **Endpoint**: `GET /api/v1/stores/{store_uuid}/`
- **Description**: Get detailed information about a specific store
- **Includes**:
  - Store details
  - Categories
  - Basic product information

### 3. Get Product in a Store
- **Endpoint**: `GET /api/v1/stores/{store_uuid}/get_product/?product_id={PRODUCT_UUID}`
- **Query Parameters**:
  - `product_id`: UUID of the product
- **Description**: Retrieve specific product details within a store

### 4. Product Availability
- **Endpoint**: `GET /api/v1/stores/product_availability/?product_id={PRODUCT_UUID}`
- **Query Parameters**:
  - `product_id`: UUID of the product
- **Description**: Check product availability across different stores

### 5. Delivery Estimate
- **Endpoint**: `GET /api/v1/stores/delivery_estimate/?latitude=40.7128&longitude=-74.0060`
- **Query Parameters**:
  - `latitude`: Decimal latitude
  - `longitude`: Decimal longitude
- **Description**: Calculate delivery time and cost based on location

### 6. Full Store Details
- **Endpoint**: `GET /api/v1/stores/full_details/`
<!-- - **Endpoint**: `GET /api/v1/stores/full_details/?is_open=true` -->
- **Query Parameters**:
  - `is_open`: Filter by open stores (true/false)
- **Description**: Comprehensive store information including categories and products

### 7. Debug UUIDs (Development Only)
- **Endpoint**: `GET /api/v1/stores/debug_uuids/`
- **Description**: Retrieve UUIDs for stores, products, and their associations
- **Useful for**: 
  - Testing
  - Finding valid UUIDs
  - Understanding data relationships

## Authentication
- Most endpoints require authentication
- Include Authorization header with valid token

## Example Requests

### List Stores
```
GET http://172.20.10.10:8000/api/v1/stores/
```

### Get Product in Store
```
GET http://172.20.10.10:8000/api/v1/stores/{store_uuid}/get_product/?product_id={product_uuid}
```

### Delivery Estimate
```
GET http://172.20.10.10:8000/api/v1/stores/delivery_estimate/?latitude=40.7128&longitude=-74.0060
```

## Troubleshooting
1. Ensure valid UUIDs are used
2. Check authentication
3. Verify database has associated data
4. Use debug_uuids endpoint to find valid identifiers

## Development Notes
- Mixins used for modular code organization
- Separate concerns into different view files
- Easy to extend and modify individual components

## Performance Considerations
- Endpoints support pagination
- Use query parameters for filtering
- Optimize database queries where possible

## Future Improvements
- Add more advanced filtering
- Implement caching
- Enhance error handling
- Add more detailed documentation

## Contributing
1. Follow existing code structure
2. Add tests for new functionality
3. Update documentation
4. Ensure code passes all existing tests
