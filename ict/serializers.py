from rest_framework import serializers
from .models import Userlist


class UserlistSerializer(serializers.ModelSerializer):
    class Meta:
        model = Userlist
        fields = ('id', 'nickname','password','location', 'email')

# # serializers.py

from rest_framework import serializers
from .models import FamilyMember

class FamilyMemberSerializer(serializers.ModelSerializer):
    class Meta:
        model = FamilyMember
        fields = ['name', 'relationship', 'phone_number', 'address']


from rest_framework import serializers
from .models import Alarm

class AlarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alarm
        fields = ['id', 'user_id', 'time', 'days', 'name', 'usage']


from rest_framework import serializers
from .models import FavoritePill

class FavoritePillSerializer(serializers.ModelSerializer):
    class Meta:
        model = FavoritePill
        fields = ['pill_code', 'pill_name']



from rest_framework import serializers
from .models import Record

class SearchHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Record
        fields = [
            'pill_code', 'pill_name', 'confidence', 'efficacy', 'manufacturer',
            'usage', 'precautions_before_use', 'usage_precautions',
            'drug_food_interactions', 'side_effects', 'storage_instructions',
            'pill_image', 'user', 'created_at','pill_info','pill_info'
        ]

