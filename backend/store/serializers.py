from rest_framework import serializers
from .models import Store

class StoreSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Store
        fields = '__all__'
    
    def get_image_url(self, obj):
        if obj.image_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.image_url.url)
        return None
