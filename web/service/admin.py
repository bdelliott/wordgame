from django.contrib import admin

from models import *

class DailyWordAdmin(admin.ModelAdmin):
        list_display = ('date', 'word')

admin.site.register(DailyWord, DailyWordAdmin)
admin.site.register(Score)
admin.site.register(User)
admin.site.register(Word)
admin.site.register(ConfigValue)
