from django.urls import path
from .views import StoreListView, PopularStoresView, NearbyStoresView

app_name = 'store'

urlpatterns = [
    path('', StoreListView.as_view(), name='store-list'),
    path('popular/', PopularStoresView.as_view(), name='popular-stores'),
    path('nearby/', NearbyStoresView.as_view(), name='nearby-stores'),
]
