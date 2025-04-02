from abc import ABC, abstractmethod
from typing import List, Optional, Tuple
from uuid import UUID

from deliveries.domain.models.entities.driver_entities import Driver


class DriverRepository(ABC):
    """Interface for driver repository"""   
    
    @abstractmethod
    def get_by_id(self, driver_id: UUID) -> Optional[Driver]:
        """Get a driver by ID"""
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: UUID) -> Optional[Driver]:
        """Get a driver by user ID"""
        pass
    
    @abstractmethod
    def list_all(self) -> List[Driver]:
        """List all drivers"""
        pass
    
    @abstractmethod
    def list_available(self) -> List[Driver]:
        """List all available drivers"""
        pass
    
    @abstractmethod
    def create(self, user_id: UUID) -> Driver:
        """Create a new driver"""
        pass
    
    @abstractmethod
    def update_info(self, driver_id: UUID, 
                    license_number: str, 
                    has_vehicle: bool
                    ) -> Tuple[bool, str, Optional[Driver]]:
        """Update an existing driver info"""
        pass

    @abstractmethod
    def update_availability(self, driver_id: UUID, 
                            is_available: bool
                            ) -> Tuple[bool, str]:
        """Update the availability of a driver"""
        pass
    
    @abstractmethod
    def delete(self, driver_id: UUID) -> Tuple[bool, str]:
        """Delete a driver"""
        pass
