import json
import numpy as np
import tensorflow as tf
from PIL import Image
from django.http import JsonResponse
from .models import Userlist, Record
from .serializers import UserlistSerializer
from django.contrib.auth import authenticate
from django.urls import path
from django.http import HttpResponse
from django.shortcuts import render
import requests
from django.http import HttpResponseNotAllowed, JsonResponse
from django.contrib.auth import authenticate, login
from django.middleware.csrf import get_token
from django.views.decorators.csrf import csrf_exempt
import json
from django.db.models import F
from django.contrib.auth.hashers import make_password



import pytesseract
from django.shortcuts import render, redirect
from django.contrib import messages
from django import forms
from .models import Userlist
from django.urls import path
# ict/views.py


import torch
import torchvision.transforms as transforms
from PIL import Image
from rest_framework.decorators import api_view
import pytesseract

import os
import json
import torch
import torchvision.transforms as transforms
from PIL import Image
import pytesseract
from django.shortcuts import render
from django.http import JsonResponse
from django.conf import settings
from .models import Userlist
import torch
import torchvision
from django.conf import settings
from PIL import Image
import torchvision.transforms as transforms
import json
import os

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import api_view
import torch
import torchvision.transforms as T
from PIL import Image
import os
import json
import csv

import os
import csv
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view
from PIL import Image
import torchvision.transforms as T
import torch
import torchvision

import os
import csv
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view
from PIL import Image
import torchvision.transforms as T
import torch
import torchvision

def get_model(num_classes):
    from torchvision.models.detection import FasterRCNN
    from torchvision.models.mobilenetv3 import mobilenet_v3_large
    from torchvision.models.detection.anchor_utils import AnchorGenerator

    # MobileNetV3 기반 백본을 사용
    backbone = mobilenet_v3_large(pretrained=True).features
    backbone.out_channels = 960  # MobileNetV3 Large의 출력 채널 수

    # 단일 특성 맵을 위한 앵커 생성기 설정
    anchor_generator = AnchorGenerator(
        sizes=((32, 64, 128, 256, 512),),
        aspect_ratios=((0.5, 1.0, 2.0),) * 5
    )

    # RoIAlign 설정 (단일 레벨 특성 맵 사용)
    roi_pooler = torchvision.ops.MultiScaleRoIAlign(
        featmap_names=['0'], output_size=7, sampling_ratio=2
    )

    # Faster R-CNN 모델 정의
    model = FasterRCNN(
        backbone,
        num_classes=num_classes,
        rpn_anchor_generator=anchor_generator,
        box_roi_pool=roi_pooler
    )
    
    return model

# CSV에서 알약 정보를 검색하는 함수
def find_pill_info_from_csv(predicted_category_id, csv_path):
    with open(csv_path, mode='r', encoding='utf-8-sig') as file:  # UTF-8 인코딩 사용
        reader = csv.DictReader(file)
        for row in reader:
            if int(row['category_id']) == predicted_category_id:
                pill_info = {
                    "제품명": row["제품명"],
                    "drug_N": row["drug_N"],
                    "품목기준코드": row["품목기준코드"],
                    "제조/수입사": row["제조/수입사"],
                    "이 약의 효능은 무엇입니까?": row["이 약의 효능은 무엇입니까?"],
                    "이 약은 어떻게 사용합니까?": row["이 약은 어떻게 사용합니까?"],
                    "이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?": row["이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?"],
                    "이 약의 사용상 주의사항은 무엇입니까?": row["이 약의 사용상 주의사항은 무엇입니까?"],
                    "이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?": row["이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?"],
                    "이 약은 어떤 이상반응이 나타날 수 있습니까?": row["이 약은 어떤 이상반응이 나타날 수 있습니까?"],
                    "이 약은 어떻게 보관해야 합니까?": row["이 약은 어떻게 보관해야 합니까?"]
                }
                return pill_info
    return None

