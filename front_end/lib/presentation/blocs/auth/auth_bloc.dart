import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:semo/data/models/error/api_error.dart';
import 'package:semo/presentation/blocs/auth/services/error_messages.dart';
import '../../../domain/repositories/user_auth/auth_repository.dart';
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
      // Create structured error
      final apiError = ApiError.fromException(e);
      
      // Log detailed error information
      _logger.severe(
        'Login failed: ${apiError.message}',
        apiError.originalError,
      );
      
      // Get user-friendly error message
      final errorMessage = getErrorMessage(apiError);
      
      // Emit failure state with user-friendly message
      emit(AuthFailure(errorMessage));
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
      );
      _logger.info('Registration and auto-login successful');
      emit(AuthAuthenticated(user));
    } catch (e) {
      // Create structured error
      final apiError = ApiError.fromException(e);
      
      // Log detailed error information
      _logger.severe(
        'Registration failed: ${apiError.message}',
        apiError.originalError,
      );
      
      // Get user-friendly error message
      final errorMessage = getErrorMessage(apiError);
      
      // Emit failure state with user-friendly message
      emit(AuthFailure(errorMessage));
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
      // Create structured error
      final apiError = ApiError.fromException(e);
      
      // Log detailed error information but at INFO level since we handle it gracefully
      _logger.info(
        'Logout error handled gracefully: ${apiError.message}',
        apiError.originalError,
      );
      
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
      _logger.info(
          'Access Token Status: ${accessToken != null ? 'EXISTS' : 'NULL'}');
      _logger.info(
          'Refresh Token Status: ${refreshToken != null ? 'EXISTS' : 'NULL'}');

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
      // Create structured error
      final apiError = ApiError.fromException(e);
      
      // Log detailed error information
      _logger.severe(
        'Authentication check failed: ${apiError.message}',
        apiError.originalError,
      );
      
      // Get user-friendly error message
      final errorMessage = getErrorMessage(apiError);
      
      // Emit failure state with user-friendly message
      emit(AuthFailure(errorMessage));
      emit(AuthUnauthenticated());
    }
  }
}
