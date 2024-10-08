import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RecommendationScreen extends StatefulWidget {
  final String userId;

  const RecommendationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List recommendations = []; // 추천 목록을 저장합니다.
  bool isLoading = true; // 로딩 상태
  FlutterTts flutterTts = FlutterTts(); // flutterTts 객체 생성

  @override
  void initState() {
    super.initState();
    fetchRecommendations(); // 초기화 시 추천 목록을 가져옵니다.
    initTts(); // TTS 초기화
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("ko-KR"); // 한국어 설정
    await flutterTts.setSpeechRate(0.4); // 말하는 속도 설정
  }

  Future<void> fetchRecommendations() async {
    final response = await http.get(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/recommendations/${widget.userId}/'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        recommendations = data['recommendations'];
        isLoading = false; // 로딩 중지
      });
    } else {
      setState(() {
        isLoading = false; // 오류가 발생해도 로딩 중지
      });
      print('추천 목록을 가져오는 중 오류 발생: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('추천 목록'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return Card( // 카드 형태로 디자인
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4, // 그림자 효과
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0), // 내용 패딩
                    title: Text(
                      recommendation['pill_name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      '효과: ${recommendation['efficacy']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Icon(Icons.chevron_right), // 오른쪽 화살표 아이콘
                    onTap: () {
                      // 상세 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendationDetailScreen(recommendation: recommendation),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}


class RecommendationDetailScreen extends StatefulWidget {
  final Map recommendation;

  const RecommendationDetailScreen({Key? key, required this.recommendation}) : super(key: key);

  @override
  _RecommendationDetailScreenState createState() => _RecommendationDetailScreenState();
}

class _RecommendationDetailScreenState extends State<RecommendationDetailScreen> {
  FlutterTts flutterTts = FlutterTts(); // flutterTts 객체 생성

  @override
  void initState() {
    super.initState();
    initTts(); // TTS 초기화
  }

Future<void> initTts() async {
  await flutterTts.setLanguage("ko-KR"); // 한국어 설정
  await flutterTts.setSpeechRate(0.6); // 빠른 말하기 속도
}


  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.recommendation['pill_name']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                child: Image.asset(
                  'assets/data/${widget.recommendation['predicted_category_id']}.png', // 이미지 파일 불러오기
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Icon(
                      Icons.healing,
                      size: MediaQuery.of(context).size.height * 0.09,
                      color: Colors.purple[200],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.recommendation['pill_code'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('품목기준코드: ${widget.recommendation['pill_code']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('품목기준코드: ${widget.recommendation['pill_code']}'), // 음성 출력
                        ),
                      ],
                    ),
                     Row(
                    children: [
                      Expanded(child: Text('예측된 카테고리 ID: ${widget.recommendation['predicted_category_id']}\n', style: TextStyle(fontSize: 16))),
                      IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () => speak('예측된 카테고리 ID: ${widget.recommendation['predicted_category_id']}'),
                      ),
                    ],
                  ),
                  if (widget.recommendation['pill_name'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('제품명: ${widget.recommendation['pill_name']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제품명: ${widget.recommendation['pill_name']}'),
                        ),
                      ],
                    ),
                     if (widget.recommendation['confidence'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('예측 확률: ${widget.recommendation['confidence']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('예측 확률: ${widget.recommendation['confidence']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['efficacy'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 효능은 무엇입니까?\n${widget.recommendation['efficacy']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 효능은 무엇입니까? ${widget.recommendation['efficacy']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['manufacturer'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('제조/수입사: ${widget.recommendation['manufacturer']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제조/수입사: ${widget.recommendation['manufacturer']}'),
                        ),
                      ],
                    ),
                    if (widget.recommendation['usage'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떻게 사용합니까?\n${widget.recommendation['usage']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떻게 사용합니까? ${widget.recommendation['usage']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['precautions_before_use'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?\n${widget.recommendation['precautions_before_use']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까? ${widget.recommendation['precautions_before_use']}'),
                        ),
                      ],
                    ),
                    if (widget.recommendation['usage_precautions'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용할 때 주의해야 할 점은 무엇입니까?\n${widget.recommendation['usage_precautions']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용할 때 주의해야 할 점은 무엇입니까? ${widget.recommendation['usage_precautions']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['drug_food_interactions'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약과 음식의 상호작용은 무엇입니까?\n${widget.recommendation['drug_food_interactions']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약과 음식의 상호작용은 무엇입니까? ${widget.recommendation['drug_food_interactions']}'),
                        ),
                      ],
                    ),if (widget.recommendation['side_effects'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 부작용은 무엇입니까?\n${widget.recommendation['side_effects']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 부작용은 무엇입니까? ${widget.recommendation['side_effects']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['storage_instructions'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 보관 방법은 무엇입니까?\n${widget.recommendation['storage_instructions']}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 보관 방법은 무엇입니까? ${widget.recommendation['storage_instructions']}'),
                        ),
                      ],
                    ),


                  // 나머지 정보들을 같은 방식으로 보여주고 TTS 제공
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop(); // TTS 중지
    super.dispose();
  }
}
