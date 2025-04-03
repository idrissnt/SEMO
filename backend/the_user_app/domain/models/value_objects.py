from enum import Enum
from typing import List, Optional, Dict, Any


class ExperienceLevel(str, Enum):
    """Experience level value object for task performer profiles"""
    BEGINNER = 'beginner'
    INTERMEDIATE = 'intermediate'
    EXPERT = 'expert'   
    
    @classmethod
    def choices(cls) -> List[tuple]:
        """Return choices for Django model field"""
        return [(level.value, level.name.capitalize()) for level in cls]
    
    @classmethod
    def values(cls) -> List[str]:
        """Return all possible values"""
        return [level.value for level in cls]
    
    @classmethod
    def from_string(cls, value: str) -> Optional['ExperienceLevel']:
        """Create an ExperienceLevel from a string value
        
        Args:
            value: String value to convert
            
        Returns:
            ExperienceLevel instance or None if invalid
        """
        try:
            return cls(value.lower())
        except ValueError:
            return None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary representation
        
        Returns:
            Dictionary with value and display_name
        """
        return {
            'value': self.value,
            'display_name': self.name.capitalize()
        }
