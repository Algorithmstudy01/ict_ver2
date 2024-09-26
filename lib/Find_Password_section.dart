import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_section.dart'; // Import the Login section

class FindPasswordSection extends StatefulWidget {
  @override
  _FindPasswordSectionState createState() => _FindPasswordSectionState();
}

class _FindPasswordSectionState extends State<FindPasswordSection> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _resultMessage = ''; // This will hold the result message or password

  Future<void> _findPassword() async {
    final String id = _usernameController.text;
    final String email = _emailController.text;

    if (id.isEmpty || email.isEmpty) {
      setState(() {
        _resultMessage = '아이디와 이메일을 입력해주세요.';
      });
      return;
    }

    final url = 'https://80d4-113-198-180-184.ngrok-free.app/find_password/'; // Replace with your Django endpoint
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _resultMessage = '비밀번호: ${data['password']}'; // Display the retrieved password
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: '아이디',
                hintText: '아이디를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: '이메일을 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _findPassword, // Attach the password finding logic
                child: Image.asset(
                  'assets/img/find_pw.png', // Use the correct path to your image
                  width: 450, // Adjust the width as needed
                  fit: BoxFit.contain, // Ensure the image scales correctly
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _resultMessage, // Display the result message or password
                style: TextStyle(
                  color: _resultMessage.contains('비밀번호:') ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to Login section
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
            ),
          ],
        ),
      ),
    );
  }
}
