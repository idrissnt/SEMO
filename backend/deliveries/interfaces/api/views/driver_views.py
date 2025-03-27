from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from the_user_app.core.permissions import IsAdminOrDriverOwner
from the_user_app.domain.repositories.repository_interfaces import UserRepository
from the_user_app.infrastructure.factory import RepositoryFactory as UserRepositoryFactory

from deliveries.domain.repositories.repository_interfaces import DriverRepository
from deliveries.infrastructure.factory import RepositoryFactory as DeliveryRepositoryFactory
from deliveries.application.services.driver_service import DriverApplicationService
from deliveries.infrastructure.django_models.orm_models import DriverModel
from deliveries.interfaces.api.serializers import DriverSerializer


class DriverViewSet(viewsets.ModelViewSet):
    """ViewSet for driver management"""
    serializer_class = DriverSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdminOrDriverOwner]
    
    def get_queryset(self):
        """Get queryset based on user permissions"""
        if self.request.user.is_staff:
            return DriverModel.objects.all()
        return DriverModel.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        """Create a new driver record"""
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['post'])
    def register(self, request):
        """Register current user as a driver"""
        # Create repositories
        user_repository = UserRepositoryFactory.create_user_repository()
        driver_repository = DeliveryRepositoryFactory.create_driver_repository()
        
        # Create service
        driver_service = DriverApplicationService(
            user_repository=user_repository,
            driver_repository=driver_repository
        )
        
        # Register user as driver
        success, message = driver_service.register_as_driver(request.user.id)
        
        if success:
            return Response(
                {"message": "Successfully registered as driver"},
                status=status.HTTP_200_OK
            )
        else:
            return Response(
                {"error": message},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['post'])
    def unregister(self, request):
        """Unregister current user from being a driver"""
        # Create repositories
        user_repository = UserRepositoryFactory.create_user_repository()
        driver_repository = DeliveryRepositoryFactory.create_driver_repository()
        
        # Create service
        driver_service = DriverApplicationService(
            user_repository=user_repository,
            driver_repository=driver_repository
        )
        
        # Unregister user as driver
        success, message = driver_service.unregister_as_driver(request.user.id)
        
        if success:
            return Response(
                {"message": "Successfully unregistered as driver"},
                status=status.HTTP_200_OK
            )
        else:
            return Response(
                {"error": message},
                status=status.HTTP_400_BAD_REQUEST
            )
