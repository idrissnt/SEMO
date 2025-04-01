from typing import List, Optional
from uuid import UUID
from datetime import datetime
from deliveries.domain.models.entities import Delivery
from deliveries.domain.repositories.repository_interfaces import DeliveryRepository
from deliveries.infrastructure.django_models.orm_models import DeliveryModel, DriverModel
from orders.models import Order
from deliveries.domain.models.constants import DeliveryStatus

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

    def list_by_status(self, status: str) -> List[Delivery]:
        """List all deliveries with a specific status"""
        delivery_models = DeliveryModel.objects.filter(status=status)
        return [self._to_domain_entity(delivery_model) for delivery_model in delivery_models]
    
    def create(self, order_id: UUID) -> Delivery:
        """Create a new delivery"""
        try:
            order = Order.objects.get(id=order_id)
            delivery_model = DeliveryModel.objects.create(
                order=order,
                estimated_total_time=order.total_time,
                delivery_address=order.user.address,
                store_brand_address=order.store_brand.address,
                notes_for_driver=order.notes_for_driver,
                schedule_for=order.schedule_for,
            )
            return self._to_domain_entity(delivery_model)
        except Order.DoesNotExist:
            raise ValueError(f"Order with ID {order_id} not found")
    
    def update_status(self, delivery_id: UUID, status: DeliveryStatus) -> Optional[Delivery]:
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
            delivery_model.status = DeliveryStatus.ASSIGNED
            delivery_model.save()
            
            return self._to_domain_entity(delivery_model)
        except (DeliveryModel.DoesNotExist, DriverModel.DoesNotExist):
            return None
    
    def _to_domain_entity(self, delivery_model: DeliveryModel) -> Delivery:
        """Convert ORM model to domain entity"""

        order = delivery_model.order

        return Delivery(
            id=delivery_model.id,
            order_id=order.id,
            fee=order.fee,
            total_items=order.total_items,
            items=order.items,
            order_total_price=order.total_price,
            delivery_address=order.user.address,
            store_brand_id=order.store_brand.id,
            store_brand_name=order.store_brand.name,
            store_brand_image_logo=order.store_brand.image_logo,
            store_brand_address=order.store_brand.address,
            notes_for_driver=order.notes_for_driver,
            driver_id=delivery_model.driver.id if delivery_model.driver else None,
            schedule_for=order.schedule_for,
            status=delivery_model.status,
            estimated_total_time=delivery_model.estimated_total_time,
            store_brand_address=delivery_model.store_brand_address,
            created_at=delivery_model.created_at
        )
