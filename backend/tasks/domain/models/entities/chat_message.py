"""
Chat message entity.
"""
from dataclasses import dataclass, field
import uuid
from datetime import datetime


@dataclass
class ChatMessage:
    """Domain model representing a chat message between requester and performer"""
    task_application_id: uuid.UUID
    sender_id: uuid.UUID
    content: str
    read: bool = False
    created_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