@api_view(['POST'])
@csrf_exempt
def predict(request):
    if 'image' not in request.FILES:
        return JsonResponse({'error': 'No image file provided'}, status=400)

    image_file = request.FILES['image']
    image_path = '/tmp/temp_image.jpg'
    
    try:
        with open(image_path, 'wb') as f:
            for chunk in image_file.chunks():
                f.write(chunk)
        
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        num_classes = 54  
        model = get_model(num_classes=num_classes)
        
        model.load_state_dict(torch.load('/Users/seon/Desktop/model/pill_detection_4.pth', map_location=device))
        model.to(device)  
        
        image = Image.open(image_path).convert("RGB")
        transform = T.Compose([T.ToTensor()])
        image_tensor = transform(image).unsqueeze(0).to(device)  # Ensure the tensor is on the same device
    except Exception as e:
        return JsonResponse({'error': f'Error loading model or processing image: {str(e)}'}, status=500)

    try:
        model.eval()
        with torch.no_grad():
            outputs = model(image_tensor)
        
        threshold = 0.5
        pred_scores = outputs[0]['scores'].cpu().numpy()
        pred_labels = outputs[0]['labels'].cpu().numpy()
        pred_labels = pred_labels[pred_scores >= threshold]
        pred_scores = pred_scores[pred_scores >= threshold]

        if len(pred_labels) == 0:
            return JsonResponse({'message': 'No predictions made'}, status=200)

        max_score_idx = pred_scores.argmax()
        predicted_category_id = pred_labels[max_score_idx]

        csv_path = '/Users/seon/Desktop/model/info.csv'

        pill_info_csv = find_pill_info_from_csv(predicted_category_id, csv_path)

        response_data = {
            'prediction_score': float(pred_scores[max_score_idx]),
            'product_name': pill_info_csv.get('제품명', 'Unknown'),
            'manufacturer': pill_info_csv.get('제조/수입사', 'Unknown'),
            'pill_code': pill_info_csv.get('품목기준코드', 'Unknown'),
            'efficacy': pill_info_csv.get('이 약의 효능은 무엇입니까?', 'No information'),
            'usage': pill_info_csv.get('이 약은 어떻게 사용합니까?', 'No information'),
            'precautions_before_use': pill_info_csv.get('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?', 'No information'),
            'usage_precautions': pill_info_csv.get('이 약의 사용상 주의사항은 무엇입니까?', 'No information'),
            'drug_food_interactions': pill_info_csv.get('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?', 'No information'),
            'side_effects': pill_info_csv.get('이 약은 어떤 이상반응이 나타날 수 있습니까?', 'No information'),
            'storage_instructions': pill_info_csv.get('이 약은 어떻게 보관해야 합니까?', 'No information'),
             'predicted_category_id': int(predicted_category_id),  # Ensure this is included
        }
    except Exception as e:
        return JsonResponse({'error': f'Error during prediction: {str(e)}'}, status=500)
    finally:
        if os.path.exists(image_path):
            os.remove(image_path)

    return JsonResponse(response_data, status=200)


