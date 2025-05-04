import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/core/domain/entities/user_entity.dart';

import 'package:semo/features/auth/domain/exceptions/auth/auth_exceptions.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/auth/domain/services/auth_check_usecase.dart';
import 'package:semo/features/auth/domain/services/email_verification_usecase.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/services/auth/auth_error_message_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserAuthRepository _authRepository;
  final UserProfileUseCase _userProfileUseCase;
  final EmailVerificationUseCase _emailVerificationUseCase;
  final AppLogger _logger;
  final AuthErrorMessageService _errorMessageService;

  final String logName = 'Auth Bloc';

  AuthBloc({
    required UserAuthRepository authRepository,
    required UserProfileUseCase userProfileUseCase,
    required EmailVerificationUseCase emailVerificationUseCase,
    required AppLogger logger,
  })  : _authRepository = authRepository,
        _userProfileUseCase = userProfileUseCase,
        _emailVerificationUseCase = emailVerificationUseCase,
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
    _logger
        .info(' [$logName] : Starting login process for user: ${event.email}');
    emit(AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    // Use await with fold by converting it to a Future
    await Future.value(result.fold(
      (authTokens) async {
        _logger.info(' [$logName] : Login successful, fetching user profile');
        await _fetchUserProfile(emit, 'login');
      },
      (error) {
        _logger.error(' [$logName] : Bloc Login error', error: error.message);
        _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
        _mapErrorToState(emit, error, 'login');
      },
    ));
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info(' [$logName] : Starting registration process');
    emit(AuthLoading());

    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      phoneNumber: event.phoneNumber,
      profilePhotoUrl: event.profilePhotoUrl,
    );

    // Use await with fold by converting it to a Future
    await Future.value(result.fold(
      (authTokens) async {
        _logger.info(
            ' [$logName] : Registration successful, fetching user profile');
        await _fetchUserProfile(emit, 'registration');

        // Automatically send email verification after successful registration
        _logger.info(
            ' [$logName] : Requesting email verification for: ${event.email}');

        final verificationResult = await _emailVerificationUseCase
            .requestEmailVerification(event.email);

        verificationResult.fold(
          (response) {
            _logger.info(
                ' [$logName] : Email verification requested successfully');
          },
          (error) {
            // Just log the error but don't change the auth state
            // This way the user can still proceed with using the app
            _logger.error(' [$logName] : Failed to request email verification',
                error: error);
          },
        );
      },
      (error) {
        _logger.error(' [$logName] : Registration error', error: error.message);
        _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
        _mapErrorToState(emit, error, 'registration');
      },
    ));
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Get the current user's email from the current state
    String email = '';
    if (state is AuthAuthenticated) {
      email = (state as AuthAuthenticated).user.email;
    }

    _logger.info(' [$logName] : BLOC Starting logout process for user: $email');
    emit(AuthLoading());

    final result = await _authRepository.logout(email: email);

    // Even if the server request fails, we want to log out locally
    result.fold(
      (_) {
        _logger.info(' [$logName] : BLOC Logout successful for user: $email');
        emit(AuthUnauthenticated());
      },
      (error) {
        _logger.error(' [$logName] : Logout error', error: error.message);
        _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));

        // Special case for logout - handle missing token gracefully
        if (error is MissingRefreshTokenException) {
          _logger.warning(
              ' [$logName] : Missing refresh token during logout: ${error.message}');
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
    _logger.info(' [$logName] : Resetting auth state to initial');
    emit(AuthInitial());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info(
        ' [$logName] : BLOC AuthCheckRequested: Starting authentication check');
    emit(AuthLoading());
    try {
      // First, check if tokens exist
      final hasAccessToken = await _userProfileUseCase.getAccessToken();
      final hasRefreshToken = await _userProfileUseCase.getRefreshToken();
      _logger.info(
          ' [$logName] : Access Token Status: ${hasAccessToken ? 'EXISTS' : 'NULL'}');
      _logger.info(
          ' [$logName] : Refresh Token Status: ${hasRefreshToken ? 'EXISTS' : 'NULL'}');

      // If no refresh token, user must log in
      if (!hasRefreshToken) {
        _logger.info(
            ' [$logName] : No refresh token found. Emitting Unauthenticated state.');
        emit(AuthUnauthenticated());
        return;
      }

      // Try to refresh the token
      _logger.debug(' [$logName] : About to attempt token refresh');
      final tokenRefreshed = await _userProfileUseCase.refreshToken();

      if (!tokenRefreshed) {
        _logger.info(
            ' [$logName] : Token refresh failed. Emitting token error state.');
        emit(const AuthFailure('Session expired. Please log in again.',
            canRetry: false));
        emit(AuthUnauthenticated());
        return;
      }

      // Get the current user
      final userResult = await _userProfileUseCase.getCurrentUser();
      userResult.fold(
        (user) {
          _logger.info(' [$logName] : User authenticated: ${user.email}');
          emit(AuthAuthenticated(user));
        },
        (error) {
          _logger.error(' [$logName] : Failed to get user data', error: error);
          // Check if the error is a "user not found" error
          if (error is UserNotFoundException || error.isUserNotFoundException) {
            _logger.warning(
                ' [$logName] : User not found exception detected, clearing tokens and logging out');
            // Clear tokens since the user doesn't exist anymore
            _userProfileUseCase.clearAllTokens();

            // Show a more specific error message
            emit(const AuthFailure(
                'Your account could not be found. Please log in again.',
                canRetry: false));

            // Transition to unauthenticated state
            emit(AuthUnauthenticated());
          } else {
            // For other errors, keep the current behavior
            emit(const ProfileFetchFailure(
                'Could not retrieve your profile. Tap to retry.'));
          }
        },
      );
    } catch (e) {
      _logger.error(' [$logName] : Authentication check failed', error: e);
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
      final userResult = await _userProfileUseCase.getCurrentUser();

      userResult.fold(
        (user) {
          _logger.info(' [$logName] : User profile fetched: ${user.email}');
          emit(AuthAuthenticated(user));
        },
        (error) {
          _logger.error(
              ' [$logName] : Failed to get user profile after $operation',
              error: error);
          _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
          // Use specific profile fetch error state with retry option
          emit(ProfileFetchFailure(_errorMessageService
              .getUserFriendlyAuthMessage(error, 'profile')));
          // Don't immediately transition to unauthenticated - let UI handle retry
        },
      );
    } catch (e) {
      _logger.error(' [$logName] : Exception in _fetchUserProfile', error: e);
      if (!emit.isDone) {
        emit(const AuthFailure(
            'An unexpected error occurred fetching your profile'));
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
    _logger.info(' [$logName] : Entering guest mode');
    emit(AuthLoading());

    // Create a guest user using the factory constructor
    final guestUser = User.guest();

    // Emit authenticated state with the guest user
    _logger.info(' [$logName] : Guest user created: ${guestUser.email}');
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
