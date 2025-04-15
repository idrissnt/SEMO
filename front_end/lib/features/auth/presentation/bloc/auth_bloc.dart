import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserAuthRepository _authRepository;
  final _logger = Logger('AuthBloc');

  AuthBloc({required UserAuthRepository authRepository})
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

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (user) {
        _logger.info('Login successful');
        emit(AuthAuthenticated(user));
      },
      (error) {
        // Emit failure state with user-friendly message
        emit(AuthFailure(error.message));
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Starting registration process');
    emit(AuthLoading());

    final result = await _authRepository.register(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      password: event.password,
      phoneNumber: event.phoneNumber,
      profilePhotoUrl: event.profilePhotoUrl,
    );

    result.fold(
      (user) {
        _logger.info('Registration and auto-login successful');
        emit(AuthAuthenticated(user));
      },
      (error) {
        // Emit failure state with user-friendly message
        emit(AuthFailure(error.message));
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Starting logout process');
    emit(AuthLoading());

    final result = await _authRepository.logout();

    // Even if the server request fails, we want to log out locally
    result.fold(
      (_) {
        _logger.info('Logout successful');
        emit(AuthUnauthenticated());
      },
      (error) {
        // Emit failure state with user-friendly message
        emit(AuthFailure(error.message));
        emit(AuthUnauthenticated());
      },
    );
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
      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (user) {
          _logger.info('User authenticated: ${user.email}');
          emit(AuthAuthenticated(user));
        },
        (error) {
          _logger.info(
              'Failed to get user: ${error.message}. Emitting Unauthenticated state.');
          emit(AuthUnauthenticated());
        },
      );
    } catch (e) {
      // Log detailed error information
      _logger.severe('Authentication check failed: $e', e);
      emit(AuthUnauthenticated());
    }
  }
}
