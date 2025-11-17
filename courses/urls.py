from django.urls import path
from . import views


urlpatterns = [
    path('course/',views.home),
    path('<id>/',views.course_id)
]