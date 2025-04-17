from dataclasses import dataclass, field
from typing import Optional, List, Dict, Any, Union
import uuid
from datetime import datetime

from ..value_objects.value_objects import ExperienceLevel

@dataclass
class User:
    """Domain model representing a user"""
    email: str
    first_name: str
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    profile_photo_url: Optional[str] = None
    last_login: Optional[datetime] = None
    last_logout: Optional[datetime] = None
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: Optional[datetime] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def __str__(self) -> str:
        return self.email
            
@dataclass
class Address:
    """Domain model representing a user address"""
    user_id: uuid.UUID
    street_number: str
    street_name: str
    city: str
    zip_code: str
    country: str
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def __str__(self) -> str:
        return f"{self.street_number} {self.street_name}, {self.city}, {self.zip_code}"

@dataclass
class UserWithAddresses:
    """Domain model representing a user with their addresses"""
    user: User
    addresses: List[Address]

@dataclass
class AuthCredentials:
    """Domain model representing authentication credentials"""
    access_token: str
    refresh_token: str
    
@dataclass
class LogoutEvent:
    """Domain model representing a logout event"""
    user_id: uuid.UUID
    device_info: str
    ip_address: str
    created_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)

@dataclass
class BlacklistedToken:
    """Domain model representing a blacklisted token"""
    token: str
    user_id: uuid.UUID
    expires_at: datetime
    blacklisted_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)

@dataclass
class TaskPerformerProfile:
    """Domain model representing a task performer profile"""
    user_id: uuid.UUID
    user_name: str
    user_email: str
    profile_photo_url: Optional[str] = None
    skills: Optional[List[str]] = None
    experience_level: Optional[Union[ExperienceLevel, str]] = None  # Using value object
    availability: Optional[Dict[str, Any]] = None  # JSON structure for availability schedule
    preferred_radius_km: Optional[int] = None
    bio: Optional[str] = None
    hourly_rate: Optional[float] = None
    rating: Optional[float] = None
    completed_tasks_count: int = 0
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def __post_init__(self):
        # Convert string to ExperienceLevel if needed
        if isinstance(self.experience_level, str):
            self.experience_level = ExperienceLevel.from_string(self.experience_level) or self.experience_level
    
    def __str__(self) -> str:
        return f"Performer Profile {self.id}"
