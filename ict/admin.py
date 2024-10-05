from django.contrib import admin
from .models import Userlist
from .models import FamilyMember
from .models import Alarm
from .models import Favorite
from .models import Record
from .models import SentItem
from .models import PillRecommendation
# Register your models here.
admin.site.register(Userlist)
admin.site.register(FamilyMember)
admin.site.register(Alarm)
admin.site.register(PillRecommendation)
admin.site.register(SentItem)
admin.site.register(Record)
admin.site.register(Favorite)