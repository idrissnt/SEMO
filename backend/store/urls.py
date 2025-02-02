from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import routers

from store.views import ShopStoreList, CategoryList, productList, articleList
#Create a router and register our viewsets with it.
router = routers.DefaultRouter()
router.register(r'shopstore', ShopStoreList, basename='store')
router.register(r'category', CategoryList, basename='category')
router.register(r'product', productList, basename='product')
router.register(r'article', articleList, basename='article')

app_name = 'store'
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('the_user_app.urls')),
    path('api/', include(router.urls)),
]
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


