"""
Task category entity module.

This module defines the TaskCategory entity, which represents different types of tasks
that can be created in the system, with UI-specific attributes for better frontend presentation.
"""
from dataclasses import dataclass, field
from datetime import datetime
import uuid
from enum import Enum

class TaskCategoryType(Enum):
    """Enum representing the type of a task category"""
    HOME_CLEANING = "home_cleaning"
    IRONING = "ironing"
    DISHWASHING = "dishwashing"
    FURNITURE_ASSEMBLY = "furniture_assembly"
    HEAVY_LIFTING = "heavy_lifting"
    LAWN_MOWING = "lawn_mowing"
    PAINTING = "painting"
    COOKING = "cooking"
    DOG_WALKING = "dog_walking"
    PET_SITTING = "pet_sitting"
    BABYSITTING = "babysitting"
    SCHOOL_PICKUP = "school_pickup"
    MOVING_HELP = "moving_help"
    INTERIOR_ORGANIZATION = "interior_organization"
    QUEUE_WAITING = "queue_waiting"
    WEDDING_HELP = "wedding_help"
    EVENT_ORGANIZATION = "event_organization"
    PHOTOGRAPHY_FINDING = "photography_finding"
    VIDEOGRAPHY_FINDING = "videography_finding"
    APPLIANCE_REPAIR = "appliance_repair"
    

@dataclass
class TaskCategory:
    """Task category entity
    
    Categories represent the different types of tasks that can be created,
    such as "Cleaning", "Moving", "Delivery", etc.
    
    This entity includes UI-specific attributes like images and colors
    to enhance the frontend presentation.
    """
    type: TaskCategoryType
    name: str
    display_name: str
    description: str
    image_url: str  # For UI representation
    icon_name: str  # For UI representation (e.g., Material icon name)
    color_hex: str  # For UI theming
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
