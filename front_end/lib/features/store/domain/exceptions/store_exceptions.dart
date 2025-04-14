/// Base exception for all store-related errors
class StoreException implements Exception {
  final String message;
  final dynamic originalError;

  StoreException(this.message, [this.originalError]);

  @override
  String toString() => 'StoreException: $message';
}

/// Exception thrown when store data cannot be found
class StoreNotFoundException extends StoreException {
  StoreNotFoundException(String message, [dynamic originalError]) 
      : super(message, originalError);
  
  @override
  String toString() => 'StoreNotFoundException: $message';
}

/// Exception thrown when store data cannot be retrieved due to network issues
class StoreNetworkException extends StoreException {
  StoreNetworkException(String message, [dynamic originalError]) 
      : super(message, originalError);
  
  @override
  String toString() => 'StoreNetworkException: $message';
}

/// Exception thrown when store search operations fail
class StoreSearchException extends StoreException {
  StoreSearchException(String message, [dynamic originalError]) 
      : super(message, originalError);
  
  @override
  String toString() => 'StoreSearchException: $message';
}

/// Exception thrown when product data cannot be found
class ProductNotFoundException extends StoreException {
  ProductNotFoundException(String message, [dynamic originalError]) 
      : super(message, originalError);
  
  @override
  String toString() => 'ProductNotFoundException: $message';
}

/// Exception thrown when authentication is required but missing
class StoreAuthenticationException extends StoreException {
  StoreAuthenticationException(String message, [dynamic originalError]) 
      : super(message, originalError);
  
  @override
  String toString() => 'StoreAuthenticationException: $message';
}
