import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Import the Login Screen
import 'my_page.dart'; // Import MyPage

class ChangePW extends StatefulWidget {
  final String userId;

  const ChangePW({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePW> createState() => _ChangePWState();
}

class _ChangePWState extends State<ChangePW> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _newPWController = TextEditingController();
  final TextEditingController _confirmPWController = TextEditingController();
  String _password = '';
  bool _showPassword = false; // Show/Hide new password
  bool _showConfirmPassword = false; // Show/Hide confirm password
  bool _showOriginPassword = false; // Show/Hide current password

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final response = await http.get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/user_info/${widget.userId}'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 decoding
      setState(() {
        _password = data['password'] ?? ''; // Null check and default value
      });
    } else {
      // Error handling
      print('Failed to load user info');
    }
  }

  void _updatePassword() {
    final String pw = _pwController.text;
    final String newPw = _newPWController.text;
    final String confirmPw = _confirmPWController.text;

    if (pw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      _showErrorDialog('비밀번호 입력 오류', '비밀번호를 모두 입력해 주세요.');
      return;
    }

    if (newPw != confirmPw) {
      _showErrorDialog('비밀번호 불일치', '새로운 비밀번호가 일치하지 않습니다.');
      return;
    }

    if (_password.isEmpty) {
      _showErrorDialog('비밀번호 오류', '비밀번호를 불러올 수 없습니다.');
      return;
    }

    if (_password != pw) {
      _showErrorDialog('비밀번호 오류', '현재 비밀번호가 일치하지 않습니다.');
      return;
    }

    _callChangePasswordAPI(newPw);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _callChangePasswordAPI(String newPassword) async {
    final Map<String, String> data = {
      'id': widget.userId,
      'current_password': _pwController.text,
      'new_password': newPassword,
    };

    final response = await http.post(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/change_password/'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 변경 성공'),
            content: Text('비밀번호가 성공적으로 변경되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyPage(userId: widget.userId)),
                  );
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      _showErrorDialog('비밀번호 변경 실패', '비밀번호 변경 중 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('비밀번호 변경'),
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation for shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align the column at the top
          children: [
            SizedBox(height: 90), // Add space at the top if needed
            _buildPasswordField(
              controller: _pwController,
              labelText: '현재 비밀번호',
              hintText: '현재 비밀번호를 입력해 주세요.',
              obscureText: !_showOriginPassword,
              onVisibilityToggle: () {
                setState(() {
                  _showOriginPassword = !_showOriginPassword;
                });
              },
              visibility: _showOriginPassword,
            ),
            SizedBox(height: 12), // Reduce the space between fields
            _buildPasswordField(
              controller: _newPWController,
              labelText: '새로운 비밀번호',
              hintText: '새로운 비밀번호를 입력해 주세요.',
              obscureText: !_showPassword,
              onVisibilityToggle: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              visibility: _showPassword,
            ),
            SizedBox(height: 12), // Reduce the space between fields
            _buildPasswordField(
              controller: _confirmPWController,
              labelText: '새로운 비밀번호 확인',
              hintText: '새로운 비밀번호를 한번 더 입력해 주세요.',
              obscureText: !_showConfirmPassword,
              onVisibilityToggle: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
              visibility: _showConfirmPassword,
            ),
            SizedBox(height: 32), // Reduce space before the button
  GestureDetector(
  onTap: _updatePassword, // 기존 onPressed 대신 onTap 사용
  child: Container(
    width: 450, // 가로 넓이 설정
    decoration: BoxDecoration(
      // 필요한 경우 추가 스타일 설정
    ),
    child: Image.asset(
      'assets/img/modify.png', // 이미지를 위한 경로 설정
      fit: BoxFit.contain,
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
    required bool visibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(
                visibility ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
        ),
      ],
    );
  }
}
