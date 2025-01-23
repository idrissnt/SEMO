from rest_framework.views import exception_handler
from rest_framework.exceptions import APIException
from rest_framework import status
from rest_framework.response import Response
import logging

logger = logging.getLogger(__name__)

class CustomAPIException(APIException):
    status_code = status.HTTP_400_BAD_REQUEST
    default_detail = 'A server error occurred.'

    def __init__(self, detail=None, status_code=None):
        if status_code is not None:
            self.status_code = status_code
        if detail is not None:
            self.detail = detail
        else:
            self.detail = self.default_detail

def custom_exception_handler(exc, context):
    """Custom exception handler for DRF"""
    
    response = exception_handler(exc, context)
    
    if response is not None:
        # Log the error
        logger.error(f"Error: {str(exc)} | Status: {response.status_code}")
        
        response.data = {
            'success': False,
            'status_code': response.status_code,
            'message': response.data.get('detail', str(exc)),
            'errors': response.data if isinstance(response.data, dict) else None
        }
    else:
        # Handle unexpected exceptions
        logger.error(f"Unhandled Exception: {str(exc)}")
        response = Response({
            'success': False,
            'status_code': status.HTTP_500_INTERNAL_SERVER_ERROR,
            'message': 'An unexpected error occurred',
            'errors': str(exc)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return response
