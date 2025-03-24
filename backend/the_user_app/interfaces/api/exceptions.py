from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
import logging

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    """
    Custom exception handler for Django REST Framework that improves error responses.
    
    Args:
        exc: The exception object
        context: The exception context
        
    Returns:
        Response object with appropriate status and error details
    """
    # Call REST framework's default exception handler first
    response = exception_handler(exc, context)
    
    # If response is None, there was an unhandled exception
    if response is None:
        logger.error(f"Unhandled exception: {str(exc)}")
        return Response(
            {"error": "An unexpected error occurred."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    # Add more context to the error response
    if hasattr(exc, 'detail'):
        # Get the error details
        error_details = exc.detail
        
        # Format the error response
        if isinstance(error_details, dict):
            # If error_details is a dict (field errors)
            response.data = {
                "error": "Validation error",
                "details": error_details
            }
        elif isinstance(error_details, list):
            # If error_details is a list
            response.data = {
                "error": error_details[0] if error_details else "An error occurred",
                "details": error_details
            }
        else:
            # If error_details is a string or other
            response.data = {
                "error": str(error_details)
            }
    
    # Log the error
    logger.error(f"API error: {response.status_code} - {response.data}")
    
    return response