from django.views.decorators.csrf import csrf_exempt

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Userlist
from .serializers import UserlistSerializer
# 회원가입
@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        data = request.data
        nickname = data.get('nickname', '')
        id = data.get('id', '')
        password = data.get('password', '')
        location = data.get('location', '')
        email = data.get('email', '')

        # Validate input data
        if not all([nickname, id, password, location, email]):
            return Response({'message': '모든 필드를 입력해야 합니다.'}, status=status.HTTP_400_BAD_REQUEST)

        # Check for duplicates
        if Userlist.objects.filter(nickname=nickname).exists():
            return Response({'message': '이미 사용중인 닉네임입니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
        if Userlist.objects.filter(id=id).exists():
            return Response({'message': '이미 사용중인 아이디입니다.'}, status=status.HTTP_400_BAD_REQUEST)

        if Userlist.objects.filter(email=email).exists():
            return Response({'message': '가입된 이메일이 존재합니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Serialize and save data
        serializer = UserlistSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 로그인 로직
import json
from django.http import JsonResponse
from .models import Userlist
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate
from .models import Userlist

import json
from django.http import JsonResponse
from .models import Userlist

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            id = data.get('id')
            password = data.get('password')

            print(f"Received login request: ID={id}, Password={password}")

            # 사용자 모델에서 해당 ID로 사용자 찾기
            try:
                user = Userlist.objects.get(id=id)
            except Userlist.DoesNotExist:
                user = None

            # 사용자가 존재하고, 비밀번호가 일치하는지 확인
            if user is not None:
                if user.password == password:
                    # 인증 성공
                    return JsonResponse({'message': '로그인 성공'}, status=200)
                else:
                    # 인증 실패
                    return JsonResponse({'error': 'ID나 비밀번호가 일치하지 않습니다.'}, status=400)
            else:
                # 사용자가 존재하지 않음
                return JsonResponse({'error': 'ID나 비밀번호가 일치하지 않습니다.'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'error': '잘못된 JSON 형식입니다.'}, status=400)
        except Exception as e:
            print(f"Unexpected error: {e}")
            return JsonResponse({'error': '서버 오류가 발생했습니다.'}, status=500)
    else:
        return JsonResponse({'error': '잘못된 요청입니다.'}, status=400)

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist
from .serializers import UserlistSerializer

@api_view(['GET'])
def user_info(request, user_id):
    try:
        user = Userlist.objects.get(id=user_id)
        serializer = UserlistSerializer(user)
        return Response(serializer.data, status=200)
    except Userlist.DoesNotExist:
        return Response({"message": "사용자를 찾을 수 없음"}, status=404)

@api_view(['POST'])
def find_user_id(request):
    if request.method == 'POST':
        email = request.data.get('email', None)
        if email:
            try:
                user = Userlist.objects.get(email=email)
                serializer = UserlistSerializer(user)
                return JsonResponse({"id": serializer.data['id']}, status=200)
            except Userlist.DoesNotExist:
                return JsonResponse({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return JsonResponse({"message": "이메일을 입력해주세요."}, status=400)

# 비밀번호 찾기from rest_framework.decorators import api_view

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist  # Adjust according to your user model
from .serializers import UserlistSerializer  # Adjust according to your serializer

@api_view(['POST'])
def find_password(request):
    id = request.data.get('id', None)
    email = request.data.get('email', None)

    if not id or not email:
        return Response({"message": "아이디와 이메일을 입력해주세요."}, status=400)

    try:
        user = Userlist.objects.get(id=id, email=email)
        return Response({"password": user.password}, status=200)
    except Userlist.DoesNotExist:
        return Response({"message": "일치하는 사용자가 없습니다."}, status=400)




# 업데이트 비밀번호
@api_view(['POST'])
def change_password(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_id = data.get('id')
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')

        if user_id and current_password and new_password:
            try:
                # 사용자 확인
                user = Userlist.objects.get(id=user_id)
                user.password = new_password
                user.save()
                return Response({"message": "비밀번호가 성공적으로 업데이트되었습니다."}, status=200)
            except Userlist.DoesNotExist:
                return Response({"message": "일치하는 사용자가 없습니다."}, status=400)
        else:
            return Response({"message": "ID와 새로운 비밀번호를 모두 제공해주세요."}, status=400)

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .serializers import FamilyMemberSerializer
from rest_framework import status
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Userlist, FamilyMember  # FamilyMember를 추가하세요


from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['POST'])
def add_family_member(request, user_id):
    try:
        user = Userlist.objects.get(id=user_id)  # 현재 로그인한 사용자
    except Userlist.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    # Serializer를 사용하여 가족 정보를 추가
    serializer = FamilyMemberSerializer(data=request.data)
    if serializer.is_valid():
        # 선택한 가족 관계를 확인하고 적절히 설정
        relationship = serializer.validated_data.get('relationship', '')
        if relationship == "부모":
            relationship = "자녀"  # 부모를 선택한 경우, 자녀로 설정
        elif relationship == "자녀":
            relationship = "부모"  # 자녀를 선택한 경우, 부모로 설정
        elif relationship == "배우자":
            relationship = "배우자" 
        elif relationship == "형제/자매":
            relationship = "형제/자매" 

        # 가족 정보를 DB에 저장
        family_member = serializer.save(user=user)  # A 사용자의 가족으로 등록

        # 방금 추가한 가족의 ID를 가져오기
        family_member_user = FamilyMember(
            user=Userlist.objects.get(id=serializer.validated_data['name']),  # 추가한 가족의 Userlist 인스턴스
            name=user.nickname,  # 추가한 가족의 이름
            relationship=relationship,  # 수정된 가족의 관계
            phone_number=user.email,  # 추가한 가족의 전화번호를 Userlist에서 가져옴
            address=user.location  # 사용자 위치
        )
        family_member_user.save()  # 방금 추가한 가족에게 현재 사용자를 가족으로 추가 저장

        return Response({'message': 'Family member added successfully'}, status=status.HTTP_201_CREATED)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist, FamilyMember
from .serializers import FamilyMemberSerializer
from rest_framework import status

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Userlist, FamilyMember
from .serializers import FamilyMemberSerializer
from rest_framework import status

@api_view(['GET'])
def get_family_members(request, user_id):
    try:
        user = Userlist.objects.get(id=user_id)
    except Userlist.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    family_members = FamilyMember.objects.filter(user=user)
    serializer = FamilyMemberSerializer(family_members, many=True)
    response = Response(serializer.data, status=status.HTTP_200_OK)
    
    # Explicitly set Content-Type header (optional)
    response['Content-Type'] = 'application/json; charset=utf-8'
    return response

@csrf_exempt
def check_member(request, user_id):
    if request.method == 'GET':
        user_exists = Userlist.objects.filter(id=user_id).exists()
        return JsonResponse({'exists': user_exists})

# 가족 추가 API
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Userlist
from .serializers import FamilyMemberSerializer


from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Alarm
from .serializers import AlarmSerializer
from django.http import JsonResponse

# 알람 생성
@api_view(['POST'])
def create_alarm(request):
    serializer = AlarmSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 특정 사용자의 알람 리스트 조회
@api_view(['GET'])
def list_alarms(request, user_id):
    alarms = Alarm.objects.filter(user_id=user_id)
    serializer = AlarmSerializer(alarms, many=True)
    return Response(serializer.data)

# 알람 수정
class UpdateAlarmView(APIView):
    def put(self, request, pk):
        try:
            alarm = Alarm.objects.get(pk=pk)
        except Alarm.DoesNotExist:
            return Response({'error': 'Alarm not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = AlarmSerializer(alarm, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 알람 삭제
class DeleteAlarmView(APIView):
    def delete(self, request, pk):
        try:
            alarm = Alarm.objects.get(pk=pk)
        except Alarm.DoesNotExist:
            return Response({'error': 'Alarm not found'}, status=status.HTTP_404_NOT_FOUND)

        alarm.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view



from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
import json

from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Favorite, Userlist
import json

from django.http import JsonResponse
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_exempt
from django.core.exceptions import ObjectDoesNotExist
from .models import Favorite, Userlist
import json


@csrf_exempt
@require_POST
def add_favorite(request):
    try:
        data = json.loads(request.body)
        user_id = data['user_id']
        pill_code = data['pill_code']
        pill_name = data['pill_name']
        confidence = data['confidence']
        efficacy = data['efficacy']
        manufacturer = data['manufacturer']
        usage = data['usage']
        precautions_before_use = data['precautions_before_use']
        usage_precautions = data['usage_precautions']
        drug_food_interactions = data['drug_food_interactions']
        side_effects = data['side_effects']
        storage_instructions = data['storage_instructions']
        pill_image = data['pill_image']
        pill_info = data['pill_info']
        predicted_category_id = data['predicted_category_id']  # 대괄호로 수정
        
    except (KeyError, json.JSONDecodeError):
        return JsonResponse({'error': 'Invalid data'}, status=400)

    try:
        user = Userlist.objects.get(id=user_id)
    except Userlist.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

    # Check if the favorite already exists
    if Favorite.objects.filter(user=user, pill_code=pill_code).exists():
        return JsonResponse({'message': 'Favorite already exists'}, status=409)  # Conflict

    # Create a new favorite entry
    Favorite.objects.create(
        user=user,
        pill_code=pill_code,
        pill_name=pill_name,
        confidence=confidence,
        efficacy=efficacy,
        manufacturer=manufacturer,
        usage=usage,
        precautions_before_use=precautions_before_use,
        usage_precautions=usage_precautions,
        drug_food_interactions=drug_food_interactions,
        side_effects=side_effects,
        storage_instructions=storage_instructions,
        pill_image=pill_image,
        pill_info=pill_info,
        predicted_category_id=predicted_category_id,  # 저장
    )

    return JsonResponse({'message': 'Favorite added successfully'}, status=201)

from django.http import JsonResponse
from django.views.decorators.http import require_POST
from .models import Favorite  # Adjust the import according to your project structure

@require_POST
def remove_favorite(request):
    # Parse the request body
    try:
        data = json.loads(request.body)
        user_id = data['user_id']
        pill_code = data['pill_code']
    except (KeyError, json.JSONDecodeError):
        return JsonResponse({'error': 'Invalid data'}, status=400)

    # Retrieve the user and delete the favorite
    try:
        user = Userlist.objects.get(id=user_id)
        favorites = Favorite.objects.filter(user=user, pill_code=pill_code)
        if favorites.exists():
            favorites.delete()
            return JsonResponse({'message': 'Favorite removed successfully'}, status=200)
        else:
            return JsonResponse({'error': 'Favorite not found'}, status=404)
    except User.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

# views.py
from django.http import JsonResponse

from django.views import View
from django.http import JsonResponse
from django.views import View
from django.http import JsonResponse
from .models import Favorite
from django.views import View

class FavoritesView(View):
    def get(self, request, user_id):
        favorites = Favorite.objects.filter(user_id=user_id).values(
            'pill_code', 'pill_name', 'confidence', 'efficacy', 'manufacturer', 
            'usage', 'precautions_before_use', 'usage_precautions', 
            'drug_food_interactions', 'side_effects', 'storage_instructions', 
            'pill_image', 'pill_info', 'created_at','predicted_category_id'
        )
        data = list(favorites)
        return JsonResponse(data, safe=False)

# views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET
from .models import Record

@csrf_exempt
@require_GET

def get_search_history(request, user_id):
    records = Record.objects.filter(user__id=user_id)
    data = list(records.values(
        'pill_code', 'pill_name', 'confidence', 'efficacy', 'manufacturer',
        'usage', 'precautions_before_use', 'usage_precautions', 'drug_food_interactions',
        'side_effects', 'storage_instructions', 'pill_image', 'pill_info','predicted_category_id' 
    ))
  
    return JsonResponse({'results': data})
from django.http import JsonResponse
import json
from .models import Userlist, Record

from django.http import JsonResponse
import json
from .models import Userlist, Record

def save_search_history(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            pill_info = data.get('pill_info')
            user_id = data.get('user_id')
            prediction_score = data.get('prediction_score')
            product_name = data.get('product_name')
            manufacturer = data.get('manufacturer')
            pill_code = data.get('pill_code')
            efficacy = data.get('efficacy')
            usage = data.get('usage')
            precautions_before_use = data.get('precautions_before_use')
            usage_precautions = data.get('usage_precautions')
            drug_food_interactions = data.get('drug_food_interactions')
            side_effects = data.get('side_effects')
            storage_instructions = data.get('storage_instructions')
            predicted_category_id = data.get('predicted_category_id')  # predicted_category_id 추가

            # Validate the received data
            if not all([user_id, prediction_score, product_name, manufacturer, pill_code]):
                return JsonResponse({'status': 'error', 'message': 'Missing required fields'}, status=400)

            # Fetch or create the User instance
            try:
                user_instance = Userlist.objects.get(pk=user_id)
            except Userlist.DoesNotExist:
                return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)

            # Create a new Record entry
           # 새로운 레코드 생성
            record = Record.objects.create(
                pill_code=pill_code,
                pill_name=product_name,
                confidence=prediction_score,
                predicted_category_id=predicted_category_id,  # 저장
                efficacy=efficacy,
                manufacturer=manufacturer,
                usage=usage,
                precautions_before_use=precautions_before_use,
                usage_precautions=usage_precautions,
                drug_food_interactions=drug_food_interactions,
                side_effects=side_effects,
                storage_instructions=storage_instructions,
                pill_image='',  # 필요에 따라 이미지 URL을 추가
                pill_info=pill_info,
                user=user_instance
            )

            print("Record created successfully")
            return JsonResponse({'status': 'success', 'message': 'Record created successfully'}, status=201)
        
        except json.JSONDecodeError:
            return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)
        
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    
    else:
        return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)


from django.http import JsonResponse
import json

def send_family_info(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            # Process the data as needed
            return JsonResponse({'status': 'success'})
        except json.JSONDecodeError:
            return JsonResponse({'status': 'failure', 'message': 'Invalid JSON'}, status=400)
    return JsonResponse({'status': 'failure', 'message': 'Invalid request method'}, status=405)

import csv
import torch
from PIL import Image
import torchvision.transforms as T
from rest_framework.decorators import api_view
from django.http import JsonResponse
import logging
from django.views.decorators.csrf import csrf_exempt 
import os

def get_model2(num_classes):
    from torchvision.models.detection import FasterRCNN
    from torchvision.models.mobilenetv3 import mobilenet_v3_large
    from torchvision.models.detection.anchor_utils import AnchorGenerator

    backbone = mobilenet_v3_large(pretrained=True).features
    backbone.out_channels = 960

    anchor_generator = AnchorGenerator(
        sizes=((32, 64, 128, 256, 512),),
        aspect_ratios=((0.5, 1.0, 2.0),) * 5
    )

    roi_pooler = torchvision.ops.MultiScaleRoIAlign(
        featmap_names=['0'], output_size=7, sampling_ratio=2
    )

    model = FasterRCNN(
        backbone,
        num_classes=num_classes,
        rpn_anchor_generator=anchor_generator,
        box_roi_pool=roi_pooler
    )
    
    return model

logger = logging.getLogger(__name__)

# CSV에서 알약 정보를 검색하는 함수
def find_pill_info_from_csv2(predicted_category_id, csv_path):
    with open(csv_path, mode='r', encoding='utf-8-sig') as file:
        reader = csv.DictReader(file)
        for row in reader:
            if int(row['category_id']) == predicted_category_id:
                pill_info = {
                    "제품명": row["제품명"],
                    "drug_N": row["drug_N"],
                    "품목기준코드": row["품목기준코드"],
                    "제조/수입사": row["제조/수입사"],
                    "이 약의 효능은 무엇입니까?": row["이 약의 효능은 무엇입니까?"],
                    "이 약은 어떻게 사용합니까?": row["이 약은 어떻게 사용합니까?"],
                    "이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?": row["이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?"],
                    "이 약의 사용상 주의사항은 무엇입니까?": row["이 약의 사용상 주의사항은 무엇입니까?"],
                    "이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?": row["이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?"],
                    "이 약은 어떤 이상반응이 나타날 수 있습니까?": row["이 약은 어떤 이상반응이 나타날 수 있습니까?"],
                    "이 약은 어떻게 보관해야 합니까?": row["이 약은 어떻게 보관해야 합니까?"]
                }
                return pill_info
    return None

def find_pill_info(predicted_category_id, root_dir):
    image_file_name = f"{predicted_category_id}.png"
    image_path = os.path.join(root_dir, image_file_name)

    if os.path.exists(image_path):
        # 이미지 경로를 터미널에 출력
        print(f'Image path: {image_path}')
        pill_info = {
            "image_path": image_path
        }
        return pill_info
    else:
        print(f'Image path not found for category ID {predicted_category_id}')
        return None



@api_view(['POST'])
@csrf_exempt
def predict2(request):
    if 'image' not in request.FILES:
        logger.error('No image file provided')
        return JsonResponse({'error': 'No image file provided'}, status=400)

    image_file = request.FILES['image']
    image_path = '/tmp/temp_image.jpg'
    
    try:
        with open(image_path, 'wb') as f:
            for chunk in image_file.chunks():
                f.write(chunk)

        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        num_classes = 151
        model = get_model2(num_classes=num_classes)

        logger.info('Loading model weights')
        model.load_state_dict(torch.load('/Users/seon/Desktop/Ict_FIN/pill_detection_4.pth', map_location=device))
        model.to(device)
        logger.info('Model weights loaded successfully')

        image = Image.open(image_path).convert("RGB")
        transform = T.Compose([T.ToTensor()])
        image_tensor = transform(image).unsqueeze(0).to(device)

    except Exception as e:
        logger.error(f'Error loading model or processing image: {str(e)}')
        return JsonResponse({'error': f'Error loading model or processing image: {str(e)}'}, status=500)

    try:
        model.eval()
        with torch.no_grad():
            outputs = model(image_tensor)

        threshold = 0.5
        pred_scores = outputs[0]['scores'].cpu().numpy()
        pred_labels = outputs[0]['labels'].cpu().numpy()
        pred_labels = pred_labels[pred_scores >= threshold]
        pred_scores = pred_scores[pred_scores >= threshold]

        if len(pred_labels) == 0:
            logger.info('No predictions made')
            return JsonResponse({'message': 'No predictions made'}, status=200)

        max_score_idx = pred_scores.argmax()
        predicted_category_id = pred_labels[max_score_idx]

        print(f'Predicted category ID: {predicted_category_id}')  # 추가된 부분


        logger.info(f'Predicted category ID: {predicted_category_id}')

        csv_path = '/Users/seon/Desktop/Ict_FIN/info.csv'
        pill_info_csv = find_pill_info_from_csv2(predicted_category_id, csv_path)

        # Set the image path based on the predicted_category_id
        image_filename = f"{predicted_category_id}.png"
        image_full_path = f"/Users/seon/Desktop/Ict_FIN/ict_chungbuk/assets/data/{image_filename}"
        image_url = f"https://80d4-113-198-180-184.ngrok-free.app/images/{image_filename}"

        # Check if the image exists
        if not os.path.exists(image_full_path):
            logger.warning(f"Image not found: {image_full_path}")
            image_full_path = None  # Set to None if the image does not exist
        else:
            print(f"Image path: {image_full_path}")

   

        response_data = {
            'predicted_category_id': int(predicted_category_id),  # Ensure this is correct
            'prediction_score': float(pred_scores[max_score_idx]),
             # Add the predicted_category_id
            'product_name': pill_info_csv.get('제품명', 'Unknown') if pill_info_csv else 'Unknown',
            'manufacturer': pill_info_csv.get('제조/수입사', 'Unknown') if pill_info_csv else 'Unknown',
            'pill_code': pill_info_csv.get('품목기준코드', 'Unknown') if pill_info_csv else 'Unknown',
            'efficacy': pill_info_csv.get('이 약의 효능은 무엇입니까?', 'No information') if pill_info_csv else 'No information',
            'usage': pill_info_csv.get('이 약은 어떻게 사용합니까?', 'No information') if pill_info_csv else 'No information',
            'precautions_before_use': pill_info_csv.get('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?', 'No information') if pill_info_csv else 'No information',
            'usage_precautions': pill_info_csv.get('이 약의 사용상 주의사항은 무엇입니까?', 'No information') if pill_info_csv else 'No information',
            'drug_food_interactions': pill_info_csv.get('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?', 'No information') if pill_info_csv else 'No information',
            'side_effects': pill_info_csv.get('이 약은 어떤 이상반응이 나타날 수 있습니까?', 'No information') if pill_info_csv else 'No information',
            'storage_instructions': pill_info_csv.get('이 약은 어떻게 보관해야 합니까?', 'No information') if pill_info_csv else 'No information',
            'image_path': image_full_path  # Include the path to the image file
        }
    except Exception as e:
        logger.error(f'Error during prediction: {str(e)}')
        return JsonResponse({'error': f'Error during prediction: {str(e)}'}, status=500)
    finally:
        if os.path.exists(image_path):
            os.remove(image_path)

    logger.info('Prediction completed successfully')
    return JsonResponse(response_data, status=200)

import os
from django.http import HttpResponse
from django.conf import settings

def serve_image(request, image_filename):
    image_path = os.path.join(settings.MEDIA_ROOT, 'data', image_filename)  # 이미지 경로 설정

    if os.path.exists(image_path):
        with open(image_path, 'rb') as f:
            return HttpResponse(f.read(), content_type="image/png")  # 이미지 파일을 반환
    else:
        return HttpResponse(status=404)  # 이미지가 없을 때 404 에러 반환



from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from django.http import JsonResponse
from django.views import View
import json

from .models import Userlist, PillRecommendation  # UserList와 PillRecommendation 모델을 임포트합니다.
from django.http import JsonResponse
from django.views import View
import json
class RecommendPillView(View):
    def post(self, request):
        try:
            # Get the data from the request
            data = json.loads(request.body)
            family_member_name = data.get('family_member_name')
            user_id = data['user_id']
            pill_code = data['pill_code']
            pill_name = data['pill_name']
            confidence = data['confidence']
            efficacy = data['efficacy']
            manufacturer = data['manufacturer']
            usage = data['usage']
            precautions_before_use = data['precautions_before_use']
            usage_precautions = data['usage_precautions']
            drug_food_interactions = data['drug_food_interactions']
            side_effects = data['side_effects']
            storage_instructions = data['storage_instructions']
            pill_image = data['pill_image']
            pill_info = data['pill_info']
            predicted_category_id = data['predicted_category_id']  # 대괄호로 수정
            
            # Validate input
            if not user_id or not family_member_name or not pill_code or not pill_name:
                return JsonResponse({'message': 'Invalid input'}, status=400)

            # Get the User instance for the recommended user (가족을 선택)
            recommended_user = Userlist.objects.filter(nickname=family_member_name).first()
            if not recommended_user:
                return JsonResponse({'message': 'User not found'}, status=404)

            # Create a new PillRecommendation entry
            recommendation = PillRecommendation.objects.create(
                user=recommended_user,
                pill_code=pill_code,
                pill_name=pill_name,
                confidence=confidence,
                efficacy=efficacy,
                manufacturer=manufacturer,
                usage=usage,
                precautions_before_use=precautions_before_use,
                usage_precautions=usage_precautions,
                drug_food_interactions=drug_food_interactions,
                side_effects=side_effects,
                storage_instructions=storage_instructions,
                pill_image=pill_image,
                pill_info=pill_info,
                predicted_category_id=predicted_category_id, 

            )

            # Prepare the response data
            response_data = {
                'id': recommendation.id,
                'pill_code': recommendation.pill_code,
                'pill_name': recommendation.pill_name,
                'confidence': recommendation.confidence,
                'efficacy': recommendation.efficacy,
                'manufacturer': recommendation.manufacturer,
                'usage': recommendation.usage,
                'precautions_before_use': recommendation.precautions_before_use,
                'usage_precautions': recommendation.usage_precautions,
                'drug_food_interactions': recommendation.drug_food_interactions,
                'side_effects': recommendation.side_effects,
                'storage_instructions': recommendation.storage_instructions,
                'pill_image': recommendation.pill_image,
                'pill_info': recommendation.pill_info,
                'created_at': recommendation.created_at,
                'user_id': recommendation.user.id,
                'predicted_category_id': recommendation.predicted_category_id,
            }

            # Return success response with all pill details
            return JsonResponse({
                'message': 'Recommendation successful',
                'recommendation': response_data
            }, status=201)

        except Exception as e:
            return JsonResponse({'message': str(e)}, status=500)
from django.http import JsonResponse
from django.views import View
from .models import PillRecommendation

class RecommendationListView(View):
    def get(self, request, user_id):
        try:
            # Get recommendations for the given user_id
            recommendations = PillRecommendation.objects.filter(user_id=user_id)

            # Convert recommendations to JSON format
            recommendations_data = [
                {
                    'id': recommendation.id,
                    'pill_code': recommendation.pill_code,
                    'pill_name': recommendation.pill_name,
                    'confidence': recommendation.confidence,
                    'efficacy': recommendation.efficacy,
                    'manufacturer': recommendation.manufacturer,
                    'usage': recommendation.usage,
                    'precautions_before_use': recommendation.precautions_before_use,
                    'usage_precautions': recommendation.usage_precautions,
                    'drug_food_interactions': recommendation.drug_food_interactions,
                    'side_effects': recommendation.side_effects,
                    'storage_instructions': recommendation.storage_instructions,
                    'pill_image': recommendation.pill_image,
                    'pill_info': recommendation.pill_info,
                    'created_at': recommendation.created_at,
                    'user_id': recommendation.user.id,
                    'predicted_category_id': recommendation.predicted_category_id,
                }
                for recommendation in recommendations
            ]

            return JsonResponse({'recommendations': recommendations_data}, status=200)
        except Exception as e:
            return JsonResponse({'message': str(e)}, status=500)
