import 'dart:convert';
import 'package:chungbuk_ict/first_alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homepage.dart';
import 'Find_Id_section.dart';
import 'Find_Password_section.dart';
import 'signup_section.dart';

class LoginSection extends StatefulWidget {
    
  const LoginSection({super.key});

  @override
  _LoginSectionState createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  //bool _showPassword = false; // 비밀번호 보이기 여부



void _login() async {
    final String id = _idController.text;
    final String password = _passwordController.text;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
      // 성공 시 페이지 이동
      return FirstAlarmSet(userId: id);
    }), (route) => false);
 if (id.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/login_view/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'id': id,
            'password': password,
          }),
        );
        if (response.statusCode == 200) {
          // 로그인 성공 시 처리
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
            // 성공 시 페이지 이동
            return TabbarFrame(userId: id);
          }), (route) => false);
        } else {
          // 로그인 실패 시 처리
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['error'] ?? '알 수 없는 오류가 발생했습니다.';
          print('Login error: $errorMessage');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("확인"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        // 오류 발생 시 처리
        print('Error during login: $e');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('로그인 중 오류가 발생했습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // ID 또는 비밀번호 누락 시 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text("ID와 비밀번호를 입력하세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
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
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: '아이디(이메일 아이디)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _login,
              child: Image.asset(
                'assets/img/login_button.png', // Use the correct path to your image
     // Adjust the width as needed
                fit: BoxFit.contain, // Ensure the image scales correctly
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindIDSection()),
                    );
                  },
                  child: const Text(
                    'ID 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindPasswordSection()),
                    );
                  },
                  child: const Text(
                    'PW 찾기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Text('|', style: TextStyle(color: Colors.black)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpSection()),
                    );
                  },
                  child: const Text(
                    '회원가입',
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

