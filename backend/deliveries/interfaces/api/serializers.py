from rest_framework import serializers
from the_user_app.serializers import UserSerializer
from deliveries.infrastructure.django_models.orm_models import DriverModel, DeliveryModel, DeliveryTimelineModel, DeliveryLocationModel


class DriverSerializer(serializers.ModelSerializer):
    """Serializer for Driver model"""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = DriverModel
        fields = ['id', 'user']
        read_only_fields = ['id']


class DeliverySerializer(serializers.ModelSerializer):
    """Serializer for Delivery model"""
    driver = DriverSerializer(read_only=True)
    delivery_address = serializers.CharField(read_only=True)

    class Meta:
        model = DeliveryModel
        fields = [
            'id', 'order', 'driver', 'status',
            'delivery_address', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def validate_status(self, value):
        """Validate status transitions"""
        status_order = ['pending', 'assigned', 'out_for_delivery', 'delivered', 'cancelled']
        current_status = self.instance.status if self.instance else None
        
        # If current status is a terminal state, no transitions allowed
        if current_status in ['delivered', 'cancelled']:
            raise serializers.ValidationError(f"Cannot change status from terminal state: {current_status}")
            
        # If not a terminal state, check for valid transitions
        if current_status and value != 'cancelled':
            if status_order.index(value) < status_order.index(current_status):
                raise serializers.ValidationError("Cannot revert to previous status")
        return value


class DeliveryTimelineSerializer(serializers.ModelSerializer):
    """Serializer for DeliveryTimeline model"""
    delivery_id = serializers.UUIDField(source='delivery.id', read_only=True)
    location = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = DeliveryTimelineModel
        fields = [
            'id', 'delivery_id', 'event_type', 'timestamp',
            'notes', 'location'
        ]
        read_only_fields = ['id', 'timestamp']
    
    def get_location(self, obj):
        """Return location as a dict if latitude and longitude are present"""
        if obj.latitude is not None and obj.longitude is not None:
            return {
                'latitude': obj.latitude,
                'longitude': obj.longitude
            }
        return None


class DeliveryLocationSerializer(serializers.ModelSerializer):
    """Serializer for DeliveryLocation model"""
    delivery_id = serializers.UUIDField(source='delivery.id', read_only=True)
    driver_id = serializers.IntegerField(source='driver.id', read_only=True)
    
    class Meta:
        model = DeliveryLocationModel
        fields = [
            'id', 'delivery_id', 'driver_id', 'latitude',
            'longitude', 'timestamp'
        ]
        read_only_fields = ['id', 'timestamp']
        
    def validate(self, data):
        """Validate latitude and longitude"""
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        
        if latitude < -90 or latitude > 90:
            raise serializers.ValidationError({"latitude": "Must be between -90 and 90"})
            
        if longitude < -180 or longitude > 180:
            raise serializers.ValidationError({"longitude": "Must be between -180 and 180"})
            
        return data
