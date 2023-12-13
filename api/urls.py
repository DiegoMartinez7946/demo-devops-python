from .views import *
from django.urls import path, include
from rest_framework import routers
from .views import health_check


router = routers.DefaultRouter()
router.register('users', UserViewSet, 'users')

urlpatterns = [
    path('health', health_check, name='health_check'),
    path('', include(router.urls)),  # Include router URLs
]