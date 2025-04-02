"""
Domain entities for notifications.

This module defines the domain entities for notifications following
Domain-Driven Design principles.
"""
from dataclasses import dataclass
from typing import Dict, Any, Optional
from uuid import UUID
from datetime import datetime

from deliveries.domain.models.value_objects import NotificationStatus

@dataclass
class DriverNotification:
    """Driver notification domain entity"""
    id: UUID
    driver_id: UUID
    delivery_id: UUID
    title: str
    body: str
    data: Dict[str, Any]
    status: NotificationStatus
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
