from django.urls import path, include

app_name = 'the_user_app'

urlpatterns = [
    # Include the interface layer URLs
    path('', include('the_user_app.interfaces.api.urls')),
]
