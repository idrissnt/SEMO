"""
URL configuration for backend project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)

urlpatterns = [     
    path('admin/', admin.site.urls),
    
    # API URLs
    path('api/v1/', include([
        path('core/', include('core.urls', namespace='core')),
        path('users/', include('the_user_app.urls', namespace='the_user_app')),
        path('stores/', include('store.urls', namespace='store')),
        path('orders/', include('orders.urls', namespace='orders')),
        path('payments/', include('payments.urls', namespace='payments')),
        path('deliveries/', include('deliveries.urls', namespace='deliveries')),
        path('cart/', include('cart.urls', namespace='cart')),
        path('tasks/', include('tasks.urls', namespace='tasks')),
        path('messaging/', include('messaging.urls', namespace='messaging')),
    ])),
    
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT) + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
