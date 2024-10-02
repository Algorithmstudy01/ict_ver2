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

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load family members');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가족 목록'),
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
            return Center(child: Text('Failed to load family members'));
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
                  title: Text(familyMember['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('관계: ${familyMember['relationship']}'),
                      Text('전화번호: ${familyMember['phone_number']}'),
                      Text('주소: ${familyMember['address']}'),
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