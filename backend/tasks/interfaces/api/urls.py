from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views.task_views import TaskViewSet
from .views.task_application_views import TaskApplicationViewSet
from .views.task_assignment_views import TaskAssignmentViewSet
from .views.review_views import ReviewViewSet
from .views.task_category_views import TaskCategoryViewSet

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'applications', TaskApplicationViewSet, basename='application')
router.register(r'assignments', TaskAssignmentViewSet, basename='assignment')
router.register(r'reviews', ReviewViewSet, basename='review')
router.register(r'categories', TaskCategoryViewSet, basename='category')

urlpatterns = [
    path('', include(router.urls)),
]
