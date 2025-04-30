import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/repositories/user_verification/user_verification_repository.dart';
import 'package:semo/features/profile/presentation/bloc/user_verification/user_verification_event.dart';
import 'package:semo/features/profile/presentation/bloc/user_verification/user_verification_state.dart';

/// BLoC for managing user verification operations
class UserVerificationBloc
    extends Bloc<UserVerificationEvent, UserVerificationState> {
  final UserVerificationRepository _verificationRepository;
  final AppLogger _logger = AppLogger();

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
      (_) {
        _logger.debug('Successfully requested email verification');
        return const EmailVerificationRequested();
      },
      (exception) {
        _logger.error('Error requesting email verification', error: exception);
        return UserVerificationError(exception: exception);
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
      (_) {
        _logger.debug('Successfully requested phone verification');
        return const PhoneVerificationRequested();
      },
      (exception) {
        _logger.error('Error requesting phone verification', error: exception);
        return UserVerificationError(exception: exception);
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
      (_) {
        _logger.debug('Successfully verified code');
        return const CodeVerified();
      },
      (exception) {
        _logger.error('Error verifying code', error: exception);
        return UserVerificationError(exception: exception);
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
      (_) {
        _logger.debug('Successfully requested password reset');
        return const PasswordResetRequested();
      },
      (exception) {
        _logger.error('Error requesting password reset', error: exception);
        return UserVerificationError(exception: exception);
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
      (_) {
        _logger.debug('Successfully reset password');
        return const PasswordReset();
      },
      (exception) {
        _logger.error('Error resetting password', error: exception);
        return UserVerificationError(exception: exception);
      },
    ));
  }
}
