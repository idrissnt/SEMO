import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final _logger = Logger('AuthBloc');

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Starting login process for user: ${event.email}');
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      _logger.info('Login successful');
      emit(AuthAuthenticated(user));
    } catch (e) {
      _logger.severe('Login failed: $e');
      emit(AuthFailure(_getErrorMessage(e)));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Starting registration process');
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        password2: event.password2,
      );
      _logger.info('Registration and auto-login successful');
      emit(AuthAuthenticated(user));
    } catch (e) {
      _logger.severe('Registration failed: $e');
      emit(AuthFailure(_getErrorMessage(e)));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Starting logout process');
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      _logger.info('Logout successful');
      emit(AuthUnauthenticated());
    } catch (e) {
      _logger.info('Logout error handled gracefully: $e');
      // Even if the server request fails, we want to log out locally
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('AuthCheckRequested: Starting authentication check');
    emit(AuthLoading());
    try {
      // First, log all available tokens
      final accessToken = await _authRepository.getAccessToken();
      final refreshToken = await _authRepository.getRefreshToken();
      _logger.info('Access Token Status: ${accessToken != null ? 'EXISTS' : 'NULL'}');
      _logger.info('Refresh Token Status: ${refreshToken != null ? 'EXISTS' : 'NULL'}');

      // If no refresh token, user must log in
      if (refreshToken == null) {
        _logger.info('No refresh token found. Emitting Unauthenticated state.');
        emit(AuthUnauthenticated());
        return;
      }

      // Try to refresh the token
      final tokenRefreshed = await _authRepository.refreshToken();
      _logger.info('Token Refresh Attempt: $tokenRefreshed');

      if (!tokenRefreshed) {
        _logger.info('Token refresh failed. Emitting Unauthenticated state.');
        emit(AuthUnauthenticated());
        return;
      }

      // Get the current user
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _logger.info('User authenticated: ${user.email}');
        emit(AuthAuthenticated(user));
      } else {
        _logger.info('Failed to get user. Emitting Unauthenticated state.');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _logger.severe('Authentication check failed', e);
      emit(AuthFailure(_getErrorMessage(e)));
      emit(AuthUnauthenticated());
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Password validation errors
    if (errorStr.contains('password2')) {
      if (errorStr.contains('not match')) {
        return 'Passwords do not match. Please confirm your password.';
      }
      return 'Please confirm your password.';
    }

    if (errorStr.contains('password')) {
      if (errorStr.contains('required')) {
        return 'Password is required.';
      }
      if (errorStr.contains('6 characters') || errorStr.contains('too short')) {
        return 'Password must be at least 6 characters long.';
      }
      return 'Please check your password.';
    }

    // Email validation errors
    if (errorStr.contains('email')) {
      if (errorStr.contains('already exists')) {
        return 'This email is already registered. Please try logging in.';
      }
      if (errorStr.contains('required')) {
        return 'Email address is required.';
      }
      if (errorStr.contains('valid')) {
        return 'Please enter a valid email address.';
      }
      return 'Please check your email address.';
    }

    // Name validation errors
    if (errorStr.contains('first_name')) {
      return 'Please enter your first name.';
    }
    if (errorStr.contains('last_name')) {
      return 'Please enter your last name.';
    }

    // Network errors
    if (errorStr.contains('connection refused') ||
        errorStr.contains('network')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    // If we can't identify a specific error, show the raw error message
    return error.toString().replaceAll('Exception: ', '');
  }
}
