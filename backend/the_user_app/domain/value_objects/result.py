"""
Result pattern implementation for domain operations.

This module provides a Result class that can be used to represent the outcome of domain operations.
It allows for explicit handling of success and failure cases, making error handling more robust.
"""
from typing import TypeVar, Generic, Optional, Any, Union

T = TypeVar('T')  # Success type
E = TypeVar('E')  # Error type

class Result(Generic[T, E]):
    """
    Represents the result of an operation that can either succeed with a value of type T
    or fail with an error of type E.
    
    This pattern helps make error handling more explicit and avoids using exceptions
    for control flow in business logic.
    """
    
    def __init__(self, value: Optional[T] = None, error: Optional[E] = None):
        self._value = value
        self._error = error
        self._is_success = error is None
    
    @classmethod
    def success(cls, value: T) -> 'Result[T, E]':
        """Create a successful result with the given value"""
        return cls(value=value)
    
    @classmethod
    def failure(cls, error: E) -> 'Result[T, E]':
        """Create a failed result with the given error"""
        return cls(error=error)
    
    def is_success(self) -> bool:
        """Check if the result is successful"""
        return self._is_success
    
    def is_failure(self) -> bool:
        """Check if the result is a failure"""
        return not self._is_success
    
    @property
    def value(self) -> T:
        """Get the success value (raises ValueError if result is a failure)"""
        if not self._is_success:
            raise ValueError("Cannot get value from a failed result")
        return self._value
    
    @property
    def error(self) -> E:
        """Get the error (raises ValueError if result is successful)"""
        if self._is_success:
            raise ValueError("Cannot get error from a successful result")
        return self._error
    
    def on_success(self, callback):
        """Execute callback if result is successful and return self for chaining"""
        if self._is_success:
            callback(self._value)
        return self
    
    def on_failure(self, callback):
        """Execute callback if result is a failure and return self for chaining"""
        if not self._is_success:
            callback(self._error)
        return self
    
    def map(self, mapper):
        """
        Transform the success value using the provided mapper function
        and return a new Result with the transformed value
        """
        if self._is_success:
            return Result.success(mapper(self._value))
        return Result.failure(self._error)
    
    def flat_map(self, mapper):
        """
        Apply the mapper function to the success value to produce a new Result
        If this result is a failure, the mapper is not called
        """
        if self._is_success:
            return mapper(self._value)
        return Result.failure(self._error)
