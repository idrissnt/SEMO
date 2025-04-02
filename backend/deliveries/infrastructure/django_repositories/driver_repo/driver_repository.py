from typing import List, Optional, Tuple
from uuid import UUID

from deliveries.domain.models.entities.driver_entities import Driver
from deliveries.domain.repositories.driver_repo.driver_repository_interfaces import DriverRepository
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverModel
from django.conf import settings


class DjangoDriverRepository(DriverRepository):
    """Django ORM implementation of DriverRepository"""
    
    def get_by_id(self, driver_id: UUID) -> Optional[Driver]:
        """Get a driver by ID"""
        try:
            driver_model = DriverModel.objects.get(id=driver_id)
            return self._to_domain_entity(driver_model)
        except DriverModel.DoesNotExist:
            return None
    
    def get_by_user_id(self, user_id: UUID) -> Optional[Driver]:
        """Get a driver by user ID"""
        try:
            driver_model = DriverModel.objects.get(user_id=user_id)
            return self._to_domain_entity(driver_model)
        except DriverModel.DoesNotExist:
            return None
    
    def list_all(self) -> List[Driver]:
        """List all drivers"""
        driver_models = DriverModel.objects.all()
        return [self._to_domain_entity(driver_model) for driver_model in driver_models]
    
    def list_available(self) -> List[Driver]:
        """List all available drivers"""
        driver_models = DriverModel.objects.filter(is_available=True)
        return [self._to_domain_entity(driver_model) for driver_model in driver_models]
    
    def create(self, user_id: UUID) -> Driver:
        """Create a new driver"""
        try:
            user = settings.AUTH_USER_MODEL.objects.get(id=user_id)
            driver_model = DriverModel.objects.create(user=user)
            return self._to_domain_entity(driver_model)
        except settings.AUTH_USER_MODEL.DoesNotExist:
            raise ValueError(f"User with ID {user_id} not found")

    def update_availability(self, driver_id: UUID, 
                            is_available: bool) -> Tuple[bool, str]:
        """Update the availability of a driver"""
        try:
            driver_model = DriverModel.objects.get(id=driver_id)
            driver_model.is_available = is_available
            driver_model.save()
            return True, ""
        except DriverModel.DoesNotExist:
            return False, f"Driver with ID {driver_id} not found"

    def update_info(self, driver_id: UUID, license_number: str, 
                    has_vehicle: bool) -> Tuple[bool, str, Optional[Driver]]:
        """Update an existing driver info"""
        try:
            driver_model = DriverModel.objects.get(id=driver_id)
            
            # Update fields
            driver_model.license_number = license_number    
            driver_model.has_vehicle = has_vehicle
            
            driver_model.save()
            return True, "", self._to_domain_entity(driver_model)
        except DriverModel.DoesNotExist:
            return False, f"Driver with ID {driver_id} not found", None

    def delete(self, driver_id: UUID) -> Tuple[bool, str]:
        """Delete a driver"""
        from deliveries.infrastructure.django_models.orm_models import DeliveryModel
        active_deliveries = DeliveryModel.objects.filter(
            driver_id=driver_id
        ).exclude(status='delivered').exists()
        
        if active_deliveries:
            return False, "Cannot delete driver with active deliveries"
        
        try:
            driver_model = DriverModel.objects.get(id=driver_id)
            driver_model.delete()
            return True, ""
        except DriverModel.DoesNotExist:
            return False, f"Driver with ID {driver_id} not found"

    def _to_domain_entity(self, driver_model: DriverModel) -> Driver:
        """Convert ORM model to domain entity"""
        return Driver(
            id=driver_model.id,
            user_id=driver_model.user.id,
            mean_time_taken=driver_model.mean_time_taken,
            license_number=driver_model.license_number,
            is_available=driver_model.is_available,
            has_vehicle=driver_model.has_vehicle,
        )
