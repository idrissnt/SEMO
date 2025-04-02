"""
Django ORM implementation of the driver location repository.

This module provides a Django ORM implementation of the DriverLocationRepository interface
for managing driver locations and geospatial queries.
"""
import logging
from typing import List, Optional
from uuid import UUID

from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
from django.db.models import Q

from deliveries.domain.models.entities.driver_entities import DriverLocation
from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.repositories.driver_repo.driver_location_repository_interfaces import DriverLocationRepository
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverLocationModel, DriverModel

logger = logging.getLogger(__name__)

class DjangoDriverLocationRepository(DriverLocationRepository):
    """Django ORM implementation of DriverLocationRepository"""
    
    def update_driver_location(self, driver_id: UUID, location: GeoPoint) -> bool:
        """Update a driver's current location"""
        try:
            # Get the driver model - use select_for_update to prevent race conditions
            driver_model = DriverModel.objects.select_for_update().get(id=driver_id)
            
            # Create a Point object from the GeoPoint
            point = Point(location.longitude, location.latitude, srid=4326)
            
            # Use transaction.atomic to ensure atomicity
            from django.db import transaction
            with transaction.atomic():
                # Create a new location entry
                location_model = DriverLocationModel.objects.create(
                    driver=driver_model,
                    location=point,
                    latitude=location.latitude,
                    longitude=location.longitude,
                    is_active=True
                )
                
                # Mark all other locations for this driver as inactive
                # Use bulk update for better performance
                DriverLocationModel.objects.filter(
                    driver=driver_model
                ).exclude(
                    id=location_model.id
                ).update(is_active=False)
            
            return True
            
        except DriverModel.DoesNotExist:
            logger.error(f"Driver with ID {driver_id} not found")
            return False
        except Exception as e:
            logger.error(f"Error updating driver location: {str(e)}")
            return False
    
    def get_driver_location(self, driver_id: UUID) -> Optional[DriverLocation]:
        """Get a driver's current location"""
        try:
            # Use a more efficient query with select_related to reduce database hits
            # This fetches the driver and location in a single query
            location_model = DriverLocationModel.objects.select_related('driver').filter(
                driver__id=driver_id,
                is_active=True
            ).order_by('-timestamp').first()
            
            if location_model:
                return self._to_domain_entity(location_model)
            
            return None
            
        except DriverModel.DoesNotExist:
            logger.error(f"Driver with ID {driver_id} not found")
            return None
        except Exception as e:
            logger.error(f"Error getting driver location: {str(e)}")
            return None
    
    def find_nearby_drivers(self, location: GeoPoint, radius_km: float = 5.0, 
                          available_only: bool = True, exclude_user_id: Optional[UUID] = None,
                          limit: int = 20) -> List[DriverLocation]:
        """Find drivers near a specific location"""
        try:
            # Create a Point object from the GeoPoint
            point = Point(location.longitude, location.latitude, srid=4326)
            
            # Build an optimized query
            # Use select_related to reduce database queries
            query = DriverLocationModel.objects.select_related('driver', 'driver__user')
            
            # Use a single filter with Q objects for better performance
            filters = Q(is_active=True)
            
            # Only include available drivers if requested
            if available_only:
                filters &= Q(driver__is_available=True)
            
            # Exclude the user who placed the order if specified
            if exclude_user_id:
                filters &= ~Q(driver__user__id=exclude_user_id)
                
            # Apply all filters
            query = query.filter(filters)
            
            # Use a spatial index with ST_DWithin for better performance than distance_lte
            # This is more efficient for large datasets
            query = query.filter(location__dwithin=(point, D(km=radius_km)))
            
            # Add distance annotation
            query = query.annotate(distance=Distance('location', point))
            
            # Order by distance and limit results
            query = query.order_by('distance')[:limit]
            
            # Convert to domain entities using the _to_domain_entity method
            return [self._to_domain_entity(location_model) for location_model in query]
            
        except Exception as e:
            logger.error(f"Error finding nearby drivers: {str(e)}")
            return []
            
    def _to_domain_entity(self, location_model: DriverLocationModel) -> DriverLocation:
        """Convert ORM model to domain entity"""
        return DriverLocation(
            id=location_model.id,
            driver_id=location_model.driver.id,
            location=GeoPoint(
                latitude=location_model.latitude,
                longitude=location_model.longitude
            ),
            timestamp=location_model.timestamp,
            is_active=location_model.is_active,
            created_at=location_model.created_at,
            updated_at=location_model.updated_at
        )
