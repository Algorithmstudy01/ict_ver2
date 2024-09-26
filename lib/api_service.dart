import 'dart:convert';
import 'dart:io'; // Import dart:io for file handling
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getPrediction(File imageFile) async {
  final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/predict2/'); // 서버 URL
  
  // MultipartRequest 객체 생성
  final request = http.MultipartRequest('POST', url)
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  
  try {
    // 요청 보내기
    final response = await request.send();
    
    // 응답 상태 코드 확인
    if (response.statusCode == 200) {
      // 응답 스트림을 문자열로 변환
      final responseData = await response.stream.bytesToString();
      
      // JSON 데이터를 Map으로 디코딩
      final decodedData = json.decode(responseData);
      
      return decodedData;
    } else {
      // 실패 시 예외 처리
      throw Exception('Failed to get prediction: ${response.statusCode}');
    }
  } catch (e) {
    // 예외 발생 시 예외 메시지 출력
    throw Exception('Error: $e');
  }
}
