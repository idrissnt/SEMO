from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response

class DeliveryMixin:
    """Mixin for delivery-related store operations"""

    @action(detail=False, methods=['get'])
    def delivery_estimate(self, request):
        """Calculate estimated delivery time and cost"""
        latitude = request.query_params.get('latitude')
        longitude = request.query_params.get('longitude')
        
        if not latitude or not longitude:
            return Response({
                'success': False,
                'message': 'Latitude and Longitude are required',
                'errors': 'Missing location coordinates'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            return Response({
                'success': False,
                'message': 'Invalid location coordinates',
                'errors': 'Latitude and Longitude must be numeric values'
            }, status=status.HTTP_400_BAD_REQUEST)

        # Get stores within delivery radius
        stores = self.get_queryset().filter(
            delivery_radius__isnull=False,
            is_open=True
        )

        delivery_options = []
        for store in stores:
            # Calculate distance (replace with actual geospatial calculation)
            distance = store.calculate_distance(latitude, longitude)
            
            if distance <= store.delivery_radius:
                delivery_option = {
                    'store_id': str(store.id),
                    'store_name': store.name,
                    'distance': distance,
                    'delivery_fee': float(store.delivery_fee),
                    'minimum_order': float(store.minimum_order),
                    'estimated_delivery_time': store.get_delivery_time_estimate(distance)
                }
                delivery_options.append(delivery_option)

        # Sort delivery options by distance
        delivery_options.sort(key=lambda x: x['distance'])

        return Response({
            'success': True,
            'latitude': latitude,
            'longitude': longitude,
            'delivery_options': delivery_options
        })
