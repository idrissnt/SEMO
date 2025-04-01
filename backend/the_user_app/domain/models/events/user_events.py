"""
Domain events for the user domain.

These events are published when significant actions occur in the user domain,
allowing other parts of the system to react to them.
"""
from dataclasses import dataclass
from typing import Optional
from uuid import UUID

from core.domain_events.events import DomainEvent

# User Events
@dataclass
class UserRegisteredEvent(DomainEvent):
    """Event fired when a new user is registered"""
    user_id: UUID

