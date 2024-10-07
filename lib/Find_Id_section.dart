import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Find_Password_section.dart'; // 비밀번호 찾기 섹션 import
import 'login_section.dart'; // 로그인 섹션 import

class FindIDSection extends StatefulWidget {
  @override
  _FindIDSectionState createState() => _FindIDSectionState();
}

class _FindIDSectionState extends State<FindIDSection> {
  final TextEditingController _emailController = TextEditingController();
  String _resultMessage = ''; // 아이디 또는 오류 메시지를 저장

  Future<void> _findUserID() async {
    final String email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _resultMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    final url = 'https://80d4-113-198-180-184.ngrok-free.app/find_user_id/'; // Django 엔드포인트
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _resultMessage = '아이디: ${data['id']}'; // 가져온 아이디 표시
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
        title: Text('아이디 찾기'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginSection()),
            ); // 뒤로가기 버튼 눌렀을 때 LoginSection으로 이동
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '아이디(이메일 아이디)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _findUserID,
                child: Image.asset(
                  'assets/img/find_id.png', // 이미지 경로 수정 필요
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _resultMessage,
              style: TextStyle(
                color: _resultMessage.contains('아이디:') ? Colors.green : Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindPasswordSection()),
                    );
                  },
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginSection()),
                    );
                  },
                  child: Text(
                    '로그인',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}