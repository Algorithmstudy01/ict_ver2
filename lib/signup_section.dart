import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chungbuk_ict/user_api_service.dart';
import 'login_section.dart';  // Ensure you import the login section
import 'package:http/http.dart' as http;

class SignUpSection extends StatefulWidget {
  const SignUpSection({Key? key}) : super(key: key);

  @override
  _SignUpSectionState createState() => _SignUpSectionState();
}

class _SignUpSectionState extends State<SignUpSection> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _signUp() async {
    final String nickname = _nicknameController.text;
    final String id = _idController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String location = _locationController.text;
    final String email = _emailController.text;

    if (!_isValidEmail(email)) {
      _showErrorDialog('올바른 이메일 형식이 아닙니다.');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('비밀번호가 일치하지 않습니다.');
      return;
    }

    final response = await http.post(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/register/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nickname': nickname,
        'id': id,
        'password': password,
        'location': location,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      _showSuccessDialog();
    } else {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
      _showErrorDialog(responseBody['message'] ?? 'Unknown error');
    }
  }

  bool _isValidEmail(String email) {
    // 이메일 형식 확인하는 정규식
    final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원가입 완료'),
          content: Text('회원가입이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginSection()), // Navigate to login page
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.white,
        elevation: 4, // Add elevation for shadow
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5), // Set shadow color
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_nicknameController, '닉네임을 입력해주세요'),
            SizedBox(height: 20),
            _buildTextField(_idController, '아이디를 입력해주세요'),
            SizedBox(height: 20),
            _buildPasswordTextField(
              _passwordController,
              '비밀번호를 입력해주세요',
              _isPasswordVisible,
              () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            SizedBox(height: 20),
            _buildPasswordTextField(
              _confirmPasswordController,
              '비밀번호를 한번 더 입력해주세요',
              _isConfirmPasswordVisible,
              () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            SizedBox(height: 20),
            _buildTextField(_locationController, '거주 지역을 입력해주세요'),
            SizedBox(height: 20),
            _buildTextField(_emailController, '이메일을 입력해주세요'),
            SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _signUp,
                child: Image.asset(
                  'assets/img/signup_button.png', // Use the correct path to your image
                  width: 380, // Adjust the width as needed
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordTextField(
    TextEditingController controller,
    String labelText,
    bool isVisible,
    VoidCallback toggleVisibility,
  ) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}