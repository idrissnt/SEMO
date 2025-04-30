import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/services/email_verification_usecase.dart';
import 'package:semo/features/auth/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:semo/features/auth/presentation/bloc/email_verification/email_verification_state.dart';
import 'package:semo/features/auth/presentation/services/email_verification/error_message_service.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';

/// BLoC for managing email verification operations
class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final EmailVerificationUseCase _emailVerificationUseCase;
  final AppLogger _logger = AppLogger();
  final EmailVerificationErrorMessageService _errorMessageService =
      EmailVerificationErrorMessageService();

  EmailVerificationBloc({
    required EmailVerificationUseCase emailVerificationUseCase,
  })  : _emailVerificationUseCase = emailVerificationUseCase,
        super(const EmailVerificationInitial()) {
    on<RequestEmailVerificationEvent>(_onRequestEmailVerification);
    on<VerifyEmailCodeEvent>(_onVerifyEmailCode);
  }

  /// Handle request email verification event
  Future<void> _onRequestEmailVerification(
    RequestEmailVerificationEvent event,
    Emitter<EmailVerificationState> emit,
  ) async {
    _logger.debug('Requesting email verification for: ${event.email}');
    emit(const EmailVerificationLoading());

    final result =
        await _emailVerificationUseCase.requestEmailVerification(event.email);

    emit(result.fold(
      (response) {
        _logger.debug('Successfully requested email verification');
        return EmailVerificationRequested(response: response);
      },
      (exception) {
        _logger.error('Error requesting email verification', error: exception);
        return _mapErrorToState(exception, 'email verification request');
      },
    ));
  }

  /// Handle verify email code event
  Future<void> _onVerifyEmailCode(
    VerifyEmailCodeEvent event,
    Emitter<EmailVerificationState> emit,
  ) async {
    _logger.debug('Verifying email code for user: ${event.userId}');
    emit(const EmailVerificationLoading());

    final result = await _emailVerificationUseCase.verifyEmailCode(
      event.userId,
      event.code,
    );

    emit(result.fold(
      (response) {
        _logger.debug('Successfully verified email code');
        return EmailCodeVerified(response: response);
      },
      (exception) {
        _logger.error('Error verifying email code', error: exception);
        return _mapErrorToState(exception, 'email code verification');
      },
    ));
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all email verification operations
  EmailVerificationFailureState _mapErrorToState(
    UserVerifException error,
    String verificationType,
  ) {
    _logger.error('Error during $verificationType', error: error);
    _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
    _logger.debug(
        _errorMessageService.getUserFriendlyMessage(error, verificationType));

    if (error.isNetworkError) {
      return EmailVerificationNetworkFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error.isServerError) {
      return EmailVerificationServerFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is UserNotFoundException) {
      return EmailUserNotFoundFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is InvalidVerificationCodeException) {
      return InvalidEmailVerificationCodeFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is EmailVerificationRequestFailedException) {
      return EmailVerificationRequestFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else {
      // Generic fallback
      return GenericEmailVerificationFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    }
  }
}
