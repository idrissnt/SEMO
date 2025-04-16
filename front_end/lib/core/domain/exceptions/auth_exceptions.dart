/// Base class for all domain-specific exceptions
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  final String? requestId;

  DomainException(this.message, {this.code, this.requestId});

  @override
  String toString() => message;
}
