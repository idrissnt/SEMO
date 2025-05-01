import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/core/domain/entities/user_entity.dart';

import 'package:semo/features/auth/domain/exceptions/auth/auth_exceptions.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/auth/domain/services/auth_check_usecase.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/services/auth/auth_error_message_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserAuthRepository _authRepository;
  final UserProfileUseCase _userProfileUseCase;
  final AppLogger _logger;
  final AuthErrorMessageService _errorMessageService;

  AuthBloc({
    required UserAuthRepository authRepository,
    required UserProfileUseCase userProfileUseCase,
    required AppLogger logger,
  })  : _authRepository = authRepository,
        _userProfileUseCase = userProfileUseCase,
        _logger = logger,
        _errorMessageService = AuthErrorMessageService(),
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthResetState>(_onAuthResetState);
    on<EnterGuestMode>(_onEnterGuestMode);
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
      (authTokens) async {
        _logger.info('Login successful, fetching user profile');
        await _fetchUserProfile(emit, 'login');
      },
      (error) {
        _logger.error('Bloc Login error', error: error.message);
        _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
        _mapErrorToState(emit, error, 'login');
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
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      phoneNumber: event.phoneNumber,
      profilePhotoUrl: event.profilePhotoUrl,
    );

    result.fold(
      (authTokens) async {
        _logger.info('Registration successful, fetching user profile');
        await _fetchUserProfile(emit, 'registration');
      },
      (error) {
        _logger.error('Registration error', error: error.message);
        _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
        _mapErrorToState(emit, error, 'registration');
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('BLOC Starting logout process for user: ${event.email}');
    emit(AuthLoading());

    final result = await _authRepository.logout(email: event.email);

    // Even if the server request fails, we want to log out locally
    result.fold(
      (_) {
        _logger.info('BLOC Logout successful for user: ${event.email}');
        emit(AuthUnauthenticated());
      },
      (error) {
        _logger.error('Logout error', error: error.message);
        _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));

        // Special case for logout - handle missing token gracefully
        if (error is MissingRefreshTokenException) {
          _logger
              .warning('Missing refresh token during logout: ${error.message}');
          emit(AuthUnauthenticated());
          return;
        }

        // Map other errors to appropriate states
        _mapErrorToState(emit, error, 'logout');

        // Even if there was an error, we still want to log out locally
        emit(AuthUnauthenticated());
      },
    );
  }

  /// Handles the reset state event
  /// Resets the auth state to initial when navigating between auth screens
  void _onAuthResetState(
    AuthResetState event,
    Emitter<AuthState> emit,
  ) {
    _logger.info('Resetting auth state to initial');
    emit(AuthInitial());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('BLOC AuthCheckRequested: Starting authentication check');
    emit(AuthLoading());
    try {
      // First, check if tokens exist
      final hasAccessToken = await _userProfileUseCase.getAccessToken();
      final hasRefreshToken = await _userProfileUseCase.getRefreshToken();
      _logger
          .info('Access Token Status: ${hasAccessToken ? 'EXISTS' : 'NULL'}');
      _logger
          .info('Refresh Token Status: ${hasRefreshToken ? 'EXISTS' : 'NULL'}');

      // If no refresh token, user must log in
      if (!hasRefreshToken) {
        _logger.info(
            'BLOC No refresh token found. Emitting Unauthenticated state.');
        emit(AuthUnauthenticated());
        return;
      }

      // Try to refresh the token
      _logger.debug('BLOC About to attempt token refresh', {
        'component': 'AuthBloc',
        'action': 'token_refresh',
        'event': 'attempt'
      });
      final tokenRefreshed = await _userProfileUseCase.refreshToken();
      _logger.info('BLOC Token Refresh Attempt Result: $tokenRefreshed');

      if (!tokenRefreshed) {
        _logger.info('BLOC Token refresh failed. Emitting token error state.');
        emit(const AuthFailure('Session expired. Please log in again.',
            canRetry: false));
        emit(AuthUnauthenticated());
        return;
      }

      // Get the current user
      final userResult = await _userProfileUseCase.getCurrentUser();
      userResult.fold(
        (user) {
          _logger.info('BLOC User authenticated: ${user.email}');
          emit(AuthAuthenticated(user));
        },
        (error) {
          _logger.error('BLOC Failed to get user data', error: error);
          // Use profile fetch error with retry option
          emit(const ProfileFetchFailure(
              'Could not retrieve your profile. Tap to retry.'));
          // Don't immediately go to unauthenticated - let the user decide to retry or logout
        },
      );
    } catch (e) {
      // Log detailed error information
      _logger.error('BLOC Authentication check failed', error: e);
      // Use network error with retry option
      emit(const NetworkFailure(
          'Connection error during authentication check. Tap to retry.'));
    }
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all auth operations
  /// @param emit The state emitter
  /// @param error The domain exception that was thrown
  /// @param operation The name of the operation (login, registration, logout)
  /// Fetches the user profile and emits appropriate states
  /// This centralizes the user profile fetching logic
  /// @param emit The state emitter
  /// @param operation The name of the operation (login, registration)
  Future<void> _fetchUserProfile(
    Emitter<AuthState> emit,
    String operation,
  ) async {
    try {
      if (emit.isDone) {
        _logger.warning('Emitter is already done in _fetchUserProfile');
        return;
      }
      
      final userResult = await _userProfileUseCase.getCurrentUser();
      
      // Check again if emitter is done before emitting
      if (emit.isDone) {
        _logger.warning('Emitter became done during _fetchUserProfile');
        return;
      }
      
      userResult.fold(
        (user) {
          _logger.info('User profile fetched: ${user.email}');
          emit(AuthAuthenticated(user));
        },
        (error) {
          _logger.error('Failed to get user profile after $operation',
              error: error);
          _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
          // Use specific profile fetch error state with retry option
          emit(ProfileFetchFailure(
              _errorMessageService.getUserFriendlyAuthMessage(error, 'profile')));
          // Don't immediately transition to unauthenticated - let UI handle retry
        },
      );
    } catch (e) {
      _logger.error('Exception in _fetchUserProfile', error: e);
      if (!emit.isDone) {
        emit(const AuthFailure('An unexpected error occurred fetching your profile'));
      }
    }
  }

  /// Handles the EnterGuestMode event
  /// Creates a guest user and emits AuthAuthenticated state with it
  /// This allows access to the app without authentication
  Future<void> _onEnterGuestMode(
    EnterGuestMode event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Entering guest mode');
    emit(AuthLoading());
    
    // Create a guest user using the factory constructor
    final guestUser = User.guest();
    
    // Emit authenticated state with the guest user
    _logger.info('Guest user created: ${guestUser.email}');
    emit(AuthAuthenticated(guestUser));
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all auth operations
  /// @param emit The state emitter
  /// @param error The domain exception that was thrown
  /// @param operation The name of the operation (login, registration, logout)
  void _mapErrorToState(
    Emitter<AuthState> emit,
    AuthenticationException error,
    String operation,
  ) {
    // Get user-friendly message from the error message service
    final userFriendlyMessage =
        _errorMessageService.getUserFriendlyAuthMessage(error, operation);

    // Log the technical details for debugging
    _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
    _logger.debug(userFriendlyMessage);

    // Map specific auth exceptions to appropriate UI states with user-friendly messages
    if (error is InvalidCredentialsException) {
      emit(InvalidCredentialsFailure(userFriendlyMessage));
    } else if (error is InvalidInputException) {
      emit(InvalidInputFailure(userFriendlyMessage));
    } else if (error is UserAlreadyExistsException) {
      emit(UserAlreadyExistsFailure(userFriendlyMessage));
    } else if (error is GenericAuthException) {
      // Use extension methods for cleaner error type checking
      if (error.isNetworkError) {
        emit(NetworkFailure(userFriendlyMessage));
      } else if (error.isServerError) {
        emit(ServerFailure(userFriendlyMessage));
      } else {
        // Generic fallback
        emit(AuthFailure(userFriendlyMessage));
      }
    } else {
      // Generic fallback for any other auth exceptions
      emit(AuthFailure(userFriendlyMessage));
    }
  }
}
