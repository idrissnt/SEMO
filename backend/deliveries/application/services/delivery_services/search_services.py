



from typing import List, Optional

from deliveries.domain.models.entities.delivery_entities import Delivery
from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository


class DeliverySearchApplicationService:
    """Application service for delivery search
    
    This service coordinates the use cases related to deliveries, including
    searching for nearby deliveries.
    """
    
    def __init__(
        self,
        delivery_repository: DeliveryRepository,
    ):
        self.delivery_repository = delivery_repository        
        
    def find_nearby_deliveries(self, 
                             latitude: float, 
                             longitude: float, 
                             radius_km: float = 2.0,
                             status: Optional[str] = None) -> List[Delivery]:
        """Find deliveries near a specific location
        
        This method is useful for drivers to find nearby deliveries they can do,
        or for customers to see deliveries happening in their area.
        
        Args:
            latitude: Current latitude
            longitude: Current longitude
            radius_km: Search radius in kilometers
            status: Optional status filter
            
        Returns:
            List of nearby deliveries
        """
        # Validate parameters
        if not -90 <= latitude <= 90 or not -180 <= longitude <= 180:
            return []
            
        # Create GeoPoint from coordinates
        location = GeoPoint(latitude=latitude, longitude=longitude)
        
        # Find nearby deliveries
        return self.delivery_repository.list_by_proximity(
            location=location,
            max_distance_km=radius_km,
            status=status
        )