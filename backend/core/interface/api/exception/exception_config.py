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
    
    This function looks for exception mappings in three ways, in order of preference:
    1. From the get_exception_mappings() method on the app's AppConfig
    2. From the app's exception_mappings module (flexible path)
    3. From the legacy path: app.interfaces.api.exception.exception_mapping
    """
    for app_label in settings.INSTALLED_APPS:
        # Skip third-party apps
        if app_label.startswith('django.') or app_label.startswith('rest_framework'):
            continue
            
        # Try to get the app config
        try:
            from django.apps import apps
            app_config = apps.get_app_config(app_label.split('.')[-1])
            
            # Method 1: Check if the app config has a get_exception_mappings method
            if hasattr(app_config, 'get_exception_mappings') and callable(app_config.get_exception_mappings):
                mappings = app_config.get_exception_mappings()
                if isinstance(mappings, dict):
                    EXCEPTION_MAPPING.update(mappings)
                    logger.debug(f"Loaded exception mappings from {app_label} AppConfig")
                    continue
            
            # Method 2: Try to import from a flexible path
            app_module = app_config.module.__name__
            possible_paths = [
                f"{app_module}.exception_mappings",
                f"{app_module}.exceptions.mappings",
                f"{app_module}.api.exceptions",
                f"{app_module}.interfaces.api.exception_mapping",
                # Legacy path as fallback
                f"{app_module}.interfaces.api.exception.exception_mapping"
            ]
            
            for path in possible_paths:
                try:
                    module = importlib.import_module(path)
                    found_mappings = False
                    
                    # Find all exception mapping dictionaries in the module
                    for attr_name in dir(module):
                        if attr_name.endswith('_EXCEPTION_MAPPING') or attr_name == 'EXCEPTION_MAPPING':
                            mapping_dict = getattr(module, attr_name)
                            if isinstance(mapping_dict, dict):
                                EXCEPTION_MAPPING.update(mapping_dict)
                                logger.debug(f"Loaded exception mapping from {path}.{attr_name}")
                                found_mappings = True
                    
                    if found_mappings:
                        break  # Stop trying other paths if we found mappings
                        
                except (ImportError, AttributeError):
                    continue  # Try the next path
                    
        except Exception as e:
            # Log errors but don't fail
            logger.debug(f"No exception mappings found for {app_label}", {"error": str(e), "app": app_label})

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
