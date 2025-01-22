# Flutter Project Structure (clean architecture)

```
lib/
├── core/                     # Core functionality and utilities
│   ├── config/              # App configuration
│   │   └── app_config.dart  # API and app-wide configurations
│   ├── di/                 # Dependency Injection
│   │   └── service_locator.dart
│   ├── errors/             # Error handling
│   └── utils/              # Utility functions
│
├── data/                    # Data layer
│   ├── datasources/        # Data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
│       └── auth_repository_impl.dart
│
├── domain/                 # Business logic layer
│   ├── entities/          # Business objects
│   └── repositories/      # Repository interfaces
│
├── presentation/          # UI layer
│   ├── blocs/            # State management
│   │   └── auth/         # Authentication bloc
│   ├── screens/          # App screens
│   │   ├── auth/         # Authentication screens
│   │   ├── home/         # Home screen
│   │   └── onboarding/   # Onboarding screens
│   └── widgets/          # Reusable widgets
│
└── main.dart            # App entry point
```

## Architecture Overview

### 1. Core Layer
- Centralized configuration management
- Dependency Injection with `get_it`
- Error handling utilities
- App-wide constants and configurations

### 2. Data Layer
- Repository implementations
- Data models
- Network and local data sources
- Concrete data retrieval logic

### 3. Domain Layer
- Abstract repository interfaces
- Core business entities
- Separation of concerns from data layer

### 4. Presentation Layer
- BLoC for state management
- Screens and UI components
- Authentication and navigation flows

## Key Technologies

- Flutter
- Dart
- Clean Architecture
- BLoC State Management
- JWT Authentication
- `get_it` for Dependency Injection
- `flutter_secure_storage` for token management

## Dependency Injection

Centralized in `core/di/service_locator.dart`:
- Manages app-wide dependencies
- Provides single instances of critical services
- Facilitates easy testing and mocking

## Authentication Flow

- JWT-based authentication
- Secure token storage
- Automatic token refresh
- Comprehensive error handling

## State Management

- Uses `flutter_bloc` for reactive state management
- Implements authentication state
- Handles login, logout, and token validation

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

## Best Practices

1. Maintain clear separation of concerns
2. Use dependency injection
3. Implement comprehensive error handling
4. Write testable code
5. Follow Flutter and Dart style guidelines

## Contributing

1. Follow clean architecture principles
2. Write unit and widget tests
3. Maintain code readability
4. Update documentation with significant changes
