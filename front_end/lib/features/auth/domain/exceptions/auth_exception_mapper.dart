// auth_exception_mapper.dart (domain interface)
import 'package:semo/core/domain/exceptions/api_exception_mapper.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';

/// Domain interface for auth-specific exception mapping
/// Extends the core ApiExceptionMapper with auth-specific exception type
abstract class AuthExceptionMapper
    extends ApiExceptionMapper<AuthenticationException> {}
