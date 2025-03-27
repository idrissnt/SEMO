from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from deliveries.infrastructure.django_models.orm_models import DeliveryModel, DeliveryTimelineModel, DeliveryLocationModel
from deliveries.interfaces.api.serializers import DeliverySerializer, DeliveryTimelineSerializer, DeliveryLocationSerializer
from deliveries.application.services.delivery_service import DeliveryApplicationService
from deliveries.infrastructure.factory import RepositoryFactory
from the_user_app.infrastructure.factory import RepositoryFactory as UserRepositoryFactory


class DeliveryViewSet(viewsets.ModelViewSet):
    """ViewSet for Delivery model"""
    queryset = DeliveryModel.objects.all()
    serializer_class = DeliverySerializer
    permission_classes = [IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Initialize the application service
        delivery_repository = RepositoryFactory.create_delivery_repository()
        driver_repository = RepositoryFactory.create_driver_repository()
        user_repository = UserRepositoryFactory.create_user_repository()
        self.service = DeliveryApplicationService(
            delivery_repository=delivery_repository,
            driver_repository=driver_repository,
            user_repository=user_repository
        )
    
    @action(detail=True, methods=['post'])
    def assign_driver(self, request, pk=None):
        """Assign a driver to a delivery"""
        driver_id = request.data.get('driver_id')
        if not driver_id:
            return Response(
                {"error": "driver_id is required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        success, message, delivery = self.service.assign_driver(pk, int(driver_id))
        if not success:
            return Response(
                {"error": message}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = self.get_serializer(delivery)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def update_status(self, request, pk=None):
        """Update the status of a delivery"""
        new_status = request.data.get('status')
        location = request.data.get('location')
        notes = request.data.get('notes')
        
        if not new_status:
            return Response(
                {"error": "status is required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        success, message, delivery = self.service.update_delivery_status(
            pk, new_status, location=location, notes=notes
        )
        
        if not success:
            return Response(
                {"error": message}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = self.get_serializer(delivery)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def update_location(self, request, pk=None):
        """Update the location of a delivery"""
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        
        if latitude is None or longitude is None:
            return Response(
                {"error": "latitude and longitude are required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            latitude = float(latitude)
            longitude = float(longitude)
        except (ValueError, TypeError):
            return Response(
                {"error": "latitude and longitude must be valid numbers"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        success, message, location_data = self.service.update_delivery_location(
            pk, float(latitude), float(longitude)
        )
        
        if not success:
            return Response(
                {"error": message}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        return Response(location_data)
    
    @action(detail=True, methods=['get'])
    def timeline(self, request, pk=None):
        """Get the timeline for a delivery"""
        # Ensure delivery exists
        try:
            delivery = self.get_object()
        except DeliveryModel.DoesNotExist:
            return Response(
                {"error": "Delivery not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        timeline_events = DeliveryTimelineModel.objects.filter(delivery=delivery).order_by('-timestamp')
        serializer = DeliveryTimelineSerializer(timeline_events, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def location_history(self, request, pk=None):
        """Get the location history for a delivery"""
        # Ensure delivery exists
        try:
            delivery = self.get_object()
        except DeliveryModel.DoesNotExist:
            return Response(
                {"error": "Delivery not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        locations = DeliveryLocationModel.objects.filter(delivery=delivery).order_by('-timestamp')
        serializer = DeliveryLocationSerializer(locations, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def current_location(self, request, pk=None):
        """Get the current location of a delivery"""
        # Ensure delivery exists
        try:
            delivery = self.get_object()
        except DeliveryModel.DoesNotExist:
            return Response(
                {"error": "Delivery not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        location = DeliveryLocationModel.objects.filter(delivery=delivery).order_by('-timestamp').first()
        if not location:
            return Response(
                {"error": "No location data available"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = DeliveryLocationSerializer(location)
        return Response(serializer.data)


class DeliveryTimelineViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for DeliveryTimeline model (read-only)"""
    queryset = DeliveryTimelineModel.objects.all()
    serializer_class = DeliveryTimelineSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Filter queryset based on query parameters"""
        queryset = super().get_queryset()
        
        # Filter by delivery_id if provided
        delivery_id = self.request.query_params.get('delivery_id')
        if delivery_id:
            queryset = queryset.filter(delivery_id=delivery_id)
        
        # Filter by event_type if provided
        event_type = self.request.query_params.get('event_type')
        if event_type:
            queryset = queryset.filter(event_type=event_type)
        
        return queryset.order_by('-timestamp')


class DeliveryLocationViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for DeliveryLocation model (read-only)"""
    queryset = DeliveryLocationModel.objects.all()
    serializer_class = DeliveryLocationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Filter queryset based on query parameters"""
        queryset = super().get_queryset()
        
        # Filter by delivery_id if provided
        delivery_id = self.request.query_params.get('delivery_id')
        if delivery_id:
            queryset = queryset.filter(delivery_id=delivery_id)
        
        # Filter by driver_id if provided
        driver_id = self.request.query_params.get('driver_id')
        if driver_id:
            queryset = queryset.filter(driver_id=driver_id)
        
        # Get only the latest location if specified
        latest_only = self.request.query_params.get('latest_only') == 'true'
        if latest_only and delivery_id:
            # Get the latest location for each delivery
            latest_ids = []
            for delivery_id in queryset.values_list('delivery_id', flat=True).distinct():
                latest = queryset.filter(delivery_id=delivery_id).order_by('-timestamp').first()
                if latest:
                    latest_ids.append(latest.id)
            queryset = queryset.filter(id__in=latest_ids)
        
        return queryset.order_by('-timestamp')
