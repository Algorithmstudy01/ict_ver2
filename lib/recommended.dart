import 'dart:convert';
import 'package:chungbuk_ict/Plus_information.dart';
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
  List recommendations = [];
  bool isLoading = true;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.4);
  }

  Future<void> fetchRecommendations() async {
    final response = await http.get(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/recommendations/${widget.userId}/'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        recommendations = data['recommendations'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('추천 목록을 가져오는 중 오류 발생: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 목록'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      recommendation['pill_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      '효과: ${recommendation['efficacy']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
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
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.6);
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
          icon: const Icon(Icons.arrow_back),
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
                  'assets/data/${widget.recommendation['predicted_category_id']}.png',
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
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
                  if (widget.recommendation['pill_name'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('제품명: \n${widget.recommendation['pill_name']}\n', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => speak('제품명: ${widget.recommendation['pill_name']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['efficacy'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('효능: \n${widget.recommendation['efficacy']}\n', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => speak('효능: ${widget.recommendation['efficacy']}'),
                        ),
                      ],
                    ),
                  if (widget.recommendation['usage'] != null)
                    Row(
                      children: [
                        Expanded(child: Text('사용법: \n${widget.recommendation['usage']}\n', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => speak('사용법: ${widget.recommendation['usage']}'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // "더보기" 버튼 추가
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // 버튼의 패딩 조정
                textStyle: TextStyle(
                  fontSize: 20, // 텍스트 크기 조정
                ),
                backgroundColor: Color.fromARGB(255, 238, 229, 248), // 버튼 배경색 설정
                foregroundColor: Colors.black, // 텍스트 색상 설정
                elevation: 2, // 그림자 깊이 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 모서리를 둥글게 하지 않음
                ),
              ),
              onPressed: () {
              Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => DetailedInfoScreen(
      pillCode: widget.recommendation['pill_code']?.toString() ?? '', // Convert to String
      pillName: widget.recommendation['pill_name'] ?? '', // Use null-aware operator
      confidence: widget.recommendation['confidence']?.toString() ?? '', // Convert to String
      userId: widget.recommendation['user_id'] ?? '', // Use null-aware operator
      usage: widget.recommendation['usage'] ?? '', // Use null-aware operator
      precautionsBeforeUse: widget.recommendation['precautions_before_use'] ?? '', // Use null-aware operator
      usagePrecautions: widget.recommendation['usage_precautions'] ?? '', // Use null-aware operator
      drugFoodInteractions: widget.recommendation['drug_food_interactions'] ?? '', // Use null-aware operator
      sideEffects: widget.recommendation['side_effects'] ?? '', // Use null-aware operator
      storageInstructions: widget.recommendation['storage_instructions'] ?? '', // Use null-aware operator
      efficacy: widget.recommendation['efficacy'] ?? '', // Use null-aware operator
      manufacturer: widget.recommendation['manufacturer'] ?? '', // Use null-aware operator
      predictedCategoryId: widget.recommendation['predicted_category_id']?.toString() ?? '', // Convert to String
    ),
  ),
);

              },
              child: Text('더보기'),
            ),
          ],
        ),
      ),
    );
  }
}
