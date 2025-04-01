from django.urls import path, include
from rest_framework.routers import DefaultRouter
from payments.interfaces.api.views import PaymentViewSet, PaymentMethodViewSet
from payments.webhooks import stripe_webhook

router = DefaultRouter()
router.register(r'payments', PaymentViewSet, basename='payment')
router.register(r'payment-methods', PaymentMethodViewSet, basename='payment-method')

urlpatterns = [
    path('', include(router.urls)),
    path('stripe-webhook/', stripe_webhook, name='stripe-webhook'),
]