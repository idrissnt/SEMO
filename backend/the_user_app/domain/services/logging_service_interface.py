from abc import ABC, abstractmethod
from enum import Enum
from typing import Any, Dict, Optional


class LogLevel(Enum):
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class LoggingServiceInterface(ABC):
    """Interface for logging services in the domain layer"""
    
    @abstractmethod
    def log(self, 
            level: LogLevel, 
            message: str, 
            context: Optional[Dict[str, Any]] = None,
            exception: Optional[Exception] = None) -> None:
        """Log a message with the specified level and context
        
        Args:
            level: The log level
            message: The log message
            context: Additional context data (user_id, request_id, etc.)
            exception: Optional exception to log
        """
        pass
    
    def debug(self, message: str, context: Optional[Dict[str, Any]] = None) -> None:
        self.log(LogLevel.DEBUG, message, context)
    
    def info(self, message: str, context: Optional[Dict[str, Any]] = None) -> None:
        self.log(LogLevel.INFO, message, context)
    
    def warning(self, message: str, context: Optional[Dict[str, Any]] = None) -> None:
        self.log(LogLevel.WARNING, message, context)
    
    def error(self, message: str, context: Optional[Dict[str, Any]] = None, exception: Optional[Exception] = None) -> None:
        self.log(LogLevel.ERROR, message, context, exception)
    
    def critical(self, message: str, context: Optional[Dict[str, Any]] = None, exception: Optional[Exception] = None) -> None:
        self.log(LogLevel.CRITICAL, message, context, exception)
