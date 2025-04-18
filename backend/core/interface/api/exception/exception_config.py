"""
Exception mapping configuration for API error handling.

This module aggregates exception mappings from all apps and provides a centralized
lookup mechanism. Each app defines its own exception mappings in its interfaces/api/exception_mapping.py
file, which are then loaded here. This approach allows for a modular and scalable
error handling system while maintaining clean architecture principles.
"""
import importlib
from django.conf import settings

from core.interface.api.exception.exception_mapping import CORE_EXCEPTION_MAPPING, DEFAULT_EXCEPTION_MAPPING
from core.infrastructure.factories.logging_factory import CoreLoggingFactory

# Create a logger using our custom logging service
logger = CoreLoggingFactory.create_logger("exception_config")

# Aggregate exception mappings from all apps
EXCEPTION_MAPPING = {}
EXCEPTION_MAPPING.update(CORE_EXCEPTION_MAPPING)

# Dynamically load exception mappings from all installed apps
def load_app_exception_mappings():
    """
    Load exception mappings from all Django apps that have defined them.
    Each app should have a module at interfaces/api/exception_mapping.py
    with dictionaries named *_EXCEPTION_MAPPING.
    """
    for app in settings.INSTALLED_APPS:
        # Skip third-party apps
        if app.startswith('django.') or app.startswith('rest_framework'):
            continue
            
        # Try to import the exception mapping module
        try:
            # Convert django app name to python module path
            if app.endswith('.apps.Config'):
                app = app.rsplit('.', 2)[0]
                
            mapping_module = f"{app}.interfaces.api.exception.exception_mapping"
            module = importlib.import_module(mapping_module)
            
            # Find all exception mapping dictionaries in the module
            for attr_name in dir(module):
                if attr_name.endswith('_EXCEPTION_MAPPING'):
                    mapping_dict = getattr(module, attr_name)
                    if isinstance(mapping_dict, dict):
                        EXCEPTION_MAPPING.update(mapping_dict)
                        logger.debug(f"Loaded exception mapping from {mapping_module}.{attr_name}")
        except (ImportError, AttributeError) as e:
            # It's okay if an app doesn't have exception mappings
            logger.debug(f"No exception mappings found for {app}", {"error": str(e), "app": app})
            continue
        except Exception as e:
            # Log other errors but don't fail
            logger.warning(f"Error loading exception mappings from {app}", {"error": str(e), "app": app})
            continue

# Load mappings when the module is imported
try:
    load_app_exception_mappings()
except Exception as e:
    logger.error("Failed to load app exception mappings", {"error": str(e)})

def get_exception_mapping(exception):
    """
    Get the status code, error code, and log level for a given exception.
    
    Args:
        exception: The exception instance
        
    Returns:
        Tuple of (status_code, error_code, log_level)
    """
    # Try to find exact match by fully qualified class name
    exception_class_path = f"{exception.__class__.__module__}.{exception.__class__.__name__}"
    if exception_class_path in EXCEPTION_MAPPING:
        return EXCEPTION_MAPPING[exception_class_path]
    
    # Try to find match by parent class
    # Check if the exception is a subclass of a domain exception
    for class_path, mapping in EXCEPTION_MAPPING.items():
        module_path, class_name = class_path.rsplit('.', 1)
        try:
            module = __import__(module_path, fromlist=[class_name])
            parent_class = getattr(module, class_name)
            if isinstance(exception, parent_class):
                return mapping
        except (ImportError, AttributeError):
            continue
    
    # Return default mapping if no match found
    return DEFAULT_EXCEPTION_MAPPING
