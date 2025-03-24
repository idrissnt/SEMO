# User Management API

This module provides a RESTful API for user management, including authentication, profile management, and address management.

## Architecture

The application follows a Domain-Driven Design (DDD) architecture with:

1. **Domain Layer**: Contains domain entities and repository interfaces
2. **Infrastructure Layer**: Contains repository implementations using Django ORM
3. **Interface Layer**: Contains API views and serializers
4. **Application Layer**: Contains application services that orchestrate domain operations

## API Endpoints

### Authentication

All authentication endpoints are under the `/api/auth/` prefix.

- **Register**: `POST /api/auth/register/`
  - Creates a new user account
  - Request body: `{ "email": "user@example.com", "password": "password", "first_name": "John", "last_name": "Doe" }`

- **Login**: `POST /api/auth/login/`
  - Authenticates a user and returns JWT tokens
  - Request body: `{ "email": "user@example.com", "password": "password" }`
  - Response: `{ "access": "access_token", "refresh": "refresh_token", "message": "Login successful" }`

- **Logout**: `POST /api/auth/logout/`
  - Invalidates the refresh token
  - Request body: `{ "refresh_token": "refresh_token" }`
  - Requires authentication

- **Change Password**: `POST /api/auth/change_password/`
  - Changes the user's password
  - Request body: `{ "old_password": "old_password", "new_password": "new_password" }`
  - Requires authentication

- **Refresh Token**: `POST /api/token/refresh/`
  - Refreshes the access token
  - Request body: `{ "refresh": "refresh_token" }`

### User Profile

All user profile endpoints are under the `/api/users/` prefix.

- **Get Profile**: `GET /api/users/me/`
  - Returns the user's profile information
  - Requires authentication

- **Update Profile**: `PUT /api/users/update_me/` or `PATCH /api/users/update_me/`
  - Updates the user's profile information
  - Request body: `{ "first_name": "New Name", ... }`
  - Requires authentication

### Addresses

All address endpoints are under the `/api/addresses/` prefix.

- **List Addresses**: `GET /api/addresses/`
  - Returns a list of the user's addresses
  - Requires authentication

- **Create Address**: `POST /api/addresses/`
  - Creates a new address for the user
  - Request body: `{ "street": "123 Main St", "city": "City", "state": "State", "postal_code": "12345", "country": "Country", "is_default": true }`
  - Requires authentication

- **Get Address**: `GET /api/addresses/{id}/`
  - Returns a specific address
  - Requires authentication

- **Update Address**: `PUT /api/addresses/{id}/` or `PATCH /api/addresses/{id}/`
  - Updates a specific address
  - Request body: `{ "street": "New Street", ... }`
  - Requires authentication

- **Delete Address**: `DELETE /api/addresses/{id}/`
  - Deletes a specific address
  - Requires authentication

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the access token in the Authorization header for authenticated requests:

```
Authorization: Bearer <access_token>
```

## Error Handling

All endpoints return appropriate HTTP status codes:

- 200/201: Success
- 400: Bad Request (invalid input)
- 401: Unauthorized (authentication required)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 500: Internal Server Error
