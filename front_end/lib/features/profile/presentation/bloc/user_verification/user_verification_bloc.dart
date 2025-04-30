import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';
import 'package:semo/features/profile/presentation/bloc/user_verification/user_verification_event.dart';
import 'package:semo/features/profile/presentation/bloc/user_verification/user_verification_state.dart';
import 'package:semo/features/profile/presentation/services/user_verification/error_message_service.dart';

/// BLoC for managing user verification operations
class UserVerificationBloc
    extends Bloc<UserVerificationEvent, UserVerificationState> {
  final UserVerificationRepository _verificationRepository;
  final AppLogger _logger = AppLogger();
  final UserVerificationErrorMessageService _errorMessageService = UserVerificationErrorMessageService();

  UserVerificationBloc({
    required UserVerificationRepository verificationRepository,
  })  : _verificationRepository = verificationRepository,
        super(const UserVerificationInitial()) {
    on<RequestEmailVerificationEvent>(_onRequestEmailVerification);
    on<RequestPhoneVerificationEvent>(_onRequestPhoneVerification);
    on<VerifyCodeEvent>(_onVerifyCode);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onRequestEmailVerification(
    RequestEmailVerificationEvent event,
    Emitter<UserVerificationState> emit,
  ) async {
    _logger.debug('Requesting email verification for: ${event.email}');
    emit(const UserVerificationLoading());

    final result =
        await _verificationRepository.requestEmailVerification(event.email);

    emit(result.fold(
      (response) {
        _logger.debug('Successfully requested email verification');
        return EmailVerificationRequested(response: response);
      },
      (exception) {
        _logger.error('Error requesting email verification', error: exception);
        return _mapErrorToState(exception, 'email verification');
      },
    ));
  }

  Future<void> _onRequestPhoneVerification(
    RequestPhoneVerificationEvent event,
    Emitter<UserVerificationState> emit,
  ) async {
    _logger.debug('Requesting phone verification for: ${event.phoneNumber}');
    emit(const UserVerificationLoading());

    final result = await _verificationRepository
        .requestPhoneVerification(event.phoneNumber);

    emit(result.fold(
      (response) {
        _logger.debug('Successfully requested phone verification');
        return PhoneVerificationRequested(response: response);
      },
      (exception) {
        _logger.error('Error requesting phone verification', error: exception);
        return _mapErrorToState(exception, 'phone verification');
      },
    ));
  }

  Future<void> _onVerifyCode(
    VerifyCodeEvent event,
    Emitter<UserVerificationState> emit,
  ) async {
    _logger.debug(
        'Verifying code for user: ${event.userId}, type: ${event.verificationType}');
    emit(const UserVerificationLoading());

    final result = await _verificationRepository.verifyCode(
        event.userId, event.code, event.verificationType);

    emit(result.fold(
      (response) {
        _logger.debug('Successfully verified code');
        return CodeVerified(response: response);
      },
      (exception) {
        _logger.error('Error verifying code', error: exception);
        return _mapErrorToState(exception, 'code verification');
      },
    ));
  }

  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<UserVerificationState> emit,
  ) async {
    _logger.debug(
        'Requesting password reset for: ${event.email ?? event.phoneNumber}');
    emit(const UserVerificationLoading());

    final result = await _verificationRepository.requestPasswordReset(
        email: event.email, phoneNumber: event.phoneNumber);

    emit(result.fold(
      (response) {
        _logger.debug('Successfully requested password reset');
        return PasswordResetRequested(response: response);
      },
      (exception) {
        _logger.error('Error requesting password reset', error: exception);
        return _mapErrorToState(exception, 'password reset request');
      },
    ));
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<UserVerificationState> emit,
  ) async {
    _logger.debug('Resetting password for user: ${event.userId}');
    emit(const UserVerificationLoading());

    final result = await _verificationRepository.resetPassword(
        event.userId, event.code, event.newPassword);

    emit(result.fold(
      (response) {
        _logger.debug('Successfully reset password');
        return PasswordReset(response: response);
      },
      (exception) {
        _logger.error('Error resetting password', error: exception);
        return _mapErrorToState(exception, 'password reset');
      },
    ));
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all verification types
  UserVerificationFailureState _mapErrorToState(
    UserVerifException error,
    String verificationType,
  ) {
    _logger.error('Error during $verificationType', error: error);
    _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
    _logger.debug(_errorMessageService.getUserFriendlyMessage(error, verificationType));

    if (error.isNetworkError) {
      return UserVerificationNetworkFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error.isServerError) {
      return UserVerificationServerFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is UserNotFoundException) {
      return UserNotFoundFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is InvalidVerificationCodeException) {
      return InvalidVerificationCodeFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is EmailVerificationRequestFailedException) {
      return EmailVerificationRequestFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is PhoneVerificationRequestFailedException) {
      return PhoneVerificationRequestFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is PasswordResetRequestFailedException) {
      return PasswordResetRequestFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is PasswordResetFailedException) {
      return PasswordResetFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else {
      // Generic fallback
      return GenericVerificationFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    }
  }
}
