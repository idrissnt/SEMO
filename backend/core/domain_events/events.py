from dataclasses import dataclass, asdict
from typing import Optional, Dict, Any
from uuid import UUID
from datetime import datetime
import uuid

# The Foundation
# The DomainEvent class is the base for all events in the system:

# Key features:
# - Each event has a unique ID and timestamp
# - The create() factory method simplifies creating new events
# - Serialization methods (to_dict() and from_dict()) handle conversion for storage/transmission
@dataclass
class DomainEvent:
    """Base class for all domain events"""
    event_id: UUID
    timestamp: datetime
    
    @classmethod
    def create(cls, **kwargs):
        """Factory method to create a new event"""
        return cls(
            event_id=uuid.uuid4(),
            timestamp=datetime.now(),
            **kwargs
        )
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert event to dictionary for serialization"""
        result = asdict(self)
        # Convert UUID objects to strings
        for key, value in result.items():
            if isinstance(value, UUID):
                result[key] = str(value)
            elif isinstance(value, datetime):
                result[key] = value.isoformat()
        return result
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'DomainEvent':
        """Create event from dictionary"""
        # Convert string UUIDs back to UUID objects
        for key, value in data.items():
            if key.endswith('_id') and isinstance(value, str):
                try:
                    data[key] = uuid.UUID(value)
                except ValueError:
                    pass  # Not a valid UUID, leave as string
            elif key == 'timestamp' and isinstance(value, str):
                data[key] = datetime.fromisoformat(value)
        return cls(**data)
