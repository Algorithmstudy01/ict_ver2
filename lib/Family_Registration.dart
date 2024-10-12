import 'package:chungbuk_ict/my_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FamilyRegister extends StatefulWidget {
  final String userId;

  const FamilyRegister({super.key, required this.userId});

  @override
  State<FamilyRegister> createState() => _FamilyRegisterState();
}

class _FamilyRegisterState extends State<FamilyRegister> {
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController(); // 기존 관계 입력 필드 제거
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedRelationship; // 선택된 관계를 저장할 변수

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final name = _nameController.text;
    final phoneNumber = _phoneNumberController.text;
    final address = _addressController.text;

    final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/addfamilymember/${widget.userId}/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'relationship': _selectedRelationship, // 선택된 관계 사용
        'phone_number': phoneNumber,
        'address': address,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FamilyRegisterCompleteScreen(userId: widget.userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register family member: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가족등록'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/img/logo.jpg',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '이름 입력',
                hintText: '이름을 입력해 주세요.',
              ),
            ),
            const SizedBox(height: 20),
            // 관계 선택 드롭다운 메뉴
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '관계 선택',
              ),
              value: _selectedRelationship,
              items: ['자녀', '부모', '배우자','형제/자매']
                  .map((relationship) => DropdownMenuItem<String>(
                        value: relationship,
                        child: Text(relationship),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRelationship = value; // 선택된 관계 저장
                });
              },
              hint: const Text('관계를 선택해 주세요.'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '전화번호 입력',
                hintText: '전화번호를 입력해 주세요',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                labelText: '주소를 입력해 주세요',
                hintText: '주소를 입력해 주세요',
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _submitForm,
              child: Image.asset(
                'assets/img/fam.png', // Use the correct path to your image
                width: 350, // Adjust the width as needed
                fit: BoxFit.contain, // Ensure the image scales correctly
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FamilyRegisterCompleteScreen extends StatelessWidget {
  final String userId;

  const FamilyRegisterCompleteScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPage(userId: userId)),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text(
            '정상적으로 등록 되었습니다.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
