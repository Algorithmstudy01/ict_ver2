from django.contrib import admin
from django.urls import path, include

from django.contrib import admin
from rest_framework import routers
from django.urls import path,include
from django.conf import settings
from django.conf.urls.static import static
from ict import views

# router = routers.DefaultRouter()
# router.register(r'test', views.TestViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('ict.urls')),
        # 'ict'는 앱 이름입니다.
]
