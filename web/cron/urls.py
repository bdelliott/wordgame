from django.conf.urls.defaults import *

import views

urlpatterns = patterns('',

    # Reminder
    url(r'^reminder', views.reminder, name="reminder"),

)
