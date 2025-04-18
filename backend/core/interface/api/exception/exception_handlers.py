"""
Global exception handlers for the API.

This module contains custom exception handlers that convert domain exceptions and DRF exceptions
to standardized API responses following clean architecture principles.
"""
import uuid
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError, AuthenticationFailed, NotAuthenticated

from .exception_config import get_exception_mapping
from core.infrastructure.factories.logging_factory import CoreLoggingFactory

# Create a logger using our custom logging service
logger = CoreLoggingFactory.create_logger("exception_handlers")

def get_request_meta(request):
    """Extract useful metadata from request for logging"""
    if not request:
        return {}
        
    return {
        'ip': request.META.get('REMOTE_ADDR', 'unknown'),
        'user_agent': request.META.get('HTTP_USER_AGENT', 'unknown'),
        'request_id': request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4())),
        'path': request.path,
        'method': request.method,
        'user_id': getattr(request.user, 'id', None)
    }

def domain_exception_handler(exc, context):
    """Handle domain-specific exceptions and convert them to API responses
    
    This handler uses a configuration-based approach to map exceptions to appropriate
    HTTP status codes and error codes. This allows for a more maintainable and
    scalable error handling system that follows clean architecture principles.
    
    Args:
        exc: The exception that was raised
        context: The context for the exception, including the request
        
    Returns:
        Response object with standardized error format or None if the exception
        should be handled by Django's default handler
    """
    # Get request metadata for logging and response
    request = context.get('request')
    request_meta = get_request_meta(request)
    request_id = request_meta.get('request_id')
    
    # Handle DRF's built-in exceptions
    if isinstance(exc, ValidationError):
        # Format validation errors
        logger.warning(f"Validation error: {str(exc.detail)}", request_meta)
        
        return Response({
            'error': 'Invalid input data',
            'details': exc.detail,
            'code': 'validation_error',
            'request_id': request_id
        }, status=status.HTTP_400_BAD_REQUEST)
    
    elif isinstance(exc, (AuthenticationFailed, NotAuthenticated)):
        # Format authentication errors
        logger.warning(f"Authentication error: {str(exc)}", request_meta)
        
        return Response({
            'error': str(exc),
            'code': 'authentication_error',
            'request_id': request_id
        }, status=status.HTTP_401_UNAUTHORIZED)
    
    # For other DRF exceptions, try the default handler first
    response = exception_handler(exc, context)
    
    # If handled by DRF but not by our custom handlers above,
    # reformat to match our standard error format
    if response is not None and not isinstance(exc, (ValidationError, AuthenticationFailed, NotAuthenticated)):
        # Extract the error message
        error_message = str(exc)
        if hasattr(response, 'data') and isinstance(response.data, dict):
            if 'detail' in response.data:
                error_message = response.data['detail']
        
        # Create standardized error response
        response.data = {
            'error': error_message,
            'code': getattr(exc, 'default_code', 'api_error'),
            'request_id': request_id
        }
        
        return response
    
    # Handle domain and other exceptions using the configuration-based approach
    # Get the mapping for this exception
    status_code, error_code, log_level = get_exception_mapping(exc)
    
    # Prepare the error response data
    data = {
        'error': str(exc),
        'code': getattr(exc, 'code', error_code),  # Use exception's code if available
        'request_id': request_id
    }
    
    # Log the exception with the appropriate level
    log_message = f"{exc.__class__.__name__}: {str(exc)}"
    if log_level == 'debug':
        logger.debug(log_message, request_meta)
    elif log_level == 'info':
        logger.info(log_message, request_meta)
    elif log_level == 'warning':
        logger.warning(log_message, request_meta)
    elif log_level == 'error':
        logger.error(log_message, request_meta, exc)
    else:  # Default to exception for unknown levels or critical errors
        logger.critical(log_message, request_meta, exc)
    
    # Return the standardized error response
    return Response(data, status=status_code)
