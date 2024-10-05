import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FamilyListScreen extends StatefulWidget {
  final String userId;

  const FamilyListScreen({Key? key, required this.userId}) : super(key: key);

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
        _familyMembersFuture = _fetchFamilyMembers();  // 삭제 후 목록 새로 고침
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가족 구성원이 삭제되었습니다.')),
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
          title: Text('삭제 확인'),
          content: Text('이 가족 구성원을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // 다이얼로그 닫기
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await _deleteFamilyMember(familyMemberName); // 삭제 요청
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가족 목록'),
        backgroundColor: Colors.white,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _familyMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('가족 목록을 불러오는 데 실패했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('등록된 가족이 없습니다.'));
          }

          final familyMembers = snapshot.data!;

          return ListView.builder(
            itemCount: familyMembers.length,
            itemBuilder: (context, index) {
              final familyMember = familyMembers[index];

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  title: Text(familyMember['name'] ?? '이름 없음'),
                 subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('관계: ${familyMember['relationship']}'), // 가족과의 관계 표시
                      Text('전화번호: ${familyMember['phone_number']}'), // 전화번호 표시
                      Text('주소: ${familyMember['address']}'), // 주소 표시
                    ],
                  ),
                  
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _confirmDelete(familyMember['name'] ?? ''); // 삭제 확인
                    },
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
