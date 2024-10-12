import 'package:chungbuk_ict/login_section.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FindPasswordSection extends StatefulWidget {
  const FindPasswordSection({super.key});

  @override
  _FindPasswordSectionState createState() => _FindPasswordSectionState();
}

class _FindPasswordSectionState extends State<FindPasswordSection> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _resultMessage = ''; // 결과 메시지나 비밀번호를 저장하는 변수

  Future<void> _findPassword() async {
    final String id = _usernameController.text;
    final String email = _emailController.text;

    if (id.isEmpty || email.isEmpty) {
      setState(() {
        _resultMessage = '아이디와 이메일을 입력해주세요.';
      });
      return;
    }

    const url = 'https://80d4-113-198-180-184.ngrok-free.app/find_password/'; // Django 엔드포인트
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _resultMessage = '비밀번호: ${data['password']}'; // 가져온 비밀번호를 표시
      });
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        _resultMessage = data['message'] ?? '일치하는 사용자가 없습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('비밀번호 찾기'),
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation for shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginSection()), // 뒤로가기 버튼 누르면 로그인 섹션으로 이동
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '아이디',
                hintText: '아이디를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                hintText: '이메일을 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _findPassword, // 비밀번호 찾기 로직
                child: Image.asset(
                  'assets/img/find_pw.png', // 이미지 경로 수정 필요
                  width: 450, // 이미지 너비 조정
                  fit: BoxFit.contain, // 이미지 크기 조정
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _resultMessage, // 결과 메시지 또는 비밀번호 출력
                style: TextStyle(
                  color: _resultMessage.contains('비밀번호:') ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginSection()),
                  );
                },
                child: const Text(
                  '로그인',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
