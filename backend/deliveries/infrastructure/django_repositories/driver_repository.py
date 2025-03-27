from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities import Driver
from deliveries.domain.repositories.repository_interfaces import DriverRepository
from deliveries.infrastructure.django_models.orm_models import DriverModel
from the_user_app.models import CustomUser


class DjangoDriverRepository(DriverRepository):
    """Django ORM implementation of DriverRepository"""
    
    def get_by_id(self, driver_id: int) -> Optional[Driver]:
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
        driver_models = DriverModel.objects.filter(user__is_available=True)
        return [self._to_domain_entity(driver_model) for driver_model in driver_models]
    
    def create(self, user_id: UUID) -> Driver:
        """Create a new driver"""
        try:
            user = CustomUser.objects.get(id=user_id)
            driver_model = DriverModel.objects.create(user=user)
            return self._to_domain_entity(driver_model)
        except CustomUser.DoesNotExist:
            raise ValueError(f"User with ID {user_id} not found")
    
    def delete(self, driver_id: int) -> bool:
        """Delete a driver"""
        try:
            driver_model = DriverModel.objects.get(id=driver_id)
            driver_model.delete()
            return True
        except DriverModel.DoesNotExist:
            return False
    
    def _to_domain_entity(self, driver_model: DriverModel) -> Driver:
        """Convert ORM model to domain entity"""
        return Driver(
            id=driver_model.id,
            user_id=driver_model.user.id
        )
