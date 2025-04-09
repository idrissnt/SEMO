"""
Task application and negotiation entities.
"""
from dataclasses import dataclass, field
from typing import Optional, List
import uuid
from datetime import datetime

from ..value_objects.application_status import ApplicationStatus
from the_user_app.domain.models.entities import TaskPerformerProfile


@dataclass
class NegotiationOffer:
    """Domain model representing a single offer in a negotiation"""
    amount: float
    message: str
    created_by: str  # 'requester' or 'performer'
    created_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)


@dataclass
class TaskApplication:
    """Domain model representing an application to perform a task"""
    task_id: uuid.UUID
    performer_id: uuid.UUID  # ID of the TaskPerformerProfile
    performer: Optional[TaskPerformerProfile] = None  # Reference to the TaskPerformerProfile entity
    initial_message: Optional[str] = None
    initial_offer: Optional[float] = None
    status: ApplicationStatus = ApplicationStatus.PENDING
    negotiation_history: List[NegotiationOffer] = field(default_factory=list)
    chat_enabled: bool = False  # Only enabled after price agreement
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def add_counter_offer(self, amount: float, message: str, created_by: str) -> None:
        """Add a counter offer to the negotiation history"""
        if self.status in [ApplicationStatus.PENDING, ApplicationStatus.NEGOTIATING]:
            offer = NegotiationOffer(
                amount=amount,
                message=message,
                created_by=created_by
            )
            self.negotiation_history.append(offer)
            self.status = ApplicationStatus.NEGOTIATING
            self.updated_at = datetime.now()
    
    def accept(self) -> None:
        """Accept the application"""
        if self.status in [ApplicationStatus.PENDING, ApplicationStatus.NEGOTIATING]:
            self.status = ApplicationStatus.ACCEPTED
            self.updated_at = datetime.now()
    
    def reject(self) -> None:
        """Reject the application"""
        if self.status in [ApplicationStatus.PENDING, ApplicationStatus.NEGOTIATING]:
            self.status = ApplicationStatus.REJECTED
            self.updated_at = datetime.now()
    
    def withdraw(self) -> None:
        """Withdraw the application (by performer)"""
        if self.status in [ApplicationStatus.PENDING, ApplicationStatus.NEGOTIATING]:
            self.status = ApplicationStatus.WITHDRAWN
            self.updated_at = datetime.now()
    
    def get_final_offer(self) -> Optional[float]:
        """Get the final agreed offer amount"""
        if self.status == ApplicationStatus.ACCEPTED:
            if self.negotiation_history:
                return self.negotiation_history[-1].amount
            return self.initial_offer
        return None
