import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/domain/exceptions/api_error_extensions.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/home/domain/usecases/verify_email_code_usecase.dart';
import 'package:semo/features/home/presentation/bloc/email_verification/verify_email_code_event.dart';
import 'package:semo/features/home/presentation/bloc/email_verification/verify_email_code_state.dart';

import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';
import 'package:semo/features/profile/presentation/services/user_verification/error_message_service.dart';

/// BLoC for managing email verification operations
class VerifyEmailCodeBloc
    extends Bloc<VerifyEmailCodeEvent, VerifyEmailCodeState> {
  final VerifyEmailCodeUseCase _verifyEmailCodeUseCase;
  final AppLogger _logger = AppLogger();
  final UserVerificationErrorMessageService _errorMessageService =
      UserVerificationErrorMessageService();

  VerifyEmailCodeBloc({
    required VerifyEmailCodeUseCase verifyEmailCodeUseCase,
  })  : _verifyEmailCodeUseCase = verifyEmailCodeUseCase,
        super(const VerifyEmailCodeInitial()) {
    on<VerifyEmailCodeEvent>(_onVerifyEmailCode);
  }

  /// Handle verify email code event
  Future<void> _onVerifyEmailCode(
    VerifyEmailCodeEvent event,
    Emitter<VerifyEmailCodeState> emit,
  ) async {
    _logger.debug('Verifying email code for user: ${event.userId}');
    emit(const VerifyEmailCodeLoading());

    final result = await _verifyEmailCodeUseCase.verifyEmailCode(
      event.userId,
      event.code,
    );

    emit(result.fold(
      (response) {
        _logger.debug('Successfully verified email code');
        return VerifyEmailCodeVerified(response: response);
      },
      (exception) {
        _logger.error('Error verifying email code', error: exception);
        return _mapErrorToState(exception, 'email code verification');
      },
    ));
  }

  /// Maps domain exceptions to specific UI states
  /// This centralizes error handling logic for all email verification operations
  VerifyEmailCodeFailureState _mapErrorToState(
    UserVerifException error,
    String verificationType,
  ) {
    _logger.error('Error during $verificationType', error: error);
    _logger.debug(_errorMessageService.getTechnicalErrorDetails(error));
    _logger.debug(
        _errorMessageService.getUserFriendlyMessage(error, verificationType));

    if (error.isNetworkError) {
      return VerifyEmailCodeNetworkFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error.isServerError) {
      return VerifyEmailCodeServerFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else if (error is InvalidVerificationCodeException) {
      return VerifyEmailCodeInvalid(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    } else {
      // Generic fallback
      return GenericVerifyEmailCodeFailure(
        _errorMessageService.getUserFriendlyMessage(error, verificationType),
        canRetry: true,
      );
    }
  }
}
