from django.urls import path
from .views import predict
from . import views
from django.urls import path

from django.conf.urls.static import static
from django.conf import settings
from .views import RecommendPillView  # Import your view
from .views import  create_alarm, list_alarms,UpdateAlarmView, DeleteAlarmView

from .views import RecommendPillView, RecommendationListView  # RecommendationListView 임포트 추가


urlpatterns = [
    path('predict/', views.predict, name='predict'),  # Ensure this line exists
    path('predict2/', views.predict2, name='predict'),  # Ensure this line exists

    path('user_info/<str:user_id>/', views.user_info, name='get_user_info'),
    path('login_view/', views.login_view, name='login_view'),
    path('register/', views.register_user, name='register_user'),
    path('find_user_id/', views.find_user_id, name='find_user_id'),
    path('change_password/', views.change_password, name='change_password'),
    path('find_password/', views.find_password, name='find_password'),
    path('addfamilymember/<str:user_id>/', views.add_family_member, name='add_family_member'),
    path('alarms/delete/<int:pk>/', DeleteAlarmView.as_view(), name='delete_alarm'),
    path('alarms/update/<int:pk>/', UpdateAlarmView.as_view(), name='update_alarm'),
    path('alarms/create/', create_alarm, name='create_alarm'),
    path('alarms/<str:user_id>/', list_alarms, name='list_alarms'),
    path('favorites/add/', views.add_favorite, name='add_favorite'),
    path('favorites/remove/', views.remove_favorite, name='remove_favorite'),
    path('favorites/<str:user_id>/', views.FavoritesView.as_view(), name='favorites-list'),
     path('save_search_history/', views.save_search_history, name='save_search_history'),
 path('get_search_history/<str:user_id>/', views.get_search_history, name='get_search_history'),
  path('checkmember/<str:user_id>/', views.check_member, name='check_member'),
   path('family/send/', views.send_family_info, name='send_family_info'),
   path('images/<str:image_filename>/', views.serve_image, name='serve_image'),  # 이미지 서빙 URL 패턴
    #  path('family/sent-items/', views.get_sent_items, name='get_sent_items'),
path('getfamilymembers/<str:user_id>/', views.get_family_members, name='get_family_members'),
 path('recommendations/<str:user_id>/', RecommendationListView.as_view(), name='recommendation_list'),
  path('updatefamilymember/<str:family_member_id>/', views.update_family_member, name='update_family_member'),
   path('deletefamilymember/<str:name>/', views.delete_family_member, name='delete_family_member'),
    # Other paths...
 path('recommend/', RecommendPillView.as_view(), name='recommend-pill'),  # URL pattern for the recommendation view

   ]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])