from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from payments.infrastructure.django_models.orm_models import (
    PaymentModel, 
    PaymentMethodModel, 
    PaymentTransactionModel
)
from payments.interfaces.api.serializers import (
    PaymentSerializer, 
    PaymentMethodSerializer, 
    PaymentTransactionSerializer,
    PaymentIntentSerializer,
    PaymentMethodCreateSerializer
)
from payments.application.services.payment_service import PaymentApplicationService
from payments.infrastructure.factory import RepositoryFactory
from core.domain_events.event_bus import EventBus


class PaymentViewSet(viewsets.ModelViewSet):
    """ViewSet for Payment model"""
    serializer_class = PaymentSerializer
    permission_classes = [IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Initialize the application service
        payment_repository = RepositoryFactory.create_payment_repository()
        payment_method_repository = RepositoryFactory.create_payment_method_repository()
        payment_transaction_repository = RepositoryFactory.create_payment_transaction_repository()
        event_bus = EventBus()
        
        self.service = PaymentApplicationService(
            payment_repository=payment_repository,
            payment_method_repository=payment_method_repository,
            payment_transaction_repository=payment_transaction_repository,
            event_bus=event_bus
        )
    
    def get_queryset(self):
        """Filter payments to only show those belonging to the current user"""
        return PaymentModel.objects.filter(
            order__user=self.request.user
        ).select_related('order')
    
    def create(self, request, *args, **kwargs):
        """Create a new payment"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        order_id = serializer.validated_data['order_id']
        payment_method = serializer.validated_data['payment_method']
        amount = serializer.validated_data['amount']
        
        success, message, payment = self.service.create_payment(
            order_id=order_id,
            payment_method=payment_method,
            amount=amount
        )
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(
            self.get_serializer(payment).data, 
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=True, methods=['post'])
    def process(self, request, pk=None):
        """Process a payment"""
        serializer = PaymentIntentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        payment_method_id = serializer.validated_data['payment_method_id']
        
        success, message, result = self.service.process_payment(
            payment_id=pk,
            payment_method_id=payment_method_id
        )
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(result)
    
    @action(detail=False, methods=['post'])
    def confirm(self, request):
        """Confirm a payment after 3D Secure authentication"""
        payment_intent_id = request.data.get('payment_intent_id')
        if not payment_intent_id:
            return Response(
                {'error': 'payment_intent_id is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        success, message, payment = self.service.confirm_payment(payment_intent_id)
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(self.get_serializer(payment).data)
    
    @action(detail=True, methods=['get'])
    def transactions(self, request, pk=None):
        """Get all transactions for a payment"""
        payment = self.get_object()
        transactions = self.service.get_payment_transactions(payment.id)
        
        serializer = PaymentTransactionSerializer(
            PaymentTransactionModel.objects.filter(payment=payment),
            many=True
        )
        return Response(serializer.data)


class PaymentMethodViewSet(viewsets.ModelViewSet):
    """ViewSet for PaymentMethod model"""
    serializer_class = PaymentMethodSerializer
    permission_classes = [IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Initialize the application service
        payment_repository = RepositoryFactory.create_payment_repository()
        payment_method_repository = RepositoryFactory.create_payment_method_repository()
        payment_transaction_repository = RepositoryFactory.create_payment_transaction_repository()
        event_bus = EventBus()
        
        self.service = PaymentApplicationService(
            payment_repository=payment_repository,
            payment_method_repository=payment_method_repository,
            payment_transaction_repository=payment_transaction_repository,
            event_bus=event_bus
        )
    
    def get_queryset(self):
        """Filter payment methods to only show those belonging to the current user"""
        return PaymentMethodModel.objects.filter(user=self.request.user)
    
    def create(self, request, *args, **kwargs):
        """Add a new payment method"""
        serializer = PaymentMethodCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        success, message, payment_method = self.service.add_payment_method(
            user_id=request.user.id,
            payment_method_id=serializer.validated_data['payment_method_id'],
            payment_method_type=serializer.validated_data['payment_method_type'],
            set_as_default=serializer.validated_data.get('set_as_default', False),
            card_details=serializer.get_card_details()
        )
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(
            PaymentMethodSerializer(payment_method).data, 
            status=status.HTTP_201_CREATED
        )
    
    def destroy(self, request, *args, **kwargs):
        """Remove a payment method"""
        payment_method = self.get_object()
        
        success, message = self.service.remove_payment_method(
            user_id=request.user.id,
            payment_method_id=payment_method.id
        )
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    @action(detail=True, methods=['post'])
    def set_default(self, request, pk=None):
        """Set a payment method as default"""
        payment_method = self.get_object()
        
        success, message = self.service.set_default_payment_method(
            user_id=request.user.id,
            payment_method_id=payment_method.id
        )
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response({'message': message})
    
    @action(detail=False, methods=['get'])
    def default(self, request):
        """Get the default payment method for the current user"""
        payment_method = self.service.get_default_payment_method(request.user.id)
        
        if not payment_method:
            return Response(
                {'error': 'No default payment method found'}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = self.get_serializer(
            PaymentMethodModel.objects.get(id=payment_method.id)
        )
        return Response(serializer.data)
