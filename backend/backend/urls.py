"""
URL configuration for backend project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import routers

from store.views import ShopStoreList, CategoryList, productList, articleList

from Cart.views import CartViewSet

from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)
#Create a router and register our viewsets with it.
router = routers.DefaultRouter()
router.register(r'shopstore', ShopStoreList, basename='store')
router.register(r'category', CategoryList, basename='category')
router.register(r'product', productList, basename='product')
router.register(r'article', articleList, basename='article')

app_name = 'store'

router.register(r'cart', CartViewSet, basename='add_to_cart')



urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include(router.urls)),
     path('api/v1/', include(router.urls)),
    # API URLs
    path('api/v1', include([
       path('', include('the_user_app.urls')),

        path('recipes/', include('recipe.urls', namespace='recipe')),
    ])),
    
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT) + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)