import 'package:chungbuk_ict/familylist.dart';
import 'package:chungbuk_ict/recommended.dart';
import 'package:flutter/material.dart';

import 'Change_Password.dart'; // 비밀번호 변경 페이지
import 'Membership_Withdrawal.dart'; // 회원탈퇴 페이지
import 'Family_Registration.dart'; // 가족 등록 페이지

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pill_information.dart'; // 알약 정보 페이지
import 'package:chungbuk_ict/search_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPage extends StatefulWidget {
  final String userId;

  const MyPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = '';
  late String _userId = widget.userId; // userId 할당

  @override
  void initState() {
    super.initState();
    _userId = widget.userId; // Initialize _userId here
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final response = await http.get(
        Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/user_info/$_userId'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      setState(() {
        _nickname = data['nickname'] ?? ''; // null 체크 및 기본값 설정
      });
      print(_nickname);
    } else {
      // 에러 처리
      print('Failed to load user info');
    }
  }

  void openPillInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchHistoryScreen(userId: widget.userId),
      ),
    );
  }

  void openFamilyList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyListScreen(userId: widget.userId), // 가족 목록 화면으로 이동
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set background color to white
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[50],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "안녕하세요.",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "$_nickname 님",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),

            // 검색 기록
            ListTile(
              title: Text("검색 기록"),
              trailing: Icon(Icons.chevron_right),
              onTap: openPillInformation, // Updated to call the correct function
            ),

            // 추천 받은 목록
            ListTile(
              title: Text("추천 받은 목록"), // 메뉴 제목
              trailing: Icon(Icons.chevron_right), // 화살표 아이콘
              onTap: () {
                // 추천 받은 목록 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendationScreen(userId: widget.userId), // 추천 목록으로 이동
                  ),
                );
              },
            ),

            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),

            // 비밀번호 변경
            ListTile(
              title: Text("비밀번호 변경"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 비밀번호 변경 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePW(userId: widget.userId)),
                );
              },
            ),

            // 가족 등록 하기
            ListTile(
              title: Text("가족 등록 하기"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 가족 등록하기 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyRegister(userId: widget.userId)), // Added Family Registration navigation
                );
              },
            ),

            // 가족 목록 보기
            ListTile(
              title: Text("가족 목록 보기"),
              trailing: Icon(Icons.chevron_right),
              onTap: openFamilyList, // 가족 목록 화면으로 이동
            ),

            Container(
              color: Colors.grey[300], // Thicker separator color
              height: 8, // Increase height to make it thicker
            ),

            // 회원탈퇴
            ListTile(
              title: Text("회원탈퇴"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // 회원탈퇴 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MembershipWithdrawScreen(userId: widget.userId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
