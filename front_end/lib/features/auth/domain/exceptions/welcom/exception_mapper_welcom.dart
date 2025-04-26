// welcome_exception_mapper.dart (domain interface)
import 'package:semo/core/domain/exceptions/api_exception_mapper.dart';
import 'package:semo/features/auth/domain/exceptions/welcom/exceptions_wlecom.dart';

/// Domain interface for welcome assets-specific exception mapping
/// Extends the core ApiExceptionMapper with welcome-specific exception type
abstract class WelcomeExceptionMapper
    extends ApiExceptionMapper<WelcomeException> {}
