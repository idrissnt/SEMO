from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    store_name = serializers.CharField(source='store.name', read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = '__all__'

    def get_image_url(self, obj):
        if obj.image_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.image_url.url)
        return None
