from typing import List, Optional
from uuid import UUID
from datetime import datetime

from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance

from deliveries.domain.models.entities.delivery_entities import Delivery
from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.repositories.delivery_repo.delivery_repository_interfaces import DeliveryRepository
from deliveries.infrastructure.django_models.delivery_orm_models.delivery_models import DeliveryModel
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverModel
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
    
    def list_by_driver(self, driver_id: UUID) -> List[Delivery]:
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
                delivery_address_human_readable=order.user.address,
                store_brand_address_human_readable=order.store_brand.address,
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
    
    def assign_driver(self, delivery_id: UUID, driver_id: UUID) -> Optional[Delivery]:
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
    
    def list_by_proximity(self, location: GeoPoint, max_distance_km: float = 2.0,
                         status: Optional[str] = None) -> List[Delivery]:
        """List deliveries within a specified distance from the given coordinates
        
        This method uses PostGIS spatial queries to efficiently find deliveries near a location.
        It first finds store locations within the specified radius, then retrieves the associated
        deliveries. This is useful for drivers looking for nearby pickups.
        
        Args:
            location: Current location point
            max_distance_km: Maximum distance in kilometers (default 2km)
            status: Optional status filter (e.g., 'pending')
            
        Returns:
            List of deliveries within the specified distance
        """
        # Create a Point object for the query
        point = Point(location.longitude, location.latitude, srid=4326)
        
        # Base query
        query = DeliveryModel.objects.all()
        
        # Filter by store location if available
        location_query = query.filter(
            store_location_geopoint__distance_lte=(point, D(km=max_distance_km))
        ).annotate(
            distance=Distance('store_location_geopoint', point)
        )
        
        # Add status filter if provided
        if status:
            location_query = location_query.filter(status=status)
        
        # Order by distance
        location_query = location_query.order_by('distance')
        
        # Convert to domain entities
        return [self._to_domain_entity(delivery_model) for delivery_model in location_query]
    
    def update_delivery_locations(self, delivery_id: UUID, 
                                delivery_location: Optional[GeoPoint] = None,
                                store_location: Optional[GeoPoint] = None) -> Optional[Delivery]:
        """Update the geospatial locations for a delivery
        
        This method updates the geographical coordinates for a delivery's pickup and
        dropoff locations. This is useful for geocoding addresses to coordinates.
        
        Args:
            delivery_id: ID of the delivery to update
            delivery_location: Optional delivery destination coordinates
            store_location: Optional store coordinates
            
        Returns:
            Updated delivery or None if not found
        """
        try:
            delivery_model = DeliveryModel.objects.get(id=delivery_id)
            
            # Update delivery location if provided
            if delivery_location:
                delivery_model.delivery_location_geopoint = Point(
                    delivery_location.longitude, 
                    delivery_location.latitude, 
                    srid=4326
                )
            
            # Update store location if provided
            if store_location:
                delivery_model.store_location_geopoint = Point(
                    store_location.longitude, 
                    store_location.latitude, 
                    srid=4326
                )
            
            delivery_model.save()
            return self._to_domain_entity(delivery_model)
        except DeliveryModel.DoesNotExist:
            return None
    
    def update_estimated_arrival(self, delivery_id: UUID, 
                               estimated_arrival_time: datetime) -> Optional[Delivery]:
        """Update the estimated arrival time for a delivery
        
        This method updates the ETA for a delivery based on route calculations.
        
        Args:
            delivery_id: ID of the delivery to update
            estimated_arrival_time: New estimated arrival time
            
        Returns:
            Updated delivery or None if not found
        """
        try:
            delivery_model = DeliveryModel.objects.get(id=delivery_id)
            delivery_model.estimated_arrival_time = estimated_arrival_time
            delivery_model.save()
            return self._to_domain_entity(delivery_model)
        except DeliveryModel.DoesNotExist:
            return None
    
    def _to_domain_entity(self, delivery_model: DeliveryModel) -> Delivery:
        """Convert ORM model to domain entity"""

        order = delivery_model.order
        
        # Convert geospatial fields to domain value objects
        delivery_location = None
        if delivery_model.delivery_location_geopoint:
            delivery_location = GeoPoint(
                latitude=delivery_model.delivery_location_geopoint.y,
                longitude=delivery_model.delivery_location_geopoint.x
            )
            
        store_location = None
        if delivery_model.store_location_geopoint:
            store_location = GeoPoint(
                latitude=delivery_model.store_location_geopoint.y,
                longitude=delivery_model.store_location_geopoint.x
            )

        return Delivery(
            id=delivery_model.id,
            order_id=order.id,
            fee=order.fee,
            total_items=order.total_items,
            items=order.items,
            order_total_price=order.total_price,
            delivery_address_human_readable=order.user.address,
            store_brand_id=order.store_brand.id,
            store_brand_name=order.store_brand.name,
            store_brand_image_logo=order.store_brand.image_logo,
            notes_for_driver=order.notes_for_driver,
            driver_id=delivery_model.driver.id if delivery_model.driver else None,
            schedule_for=order.schedule_for,
            status=delivery_model.status,
            estimated_total_time=delivery_model.estimated_total_time,
            store_brand_address_human_readable=delivery_model.store_brand_address_human_readable,
            created_at=delivery_model.created_at,
            delivery_location_geopoint=delivery_location,
            store_location_geopoint=store_location,
            estimated_arrival_time=delivery_model.estimated_arrival_time
        )
