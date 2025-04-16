import json
import logging
import traceback
from typing import Any, Dict, Optional

from the_user_app.domain.services.logging_service_interface import LoggingServiceInterface, LogLevel

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
        # Format context as JSON if provided
        context_str = ""
        if context:
            try:
                # Filter out None values and convert to string for JSON serialization
                filtered_context = {k: str(v) if v is not None else "" for k, v in context.items() if v is not None}
                context_str = f" | Context: {json.dumps(filtered_context)}"
            except Exception:
                context_str = f" | Context: {str(context)}"
        
        # Format exception if provided
        exception_str = ""
        if exception:
            exception_str = f" | Exception: {str(exception)}"
            if level in [LogLevel.ERROR, LogLevel.CRITICAL]:
                exception_str += f"\n{traceback.format_exc()}"
        
        # Combine message components
        full_message = f"{message}{context_str}{exception_str}"
        
        # Map domain log level to Python logging level
        log_method = {
            LogLevel.DEBUG: self.logger.debug,
            LogLevel.INFO: self.logger.info,
            LogLevel.WARNING: self.logger.warning,
            LogLevel.ERROR: self.logger.error,
            LogLevel.CRITICAL: self.logger.critical
        }.get(level, self.logger.info)
        
        # Log the message
        log_method(full_message)
