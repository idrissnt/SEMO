"""
Core domain exceptions.

This module contains base exceptions that can be used across all domain modules.
"""

class CoreDomainException(Exception):
    """Base exception for all domain exceptions across the system"""
    def __init__(self, message="A domain error occurred", code=None):
        self.message = message
        self.code = code or self.__class__.__name__.lower()
        super().__init__(self.message)
    
    def __str__(self):
        return self.message
