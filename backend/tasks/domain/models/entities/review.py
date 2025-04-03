"""
Review entity.
"""
from dataclasses import dataclass, field
from typing import Optional
import uuid
from datetime import datetime


@dataclass
class Review:
    """Domain model representing a review for a completed task"""
    task_id: uuid.UUID
    reviewer_id: uuid.UUID
    reviewee_id: uuid.UUID
    rating: int  # 1-5 stars
    comment: Optional[str] = None
    created_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
