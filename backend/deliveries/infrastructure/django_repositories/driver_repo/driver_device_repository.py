"""
Django ORM implementation of the driver device repository.

This module provides a Django ORM implementation of the DriverDeviceRepository interface
for managing driver devices.
"""
import logging
from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities.driver_entities import DriverDevice
from deliveries.domain.repositories.driver_repo.driver_device_repository_interfaces import DriverDeviceRepository
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverDeviceModel, DriverModel

logger = logging.getLogger(__name__)

class DjangoDriverDeviceRepository(DriverDeviceRepository):
    """Django ORM implementation of DriverDeviceRepository"""
    
    def register_device(self, driver_id: UUID, device_token: str, device_type: str) -> DriverDevice:
        """Register a driver's device for push notifications"""
        try:
            # Get the driver model
            driver_model = DriverModel.objects.get(id=driver_id)
            
            # Create or update the device
            device_model, created = DriverDeviceModel.objects.update_or_create(
                driver=driver_model,
                device_token=device_token,
                defaults={
                    'device_type': device_type,
                    'is_active': True
                }
            )
            
            # Convert to domain entity
            return self._to_domain_entity(device_model, driver_id)
            
        except DriverModel.DoesNotExist:
            logger.error(f"Driver with ID {driver_id} not found")
            raise ValueError(f"Driver with ID {driver_id} not found")
        except Exception as e:
            logger.error(f"Error registering device: {str(e)}")
            raise
    
    def unregister_device(self, driver_id: UUID, device_token: str) -> bool:
        """Unregister a driver's device from push notifications"""
        try:
            # Get the driver model
            driver_model = DriverModel.objects.get(id=driver_id)
            
            # Mark the device as inactive
            updated = DriverDeviceModel.objects.filter(
                driver=driver_model,
                device_token=device_token
            ).update(is_active=False)
            
            return updated > 0
            
        except DriverModel.DoesNotExist:
            logger.error(f"Driver with ID {driver_id} not found")
            return False
        except Exception as e:
            logger.error(f"Error unregistering device: {str(e)}")
            return False
    
    def get_active_devices(self, driver_id: UUID) -> List[DriverDevice]:
        """Get all active devices for a driver"""
        try:
            # Get the driver model
            driver_model = DriverModel.objects.get(id=driver_id)
            
            # Get all active devices
            device_models = DriverDeviceModel.objects.filter(
                driver=driver_model,
                is_active=True
            )
            
            # Convert to domain entities using the _to_domain_entity method
            return [self._to_domain_entity(device, driver_id) for device in device_models]
            
        except DriverModel.DoesNotExist:
            logger.error(f"Driver with ID {driver_id} not found")
            return []
        except Exception as e:
            logger.error(f"Error getting active devices: {str(e)}")
            return []
            
    def _to_domain_entity(self, device_model: DriverDeviceModel, driver_id: UUID) -> DriverDevice:
        """Convert ORM model to domain entity"""
        return DriverDevice(
            id=device_model.id,
            driver_id=driver_id,
            device_token=device_model.device_token,
            device_type=device_model.device_type,
            is_active=device_model.is_active,
            created_at=device_model.created_at,
            updated_at=device_model.updated_at
        )
    

