import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OCRScreen(),
    );
  }
}

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  String _ocrResult = "OCR 결과가 여기에 표시됩니다.";

  // 서버로 이미지를 전송하고, OCR 결과를 받아서 화면에 표시
  Future<void> sendImageToServer(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/ocr/'));

    // 이미지 파일을 form-data로 추가
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);

      // OCR 결과 화면에 표시
      setState(() {
        _ocrResult = result['text'] ?? 'OCR 결과 없음';
      });
    } else {
      setState(() {
        _ocrResult = 'OCR 요청 실패: 상태 코드 ${response.statusCode}';
      });
    }
  }

  // 이미지 선택 및 서버로 전송
  Future<void> pickAndSendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      await sendImageToServer(imageFile);
    } else {
      setState(() {
        _ocrResult = '이미지 선택 취소됨';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // OCR 결과 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _ocrResult,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            ElevatedButton(
              onPressed: pickAndSendImage,
              child: const Text('이미지 선택 후 OCR 요청'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndSendImage,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
