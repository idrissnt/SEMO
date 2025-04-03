"""
Task category and category template entities.
"""
from dataclasses import dataclass, field
from typing import List, Dict
import uuid
from enum import Enum


class TaskCategory(Enum):
    """Enum representing the category of a task"""
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
class TaskCategoryTemplate:
    """Domain model representing a template for a task category with predefined attributes"""
    category: TaskCategory
    name: str
    image_url: str
    description: str
    title_template: str  # Template for task title
    description_template: str  # Template for task description
    attribute_templates: List[Dict[str, str]]  # List of {name, question} dictionaries
    id: uuid.UUID = field(default_factory=uuid.uuid4)
