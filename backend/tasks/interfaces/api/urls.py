from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import TaskViewSet
from .views import TaskApplicationViewSet
from .views import TaskAssignmentViewSet
from .views import ReviewViewSet
from .views import TaskCategoryViewSet
from .views import PredefinedTaskViewSet

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'applications', TaskApplicationViewSet, basename='application')
router.register(r'assignments', TaskAssignmentViewSet, basename='assignment')
router.register(r'reviews', ReviewViewSet, basename='review')
router.register(r'categories', TaskCategoryViewSet, basename='category')
router.register(r'predefined-tasks', PredefinedTaskViewSet, basename='predefined_task')

urlpatterns = [
    path('', include(router.urls)),
]
