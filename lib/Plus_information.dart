import 'package:flutter/material.dart';

// '더보기' 버튼을 눌렀을 때 나타나는 상세 화면
class DetailedInfoScreen extends StatelessWidget {
  final String pillCode;
  final String pillName;
  final String confidence;
  final String userId;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;
  final String efficacy;
  final String manufacturer;
  final String predictedCategoryId;

  const DetailedInfoScreen({
    Key? key,
    required this.pillCode,
    required this.pillName,
    required this.confidence,
    required this.userId,
    required this.usage,
    required this.precautionsBeforeUse,
    required this.usagePrecautions,
    required this.drugFoodInteractions,
    required this.sideEffects,
    required this.storageInstructions,
    required this.efficacy,
    required this.manufacturer,
    required this.predictedCategoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약물 상세정보'),
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation for shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '제품명: $pillName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('품목기준코드: $pillCode'),
            Text('예측 확률: $confidence'),
            Text('효능: $efficacy'),
            Text('사용법: $usage'),
            Text('사용 시 주의사항: $precautionsBeforeUse'),
            Text('약물-음식 상호작용: $drugFoodInteractions'),
            Text('부작용: $sideEffects'),
            Text('보관 방법: $storageInstructions'),
            Text('제조사: $manufacturer'),
          ],
        ),
      ),
    );
  }
}
