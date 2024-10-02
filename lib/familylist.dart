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
  Future<List<dynamic>> _fetchFamilyMembers() async {
    final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/getfamilymembers/${widget.userId}/');
    final response = await http.get(url);

    // Print the raw response body as bytes
    print('Raw response body: ${response.bodyBytes}');

    if (response.statusCode == 200) {
      // Try decoding with utf-8 if necessary
      try {
        return json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('가족 목록을 불러오는 데 실패했습니다.');
      }
    } else {
      throw Exception('가족 목록을 불러오는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가족 목록'), // 한국어로 제목 표시
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchFamilyMembers(),
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
                  title: Text(familyMember['name']), // 가족의 이름 표시
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('관계: ${familyMember['relationship']}'), // 가족과의 관계 표시
                      Text('전화번호: ${familyMember['phone_number']}'), // 전화번호 표시
                      Text('주소: ${familyMember['address']}'), // 주소 표시
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
