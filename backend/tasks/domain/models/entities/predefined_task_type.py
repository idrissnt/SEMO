"""
Task category and predefined task type entities.

This module defines two key domain models:
1. TaskCategory - An enum of possible task categories
2. PredefinedTaskType - A model for predefined task types with default values and attributes

Predefined task types provide a template for common tasks, making it easier for users
to create well-structured tasks without starting from scratch.
"""
from dataclasses import dataclass, field
from typing import List, Dict, Tuple
import uuid
from enum import Enum
from datetime import datetime

@dataclass
class PredefinedTaskType:
    """Domain model representing a predefined type of task with default values and attributes.
    
    This model serves as a template for common tasks (like "House Cleaning", "Furniture Assembly", etc.),
    providing default values, suggested formats, and predefined questions relevant to that type of task.
    
    When a user creates a task based on a predefined type:
    1. The default values (title_template, description_template, image_url, estimated_budget) are shown to the user
    2. The user can modify any of these values as needed
    3. The attribute_templates are used to generate the task attributes (questions)
    4. Once the task is created, it doesn't maintain a reference to the predefined type
    
    This approach allows for guided task creation while maintaining flexibility for users.
    """
    
    title_template: str
    description_template: str
    image_url: str
    category_id: uuid.UUID  # Reference to TaskCategory by ID
    location_address: str
    estimated_budget_range: Tuple[float, float]
    estimated_duration_range: Tuple[int, int]
    scheduled_date: datetime
    attribute_templates: List[Dict[str, str]]  # List of {name, question} dictionaries
    id: uuid.UUID = field(default_factory=uuid.uuid4)
