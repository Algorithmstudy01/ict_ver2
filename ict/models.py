
from django.db import models
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import make_password, check_password

class Userlist(models.Model):
    id = models.CharField(primary_key=True, unique=True, max_length=50)
    nickname = models.CharField(null=False, max_length=30)
    password = models.CharField(max_length=100)  # Ensure this is hashed in production
    location = models.CharField(max_length=255)
    email = models.EmailField(unique=True)

from django.contrib.auth.models import User
from django.db import models

class Family(models.Model):
    user = models.ForeignKey(User, related_name='family_members', on_delete=models.CASCADE)
    family_member = models.ForeignKey(User, related_name='related_family_members', on_delete=models.CASCADE)
    relationship = models.CharField(max_length=50)

    def __str__(self):
        return f'{self.user.username} - {self.family_member.username} ({self.relationship})'


class FamilyMember(models.Model):

    user = models.ForeignKey(Userlist, on_delete=models.CASCADE, related_name='family_members')
    name = models.CharField(max_length=100)
    relationship = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)

from django.db import models


from django.db import models

class Alarm(models.Model):
    user_id = models.CharField(max_length=100)
    time = models.CharField(max_length=10)  # 시간 형식에 따라 조정
    days = models.JSONField()  # 선택된 요일을 저장
    name = models.CharField(max_length=255, blank=True, null=True)  # 알약의 이름
    usage = models.TextField(blank=True, null=True)  # 용법

    def __str__(self):
        return f"Alarm for {self.user_id} at {self.time} (Pill: {self.name})"


class FavoritePill(models.Model):
    user = models.ForeignKey(Userlist, on_delete=models.CASCADE)
    pill_code = models.CharField(max_length=100)
    pill_name = models.CharField(max_length=100)


from django.db import models

class SearchHistory(models.Model):
    user = models.ForeignKey(Userlist, on_delete=models.CASCADE)

   
    pill_info = models.TextField()

# models.py

from django.db import models

class Pill(models.Model):
    code = models.CharField(max_length=100)
    name = models.CharField(max_length=255)
    image_path = models.CharField(max_length=255)
    # Add other fields as needed


class Search(models.Model):
    user = models.ForeignKey(Userlist, on_delete=models.CASCADE)
    pill_info = models.TextField()
    
from django.db import models

class Sear(models.Model):
    pill_code = models.CharField(max_length=255)
    pill_name = models.CharField(max_length=255)
    confidence = models.CharField(max_length=255)
    efficacy = models.TextField()
    manufacturer = models.CharField(max_length=255)
    usage = models.TextField()
    precautions_before_use = models.TextField()
    usage_precautions = models.TextField()
    drug_food_interactions = models.TextField()
    side_effects = models.TextField()
    storage_instructions = models.TextField()
    pill_image = models.TextField()
    pill_info = models.TextField()  # 이 필드가 모델에 정의되어 있어야 합니다.
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey('UserList', on_delete=models.CASCADE)  # ForeignKey 필드가 정확한지 확인합니다.

class Record(models.Model):
    pill_code = models.CharField(max_length=255)
    pill_name = models.CharField(max_length=255)
    confidence = models.CharField(max_length=255)
    predicted_category_id = models.IntegerField(null=True, blank=True)  # 새 필드 추가
    efficacy = models.TextField()
    manufacturer = models.CharField(max_length=255)
    usage = models.TextField()
    precautions_before_use = models.TextField()
    usage_precautions = models.TextField()
    drug_food_interactions = models.TextField() 
    side_effects = models.TextField()
    storage_instructions = models.TextField()
    pill_image = models.TextField()
    pill_info = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey('UserList', on_delete=models.CASCADE)


from django.db import models

class Favorite(models.Model):
    pill_code = models.CharField(max_length=255)
    pill_name = models.CharField(max_length=255)
    confidence = models.CharField(max_length=255)
    efficacy = models.TextField()
    manufacturer = models.CharField(max_length=255)
    usage = models.TextField()
    precautions_before_use = models.TextField()
    usage_precautions = models.TextField()
    drug_food_interactions = models.TextField()
    side_effects = models.TextField()
    storage_instructions = models.TextField()
    pill_image = models.TextField()
    pill_info = models.TextField(null=True, blank=True)  
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey('UserList', on_delete=models.CASCADE)
    predicted_category_id = models.IntegerField(null=True, blank=True)  # 새 필드 추가

    def __str__(self):
        return self.pill_name


# models.py
from django.db import models
from django.contrib.auth.models import User

class SentItem(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    pill_code = models.CharField(max_length=100)
    pill_name = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.pill_name} sent to {self.user.username}"
