from dataclasses import dataclass
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime

from deliveries.domain.models.constants import DeliveryStatus, DeliveryEventType
from deliveries.domain.models.value_objects import GeoPoint, RouteInfo


@dataclass
class Driver:
    """Driver domain entity"""
    id: UUID
    user_id: UUID
    mean_time_taken: float
    license_number: Optional[str] = None
    is_available: bool = True
    has_vehicle: Optional[bool] = False

    def compute_mean_time_taken(self) -> None:
        # TODO: Implement mean time taken calculation
        pass


@dataclass
class DriverDevice:
    """Driver device domain entity for push notifications"""
    id: UUID
    driver_id: UUID
    device_token: str
    device_type: str  # 'android', 'ios', etc.
    is_active: bool = True
    created_at: datetime = None
    updated_at: datetime = None


@dataclass
class DriverLocation:
    """Driver location domain entity for tracking driver positions"""
    id: UUID
    driver_id: UUID
    location: GeoPoint
    timestamp: datetime
    is_active: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

