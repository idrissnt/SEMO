"""
Application status value object.
"""
from enum import Enum


class ApplicationStatus(Enum):
    """Enum representing the status of a task application"""
    PENDING = "pending"  # Initial application
    NEGOTIATING = "negotiating"  # Price negotiation in progress
    ACCEPTED = "accepted"  # Application accepted by requester
    REJECTED = "rejected"  # Application rejected by requester
    WITHDRAWN = "withdrawn"  # Application withdrawn by performer
    
    @classmethod
    def choices(cls):
        """Return the enum values as Django model field choices."""
        return [(status.value, status.name) for status in cls]
