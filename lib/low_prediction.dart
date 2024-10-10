import 'package:flutter/material.dart';
import 'package:chungbuk_ict/pill_information.dart';

// 예측률이 낮을 때 발생하는 파일입니다.
class LowPrediction extends StatelessWidget {
  const LowPrediction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 화면 크기에 맞춘 반응형 디자인을 적용하기 위해 MediaQuery를 사용
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
        title: Center(
          child: Text(
            '검색한 이미지와 동일한 알약을 선택하세요',
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
            // 반복되는 알약 카드 리스트
            Expanded(
              child: ListView.builder(
                itemCount: 3, // 예시로 3개의 아이템을 생성
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationScreen(
                              pillCode: 'example_code', // 필수 매개변수에 실제 값을 전달
                              pillName: 'example_name',
                              confidence: '0.95',
                              extractedText: 'extracted text example',
                              userId: 'user123',
                              usage: 'example usage',
                              precautionsBeforeUse: 'example precautions before use',
                              usagePrecautions: 'example usage precautions',
                              drugFoodInteractions: 'example interactions',
                              sideEffects: 'example side effects',
                              storageInstructions: 'store in a cool place',
                              efficacy: 'example efficacy',
                              manufacturer: 'example manufacturer',
                              imageUrl: 'https://example.com/image.png', // 이미지 URL 예시
                              predictedCategoryId: '1', // 예측된 카테고리 ID 예시
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: Row(
                          children: [
                            // 이미지 영역
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                'assets/img/pill.png', // 알약 이미지 경로
                                width: size.width * 0.2,
                                height: size.width * 0.2,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // 텍스트 영역
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '약 이름',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
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
}
