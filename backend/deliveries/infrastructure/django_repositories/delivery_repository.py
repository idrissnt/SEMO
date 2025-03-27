from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities import Delivery
from deliveries.domain.repositories.repository_interfaces import DeliveryRepository
from deliveries.infrastructure.django_models.orm_models import DeliveryModel, DriverModel
from orders.models import Order


class DjangoDeliveryRepository(DeliveryRepository):
    """Django ORM implementation of DeliveryRepository"""
    
    def get_by_id(self, delivery_id: UUID) -> Optional[Delivery]:
        """Get a delivery by ID"""
        try:
            delivery_model = DeliveryModel.objects.get(id=delivery_id)
            return self._to_domain_entity(delivery_model)
        except DeliveryModel.DoesNotExist:
            return None
    
    def get_by_order_id(self, order_id: UUID) -> Optional[Delivery]:
        """Get a delivery by order ID"""
        try:
            delivery_model = DeliveryModel.objects.get(order_id=order_id)
            return self._to_domain_entity(delivery_model)
        except DeliveryModel.DoesNotExist:
            return None
    
    def list_by_driver(self, driver_id: int) -> List[Delivery]:
        """List all deliveries for a driver"""
        delivery_models = DeliveryModel.objects.filter(driver_id=driver_id)
        return [self._to_domain_entity(delivery_model) for delivery_model in delivery_models]
    
    def create(self, order_id: UUID, delivery_address: str) -> Delivery:
        """Create a new delivery"""
        try:
            order = Order.objects.get(id=order_id)
            delivery_model = DeliveryModel.objects.create(
                order=order,
                delivery_address=delivery_address
            )
            return self._to_domain_entity(delivery_model)
        except Order.DoesNotExist:
            raise ValueError(f"Order with ID {order_id} not found")
    
    def update_status(self, delivery_id: UUID, status: str) -> Optional[Delivery]:
        """Update delivery status"""
        try:
            delivery_model = DeliveryModel.objects.get(id=delivery_id)
            delivery_model.status = status
            delivery_model.save()
            return self._to_domain_entity(delivery_model)
        except DeliveryModel.DoesNotExist:
            return None
    
    def assign_driver(self, delivery_id: UUID, driver_id: int) -> Optional[Delivery]:
        """Assign a driver to a delivery"""
        try:
            delivery_model = DeliveryModel.objects.get(id=delivery_id)
            driver_model = DriverModel.objects.get(id=driver_id)
            
            delivery_model.driver = driver_model
            delivery_model.status = 'assigned'
            delivery_model.save()
            
            return self._to_domain_entity(delivery_model)
        except (DeliveryModel.DoesNotExist, DriverModel.DoesNotExist):
            return None
    
    def _to_domain_entity(self, delivery_model: DeliveryModel) -> Delivery:
        """Convert ORM model to domain entity"""
        return Delivery(
            id=delivery_model.id,
            order_id=delivery_model.order.id,
            driver_id=delivery_model.driver.id if delivery_model.driver else None,
            status=delivery_model.status,
            delivery_address=delivery_model.delivery_address,
            created_at=delivery_model.created_at
        )
