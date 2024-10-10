import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// Assuming this contains the PillInfo class
import 'package:chungbuk_ict/pill_information.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class LowPrediction extends StatefulWidget {
  final List<dynamic> options;
  final String userId;

  LowPrediction({Key? key, required this.options, required this.userId}) : super(key: key);

  @override
  _LowPredictionState createState() => _LowPredictionState();
}

class _LowPredictionState extends State<LowPrediction> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Center(
      child: Text(
        '알약검색', // 앱 바 제목 변경
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
  
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Text(
          '검색한 이미지와 동일한 알약을 선택하세요',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
             ),
             Divider(
          color: Colors.grey[300], // 회색 선 색상
          thickness: 1, // 선 두께
        ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        // 선택한 알약 정보를 InformationScreen으로 이동
                        final pillInfo = PillInfo2.fromJson(option); // 수정된 부분
                        print('Selected option: $option');

                        await _saveSearchHistory(pillInfo); // 함수 호출

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationScreen(
                              pillCode: option['pill_code'],
                              pillName: option['product_name'],
                              confidence: (option['confidence'] is String
                                  ? double.parse(option['confidence'])
                                  : option['confidence']).toStringAsFixed(2),
                              extractedText: '',
                              userId: widget.userId, // userId 사용
                              usage: option['usage'] ?? 'No information',
                              precautionsBeforeUse: option['precautions_before_use'] ?? 'No information',
                              usagePrecautions: option['usage_precautions'] ?? 'No information',
                              drugFoodInteractions: option['drug_food_interactions'] ?? 'No information',
                              sideEffects: option['side_effects'] ?? 'No information',
                              storageInstructions: option['storage_instructions'] ?? 'No information',
                              efficacy: option['efficacy'] ?? 'No information',
                              manufacturer: option['manufacturer'] ?? 'Unknown',
                              imageUrl: option['image_url'] ?? '',
                              predictedCategoryId: option['predicted_category_id']?.toString() ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white, // 카드 배경을 흰색으로 설정
                        shape: RoundedRectangleBorder(
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                'assets/data/${option['predicted_category_id'].toString()}.png', 
                                width: size.width * 0.2,
                                height: size.width * 0.2,
                                fit: BoxFit.contain,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  return Icon(
                                    Icons.healing,
                                    size: 50,
                                    color: Colors.purple[200],
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '약 이름: ${option['product_name']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '예측 확률: ${(option['confidence'] is String
                                          ? double.parse(option['confidence'])
                                          : option['confidence']).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSearchHistory(PillInfo2 pillInfo) async {
    // 디버깅: userId 출력
    final userId = widget.userId; // widget.userId를 사용
    print('Retrieved userId: $userId');

    if (userId.isEmpty) {
      print('User ID is empty. Unable to save search history.');
      return; // userId가 비어있는 경우 함수 종료
    }

    // 서버에 전송할 데이터 준비
    final body = jsonEncode({
  'user_id': userId,
  'prediction_score': pillInfo.confidence ?? 'Unknown',
  'product_name': pillInfo.pillName,
  'manufacturer': pillInfo.manufacturer ?? 'Unknown',
  'pill_code': pillInfo.pillCode,
  'efficacy': pillInfo.efficacy ?? 'No information',
  'usage': pillInfo.usage ?? 'No information',
  'precautions_before_use': pillInfo.precautionsBeforeUse ?? 'No information',
  'usage_precautions': pillInfo.usagePrecautions ?? 'No information',
  'drug_food_interactions': pillInfo.drugFoodInteractions ?? 'No information',
  'side_effects': pillInfo.sideEffects ?? 'No information',
  'storage_instructions': pillInfo.storageInstructions ?? 'No information',
  'predicted_category_id': pillInfo.predictedCategoryId ?? 'Unknown',

});


    // 각 필드 로그 출력
    print('user_id: $userId');
    print('pill_code: ${pillInfo.pillCode}');
    print('product_name: ${pillInfo.pillName}');
    print('confidence: ${pillInfo.confidence}');
    print('efficacy: ${pillInfo.efficacy}');
    print('manufacturer: ${pillInfo.manufacturer}');
    print('usage: ${pillInfo.usage}');
    print('precautions_before_use: ${pillInfo.precautionsBeforeUse}');
    print('usage_precautions: ${pillInfo.usagePrecautions}');
    print('drug_food_interactions: ${pillInfo.drugFoodInteractions}');
    print('side_effects: ${pillInfo.sideEffects}');
    print('storage_instructions: ${pillInfo.storageInstructions}');
    print('predicted_category_id: ${pillInfo.predictedCategoryId}');
    print('Request body: $body');

    // 서버에 요청 전송
    final response = await http.post(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/save_search_history/'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    // 응답 상태 코드 확인
    if (response.statusCode == 201) {
      print('Search history saved successfully.');
    } else {
      print('Failed to save search history. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}

// PillInfo2 클래스를 최상위 레벨에 정의
class PillInfo2 {
  final String pillCode;
  final String pillName; // product_name과 매핑
  final String manufacturer;
  final String efficacy;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;
  final double? confidence;
  final String predictedCategoryId;

  PillInfo2({
    required this.pillCode,
    required this.pillName,
    required this.manufacturer,
    required this.efficacy,
    required this.usage,
    required this.precautionsBeforeUse,
    required this.usagePrecautions,
    required this.drugFoodInteractions,
    required this.sideEffects,
    required this.storageInstructions,
    this.confidence,
    required this.predictedCategoryId,
  });

  factory PillInfo2.fromJson(Map<String, dynamic> json) {
    return PillInfo2(
      pillCode: json['pill_code'] ?? '',
      pillName: json['product_name'] ?? 'Unknown', // product_name을 pillName으로 가져옴
      manufacturer: json['manufacturer'] ?? 'Unknown',
      efficacy: json['efficacy'] ?? 'No information',
      usage: json['usage'] ?? 'No information',
      precautionsBeforeUse: json['precautions_before_use'] ?? 'No information',
      usagePrecautions: json['usage_precautions'] ?? 'No information',
      drugFoodInteractions: json['drug_food_interactions'] ?? 'No information',
      sideEffects: json['side_effects'] ?? 'No information',
      storageInstructions: json['storage_instructions'] ?? 'No information',
      confidence: json['confidence'] is String 
          ? double.tryParse(json['confidence']) 
          : json['confidence'], // String일 경우 변환
      predictedCategoryId: json['predicted_category_id']?.toString() ?? 'Unknown',
    );
  }
}
