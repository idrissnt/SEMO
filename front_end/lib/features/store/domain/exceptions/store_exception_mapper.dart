// store_exception_mapper.dart (domain interface)
import 'package:semo/core/domain/exceptions/api_exception_mapper.dart';
import 'package:semo/features/store/domain/exceptions/store_exceptions.dart';

/// Domain interface for store-specific exception mapping
/// Extends the core ApiExceptionMapper with store-specific exception type
abstract class StoreExceptionMapper
    extends ApiExceptionMapper<StoreException> {}
