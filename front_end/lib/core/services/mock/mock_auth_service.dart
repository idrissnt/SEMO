import 'package:semo/core/domain/entities/user_entity.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exceptions.dart';
import 'package:semo/features/profile/domain/exceptions/profile/profile_exceptions.dart' hide AuthenticationException;

/// Mock authentication service that provides fake data for offline mode
class MockAuthService {
  /// Returns a mock user for offline testing
  static Result<User, BasicProfileException> getMockUser() {
    // Create a mock user with test data
    final mockUser = User(
      id: 'mock-user-id-123',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      phoneNumber: '+33123456789',
      profilePhotoUrl: 'https://via.placeholder.com/150',
      createdAt: DateTime.now(),
      isGuest: false,
      needsEmailVerification: false,
    );
    
    return Result.success(mockUser);
  }

  /// Simulates a successful login
  static Result<Map<String, dynamic>, AuthenticationException> mockLogin() {
    return Result.success({
      'access': 'mock-access-token',
      'refresh': 'mock-refresh-token',
    });
  }

  /// Simulates a successful token refresh
  static bool mockTokenRefresh() {
    return true;
  }
}
