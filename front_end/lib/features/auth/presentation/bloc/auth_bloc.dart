import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:semo/features/auth/domain/exceptions/auth_error_extensions.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/auth/domain/usecases/auth_check_usecase.dart';
import 'package:semo/features/auth/presentation/bloc/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserAuthRepository _authRepository;
  final UserProfileUseCase _userProfileUseCase;
  final AppLogger _logger;

  AuthBloc({
    required UserAuthRepository authRepository,
    required UserProfileUseCase userProfileUseCase,
    required AppLogger logger,
  })  : _authRepository = authRepository,
        _userProfileUseCase = userProfileUseCase,
        _logger = logger,
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
      (authTokens) async {
        _logger.info('Login successful, fetching user profile');
        // After successful login, fetch the user profile
        final userResult = await _userProfileUseCase.getCurrentUser();
        userResult.fold(
          (user) {
            _logger.info('User profile fetched: ${user.email}');
            emit(AuthAuthenticated(user));
          },
          (error) {
            _logger.error('Failed to get user profile after login',
                error: error);
            // Use specific profile fetch error state with retry option
            emit(const ProfileFetchFailure(
                'Login successful but failed to get user profile'));
            // Don't immediately transition to unauthenticated - let UI handle retry
          },
        );
      },
      (error) {
        // Log the error without stack trace
        _logger.error('Bloc Login error', error: error.message);

        // Map domain exceptions to specific UI states
        if (error is InvalidCredentialsException) {
          emit(InvalidCredentialsFailure(error.message));
        } else if (error is InvalidInputException) {
          emit(InvalidInputFailure(error.message));
        } else if (error is GenericAuthException) {
          // Use extension methods for cleaner error type checking
          if (error.isNetworkError) {
            emit(NetworkFailure(error.getNetworkErrorMessage('login')));
          } else if (error.isServerError) {
            emit(ServerFailure(error.getServerErrorMessage('login')));
          } else {
            // Generic fallback
            emit(AuthFailure(error.message));
          }
        } else {
          // Generic fallback
          emit(AuthFailure(error.message));
        }
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
      lastName: event.lastName,
      phoneNumber: event.phoneNumber,
      profilePhotoUrl: event.profilePhotoUrl,
    );

    result.fold(
      (authTokens) async {
        _logger.info('Registration successful, fetching user profile');
        // After successful registration, fetch the user profile
        final userResult = await _userProfileUseCase.getCurrentUser();
        userResult.fold(
          (user) {
            _logger.info('User profile fetched: ${user.email}');
            emit(AuthAuthenticated(user));
          },
          (error) {
            _logger.error('Failed to get user profile after registration',
                error: error);
            // Use specific profile fetch error state with retry option
            emit(const ProfileFetchFailure(
                'Registration successful but failed to get user profile'));
            // Don't immediately transition to unauthenticated - let UI handle retry
          },
        );
      },
      (error) {
        _logger.error('Registration error', error: error);

        // Map domain exceptions to specific UI states
        if (error is UserAlreadyExistsException) {
          emit(UserAlreadyExistsFailure(error.message));
        } else if (error is InvalidInputException) {
          emit(InvalidInputFailure(error.message));
        } else if (error is GenericAuthException) {
          // Use extension methods for cleaner error type checking
          if (error.isNetworkError) {
            emit(NetworkFailure(error.getNetworkErrorMessage('registration')));
          } else if (error.isServerError) {
            emit(ServerFailure(error.getServerErrorMessage('registration')));
          } else {
            // Generic fallback
            emit(AuthFailure(error.message));
          }
        } else {
          // Generic fallback
          emit(AuthFailure(error.message));
        }
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
        // Map domain exceptions to specific UI states
        if (error is MissingRefreshTokenException) {
          // We can handle this gracefully - just log out locally
          _logger
              .warning('Missing refresh token during logout: ${error.message}');
          emit(AuthUnauthenticated());
          return;
        } else if (error is GenericAuthException) {
          // Use extension methods for cleaner error type checking
          if (error.isNetworkError) {
            emit(NetworkFailure(error.getNetworkErrorMessage('logout')));
          } else if (error.isServerError) {
            emit(ServerFailure(error.getServerErrorMessage('logout')));
          } else {
            // Generic fallback
            emit(AuthFailure(error.message));
          }
        } else {
          // Generic fallback
          emit(AuthFailure(error.message));
        }

        // Even if there was an error, we still want to log out locally
        emit(AuthUnauthenticated());
      },
    );
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
}
