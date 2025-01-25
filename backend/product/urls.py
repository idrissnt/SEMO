from django.urls import path
from .views import ProductListView, SeasonalProductsView

app_name = 'product'

urlpatterns = [
    path('', ProductListView.as_view(), name='product-list'),
    path('seasonal/', SeasonalProductsView.as_view(), name='seasonal-products'),
]
