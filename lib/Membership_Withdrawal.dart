import 'package:flutter/material.dart';
import 'my_page.dart';

class MembershipWithdrawScreen extends StatelessWidget {
  final String userId;

  const MembershipWithdrawScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원탈퇴'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 90),
            const Text(
              '여기서 활동하신 모든 기록들이 삭제됩니다.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '삭제된 이후 정보들은 다시 복구할 수 없습니다.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 160),
            const Text(
              '회원탈퇴를 하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '회원탈퇴를 하기 위해 비밀번호를 입력해 주세요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            PasswordField(hintText: '비밀번호를 입력해 주세요.'),
            const SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WithdrawCompleteScreen(userId: userId),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/img/out.png',
                  width: 450,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String hintText;

  const PasswordField({super.key, required this.hintText});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _toggleVisibility,
        ),
      ),
    );
  }
}

class WithdrawCompleteScreen extends StatelessWidget {
  final String userId;

  const WithdrawCompleteScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPage(userId: userId),
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '회원탈퇴가 정상적으로 처리되었습니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '그동안 이용해주셔서 감사합니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
