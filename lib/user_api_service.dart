import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _baseUrl = 'https://80d4-113-198-180-184.ngrok-free.app/';

  static Future<http.Response> registerUser(
  String id,
  String nickname,
  String password,
  String location,
  String email) async {
  final Map<String, String> requestData = {
    'id': id,
    'nickname': nickname,
    'password': password,
    'location': location,
    'email': email,
  };
  print('Request Data: $requestData');
  print('Request Data: ${jsonEncode(requestData)}'); // 디버깅 출력

  try {
    final response = await http.post(
      Uri.parse('${_baseUrl}register/'), // 엔드포인트 수정
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    ).timeout(const Duration(seconds: 10)); // 타임아웃 설정

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  } on http.ClientException catch (e) {
      print('ClientException: $e');
    rethrow;
  } on SocketException catch (e) {
      print('SocketException: $e');
    rethrow;
  } on TimeoutException catch (e) {
      print('TimeoutException: $e');
    rethrow;
  } catch (e) {
      print('Exception: $e');
    rethrow;
  }
}

}