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
          title: const Text('가족 정보 수정'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(labelText: '관계'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: '전화번호'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: '주소'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
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
              child: const Text('수정'),
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
        color: Colors.white, // 카드 배경을 흰색으로 설정
        borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 설정
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // 카드 모서리를 둥글게 설정
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 카드의 흰색 배경
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // 아래쪽 그림자 설정
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2), // 아래쪽으로만 그림자
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
               title: Text(
                familyMember['name'] ?? '이름 없음',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // 글꼴 굵기 설정
                  fontSize: 23, // 글씨 크기 설정
                  color: Colors.black, // 텍스트 색상 설정
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
              // 수정 및 삭제 버튼을 카드의 아래쪽 오른쪽에 배치
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8), // 오른쪽과 아래쪽 패딩 추가
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 버튼을 오른쪽으로 정렬
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
                    const SizedBox(width: 8), // 버튼 사이 간격 추가
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
              // 카드 하단에 회색선 추가
              const Divider(
                color: Colors.grey, // 회색선 색상
                thickness: 1, // 선 두께
                height: 1, // 선의 높이
              ),
            ],
          ),
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
