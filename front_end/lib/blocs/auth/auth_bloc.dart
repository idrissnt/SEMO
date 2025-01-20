// ignore_for_file: unused_import

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final _logger = Logger('AuthBloc');

  AuthBloc({required AuthService authService})
      : _authService = authService,
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
      // ignore: unused_local_variable
      final result = await _authService.login(
        email: event.email,
        password: event.password,
      );
      _logger.info('Login successful, fetching user profile');
      final user = await _authService.getUserProfile();
      if (user != null) {
        _logger.info('User profile fetched successfully');
        emit(AuthAuthenticated(user));
      } else {
        _logger.warning('User profile not found after login');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _logger.severe('Login failed: $e');
      emit(AuthFailure(e.toString()));
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
      _logger.info('Sending registration request for user: ${event.email}');
      await _authService.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      _logger.info('Registration successful, proceeding to login');
      
      // Automatically login after successful registration
      final result = await _authService.login(
        email: event.email,
        password: event.password,
      );
      _logger.info('Auto-login successful, fetching user profile');
      
      final user = await _authService.getUserProfile();
      if (user != null) {
        _logger.info('User profile fetched successfully after registration');
        emit(AuthAuthenticated(user));
      } else {
        _logger.warning('User profile not found after registration');
        emit(AuthFailure('Could not fetch user profile'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _logger.severe('Registration/Auto-login failed: $e');
      String errorMessage = 'Registration failed';
      
      if (e.toString().contains('password')) {
        if (e.toString().contains('8 characters')) {
          errorMessage = 'Password must be at least 8 characters long';
        } else {
          errorMessage = 'Password is not strong enough. Please include numbers and special characters';
        }
      } else if (e.toString().contains('email')) {
        if (e.toString().contains('already exists')) {
          errorMessage = 'An account with this email already exists';
        } else {
          errorMessage = 'Please enter a valid email address';
        }
      } else if (e.toString().contains('first_name')) {
        errorMessage = 'First name is required';
      } else if (e.toString().contains('last_name')) {
        errorMessage = 'Last name is required';
      }
      
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
      await _authService.logout();
      _logger.info('Logout successful');
      emit(AuthUnauthenticated());
    } catch (e) {
      _logger.severe('Logout failed: $e');
      emit(AuthFailure(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('Checking authentication status');
    emit(AuthLoading());
    try {
      final token = await _authService.getAccessToken();
      if (token != null) {
        _logger.info('Access token found, fetching user profile');
        final user = await _authService.getUserProfile();
        if (user != null) {
          _logger.info('User profile fetched successfully');
          emit(AuthAuthenticated(user));
        } else {
          _logger.warning('No user profile found with valid token');
          emit(AuthUnauthenticated());
        }
      } else {
        _logger.info('No access token found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _logger.severe('Auth check failed: $e');
      emit(AuthUnauthenticated());
    }
  }
}
