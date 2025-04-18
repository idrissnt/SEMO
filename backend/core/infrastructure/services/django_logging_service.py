import json
import logging
import traceback
from typing import Any, Dict, Optional

from core.domain.services.logging_service_interface import LoggingServiceInterface, LogLevel

class DjangoLoggingService(LoggingServiceInterface):
    """Django implementation of the logging service interface"""
    
    def __init__(self, logger_name: str = "semo"):
        self.logger = logging.getLogger(logger_name)
    
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
        # Process context for logging
        log_context = {}
        if context:
            try:
                # Filter out None values and convert to string for JSON serialization
                log_context = {k: str(v) if v is not None else "" for k, v in context.items() if v is not None}
            except Exception:
                log_context = {"raw_context": str(context)}
        
        # Add exception info to context if provided
        if exception:
            log_context["exception"] = str(exception)
            if level in [LogLevel.ERROR, LogLevel.CRITICAL]:
                log_context["traceback"] = traceback.format_exc()
        
        # Use the message as is - context will be formatted by the JSON logger
        
        # Map domain log level to Python logging level
        log_method = {
            LogLevel.DEBUG: self.logger.debug,
            LogLevel.INFO: self.logger.info,
            LogLevel.WARNING: self.logger.warning,
            LogLevel.ERROR: self.logger.error,
            LogLevel.CRITICAL: self.logger.critical
        }.get(level, self.logger.info)
        
        # Log the message with context
        log_method(message, extra={"context": log_context})