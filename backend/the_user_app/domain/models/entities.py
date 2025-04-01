from dataclasses import dataclass, field
from typing import Optional, List
import uuid
from datetime import datetime

@dataclass
class User:
    """Domain model representing a user"""
    email: str
    first_name: str
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
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
