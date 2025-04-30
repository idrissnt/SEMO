// verif_exception_mapper.dart (domain interface)
import 'package:semo/core/domain/exceptions/api_exception_mapper.dart';
import 'package:semo/features/profile/domain/exceptions/user_verifications/verif_exceptions.dart';

/// Domain interface for user verification-specific exception mapping
/// Extends the core ApiExceptionMapper with user verification-specific exception type
abstract class UserVerificationExceptionMapper
    extends ApiExceptionMapper<UserVerifException> {}
