/// A class that represents either a success value of type T or a failure value of type E
class Result<T, E> {
  final T? _value;
  final E? _error;
  final bool isSuccess;

  // Private constructor
  const Result._({T? value, E? error, required this.isSuccess})
      : _value = value,
        _error = error;

  // Factory constructors
  /// Creates a success result with the given [value]
  factory Result.success(T value) => Result._(value: value, isSuccess: true);
  // Factory constructors
  /// Creates a failure result with the given [error]
  factory Result.failure(E error) => Result._(error: error, isSuccess: false);

  /// Returns true if this result represents a failure
  bool get isFailure => !isSuccess;

  /// Gets the success value if this is a success result, otherwise throws an exception
  T get value {
    if (isSuccess) {
      return _value as T;
    }
    throw Exception('Cannot get value from a failure result');
  }

  /// Gets the error value if this is a failure result, otherwise throws an exception
  E get error {
    if (isFailure) {
      return _error as E;
    }
    throw Exception('Cannot get error from a success result');
  }

  /// Maps the success value using the given [mapper] function
  Result<R, E> map<R>(R Function(T) mapper) {
    if (isSuccess) {
      return Result.success(mapper(_value as T));
    }
    return Result.failure(_error as E);
  }

  // fold method is the main method that handles the result (success or failure)
  /// Executes [onSuccess] if this is a success result, or [onFailure] if this is a failure result
  R fold<R>(R Function(T) onSuccess, R Function(E) onFailure) {
    if (isSuccess) {
      return onSuccess(_value as T);
    }
    return onFailure(_error as E);
  }
}
