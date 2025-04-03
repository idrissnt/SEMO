from django.urls import path, include

app_name = 'tasks'

urlpatterns = [
    path('', include('tasks.interfaces.api.urls')),
]
