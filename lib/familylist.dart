import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FamilyListScreen extends StatefulWidget {
  final String userId;

  const FamilyListScreen({super.key, required this.userId});

  @override
  _FamilyListScreenState createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends State<FamilyListScreen> {
  late Future<List<dynamic>> _familyMembersFuture;

  @override
  void initState() {
    super.initState();
    _familyMembersFuture = _fetchFamilyMembers();
  }

  Future<List<dynamic>> _fetchFamilyMembers() async {
    final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/getfamilymembers/${widget.userId}/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('가족 목록을 불러오는 데 실패했습니다.');
    }
  }

  Future<void> _deleteFamilyMember(String familyMemberName) async {
    final response = await http.delete(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/deletefamilymember/$familyMemberName/'),
    );

    if (response.statusCode == 204) {
      setState(() {
        _familyMembersFuture = _fetchFamilyMembers(); // 삭제 후 목록 새로 고침
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가족 구성원이 삭제되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제에 실패했습니다: ${response.body}')),
      );
    }
  }

  Future<void> _confirmDelete(String familyMemberName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('이 가족 구성원을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteFamilyMember(familyMemberName);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editFamilyMember(
      String familyMemberName,
      String currentRelationship,
      String currentPhoneNumber,
      String currentAddress,
      ) async {
    TextEditingController nameController = TextEditingController(text: familyMemberName);
    TextEditingController relationshipController = TextEditingController(text: currentRelationship);
    TextEditingController phoneController = TextEditingController(text: currentPhoneNumber);
    TextEditingController addressController = TextEditingController(text: currentAddress);
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Set the background color to white
      title: const Text(
        '가족 정보 수정', // Title remains the same
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), // Bold and larger font
      ),
      content: SingleChildScrollView(
        child: Padding( // Added padding around content
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container( // Container for the first TextField
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Gray border
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                  color: Colors.white, // Background color
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: '이름을 입력하세요', // Hint text
                    border: InputBorder.none, // No border for a flat appearance
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust padding
                  ),
                ),
              ),
              const SizedBox(height: 10), // Space between text fields
              Container( // Container for the second TextField
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Gray border
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                  color: Colors.white, // Background color
                ),
                child: TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    hintText: '관계를 입력하세요', // Hint text
                    border: InputBorder.none, // No border for a flat appearance
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Adjust padding
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container( // Container for the third TextField
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Gray border
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                  color: Colors.white, // Background color
                ),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: '전화번호를 입력하세요', // Hint text
                    border: InputBorder.none, // No border for a flat appearance
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Adjust padding
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 10),
              Container( // Container for the fourth TextField
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Gray border
                  borderRadius: BorderRadius.circular(5), // Rounded corners
                  color: Colors.white, // Background color
                ),
                child: TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: '주소를 입력하세요', // Hint text
                    border: InputBorder.none, // No border for a flat appearance
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), // Adjust padding
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '취소',
            style: TextStyle(color: Colors.black), // Optionally color the cancel button
          ),
        ),
        TextButton(
          onPressed: () async {
            await _updateFamilyMember(
              nameController.text,
              relationshipController.text,
              phoneController.text,
              addressController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text(
            '수정',
            style: TextStyle(color: Colors.black), // Optionally color the update button
  ),
     ),
          ],
        );
      },
    );
  }



  Future<void> _updateFamilyMember(
      String name,
      String relationship,
      String phoneNumber,
      String address,
      ) async {
    final response = await http.put(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/updatefamilymember/${widget.userId}/$name/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'relationship': relationship,
        'phone_number': phoneNumber,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _familyMembersFuture = _fetchFamilyMembers(); // 업데이트 후 목록 새로 고침
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가족 정보가 성공적으로 수정되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정에 실패했습니다: ${response.body}')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('가족 목록'),
      backgroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      foregroundColor: Colors.black,
      shadowColor: Colors.grey.withOpacity(0.5),
    ),
    backgroundColor: Colors.white,
    body: FutureBuilder<List<dynamic>>(
      future: _familyMembersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('가족 목록을 불러오는 데 실패했습니다.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('등록된 가족이 없습니다.'));
        }

        final familyMembers = snapshot.data!;

        return ListView.builder(
          itemCount: familyMembers.length,
          itemBuilder: (context, index) {
            final familyMember = familyMembers[index];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 4), // 아래쪽으로 그림자를 더 강하게 설정
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        familyMember['name'] ?? '이름 없음',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Text('관계: ${familyMember['relationship']}'),
                          Text('전화번호: ${familyMember['phone_number']}'),
                          Text('주소: ${familyMember['address']}'),
                        ],
                      ),
                    ),
                    // 수정 및 삭제 버튼을 위로 올리기 위한 Padding 조정
                    Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 2), // 위로 올리기 위해 패딩을 추가
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _editFamilyMember(
                                familyMember['name'] ?? '',
                                familyMember['relationship'] ?? '',
                                familyMember['phone_number'] ?? '',
                                familyMember['address'] ?? '',
                              );
                            },
                            child: const Text(
                              '수정',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 0),
                          TextButton(
                            onPressed: () {
                              _confirmDelete(familyMember['name'] ?? '');
                            },
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
}
