from rest_framework import permissions
from deliveries.models import Delivery, Driver

# class IsAdminOrDriverOwner(permissions.BasePermission):
#     def has_object_permission(self, request, view, obj):
#         # 1. Admins can do anything
#         if request.user.is_staff:
#             return True
        
#         # 2. For Delivery objects: Check if user is the assigned driver
#         if isinstance(obj, Delivery):
#             return obj.driver.user == request.user
        
#         # 3. For Driver objects: Check if user owns the driver profile
#         if isinstance(obj, Driver):
#             return obj.user == request.user
        
#         # 4. Deny access by default
#         return False