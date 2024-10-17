import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String imageUrl = '';

  Future<void> fetchPrediction() async {
    final response = await http.post(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/predict2/'),
      // 필요한 경우에 따라 이미지 파일을 포함한 Multipart 요청을 보낼 수 있습니다.
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        imageUrl = data['image_path']; // 서버에서 반환된 이미지 URL
      });
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPrediction(); // 화면이 처음 열릴 때 예측 결과 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Result'),
      ),
      body: Center(
        child: imageUrl.isEmpty
            ? const CircularProgressIndicator() // 이미지 로딩 중일 때 스피너 표시
            : Image.network(imageUrl), // 이미지 출력
      ),
    );
  }
}
