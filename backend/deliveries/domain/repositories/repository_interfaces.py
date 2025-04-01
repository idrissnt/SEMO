from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Tuple
from uuid import UUID

from deliveries.domain.models.entities import Driver, Delivery, DeliveryTimelineEvent, DeliveryLocation


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

class DeliveryTimelineRepository(ABC):
    """Interface for delivery timeline repository"""
    
    @abstractmethod
    def get_by_id(self, event_id: UUID) -> Optional[DeliveryTimelineEvent]:
        """Get a timeline event by ID"""
        pass
    
    @abstractmethod
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryTimelineEvent]:
        """List all timeline events for a delivery"""
        pass
    
    @abstractmethod
    def create(
        self, 
        delivery_id: UUID, 
        event_type: str, 
        notes: Optional[str] = None,
        location: Optional[Dict[str, float]] = None
    ) -> DeliveryTimelineEvent:
        """Create a new timeline event"""
        pass


class DeliveryLocationRepository(ABC):
    """Interface for delivery location repository"""
    
    @abstractmethod
    def get_by_id(self, location_id: UUID) -> Optional[DeliveryLocation]:
        """Get a location by ID"""
        pass
    
    @abstractmethod
    def get_latest_by_delivery(self, delivery_id: UUID) -> Optional[DeliveryLocation]:
        """Get the latest location for a delivery"""
        pass
    
    @abstractmethod
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryLocation]:
        """List all locations for a delivery"""
        pass
    
    @abstractmethod
    def create(
        self,
        delivery_id: UUID,
        driver_id: int,
        latitude: float,
        longitude: float
    ) -> DeliveryLocation:
        """Create a new location record"""
        pass


class DeliveryRepository(ABC):
    """Interface for delivery repository"""
    
    @abstractmethod
    def get_by_id(self, delivery_id: UUID) -> Optional[Delivery]:
        """Get a delivery by ID"""
        pass
    
    @abstractmethod
    def get_by_order_id(self, order_id: UUID) -> Optional[Delivery]:
        """Get a delivery by order ID"""
        pass
    
    @abstractmethod
    def list_by_driver(self, driver_id: int) -> List[Delivery]:
        """List all deliveries for a driver"""
        pass
    
    @abstractmethod
    def list_by_status(self, status: str) -> List[Delivery]:
        """List all deliveries with a specific status"""
        pass
    
    @abstractmethod
    def create(self, order_id: UUID, delivery_address: str) -> Delivery:
        """Create a new delivery"""
        pass
    
    @abstractmethod
    def update_status(self, delivery_id: UUID, status: str) -> Optional[Delivery]:
        """Update delivery status"""
        pass
    
    @abstractmethod
    def assign_driver(self, delivery_id: UUID, driver_id: int) -> Optional[Delivery]:
        """Assign a driver to a delivery"""
        pass
