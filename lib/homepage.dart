import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'BookMark.dart';
import 'find_pill.dart';
import 'search_history_screen.dart';
import 'my_page.dart';
import 'NewAlarm/NewAlarm.dart';
import 'pill_information.dart';
import 'package:chungbuk_ict/recommended.dart';
import 'package:chungbuk_ict/PharmacyScreen.dart';
import 'package:chungbuk_ict/text_OCR.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yagum Yagum', // 앱의 제목
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TabbarFrame(userId: 'user111'), // 앱 실행 시 TabbarFrame으로 시작
    );
  }
}

class TabbarFrame extends StatelessWidget {
  final String userId;
  const TabbarFrame({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false, // 뒤로가기 버튼 비활성화
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 이미지와 텍스트를 왼쪽 정렬
              children: [
                Image.asset(
                  'assets/img/yagum3.png', // 로고 이미지 경로
                  height: 30, // 이미지 높이
                  width: MediaQuery.of(context).size.width * 0.3, // 반응형 너비 설정
                ),
                const SizedBox(width: 10), // 이미지와 텍스트 사이 간격
              ],
            ),
          ),
          bottomNavigationBar: TabBar(
            indicatorColor: Colors.white,
            labelStyle: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            indicatorWeight: 4,
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: "홈",
              ),
              Tab(
                icon: Icon(Icons.alarm),
                text: "알람",
              ),
              Tab(
                icon: Icon(Icons.person),
                text: "내정보",
              )
            ],
          ),
          body: TabBarView(
            children: [
              MyHomePage(userId: userId),
              const ExampleAlarmHomeScreen(),
              MyPage(userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _nickname = '';
  Map<String, dynamic> _pillInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchNickname();
  }

  Future<void> _fetchNickname() async {
    final response = await http.get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/user_info/${widget.userId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nickname = data['nickname'] ?? 'Unknown User';
      });
    } else {
      setState(() {
        _nickname = 'Unknown User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.03), // AppBar 추가로 높이 조정
              Column(
                children: [
                  Container(
                    width: size.width * 0.2,
                    height: size.width * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/img/user5.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.5,
                    height: size.height * 0.05,
                    child: Text(
                      _nickname,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * 0.07,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04), // nickname 아래의 여백
                  SizedBox(
                    width: size.width * 0.9,
                    child: Text(
                      '알약의 정보를 알고싶다면\n 아래 검색 기능을 이용해보세요!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black.withOpacity(0.9),
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold, // 굵은 글씨
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02), // 텍스트 아래 여백 조절
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: size.width * 0),
                    child: SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FindPill(userId: widget.userId),
                                ),
                              ),
                              icon: Image.asset('assets/img/find_pill.png'),
                              iconSize: size.width * 0.15,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookmarkScreen(userId: widget.userId),
                                ),
                              ),
                              icon: Image.asset('assets/img/favorites.png'),
                              iconSize: size.width * 0.15,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: size.width * 0.03),  // 위와의 간격을 맞추기 위한 마진
                    child: SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FindText(), // NaverMapApp 화면으로 이동
                                ),
                              ),
                              icon: Image.asset('assets/img/pharmacy.png'),
                              iconSize: size.width * 0.15,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecommendationScreen(userId: widget.userId),
                              ),
                            ),
                              icon: Image.asset('assets/img/recommend.png'),
                              iconSize: size.width * 0.15,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: size.width * 0.85,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 162, 228, 192),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.045,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: '💡 도움말\n\n',
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  fontSize: size.width * 0.06,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: '야금야금은 다양한 약을 꾸준히 복용해야 하는 분들에게 쉽고 정확하게 약을 복용할 수 있도록 도와주는 어플리케이션입니다.\n\n\n',
                            ),

                            TextSpan(
                              text: '- 이 어플은 참고용이며, 실제 복약 지침은 의료 전문가의 조언을 우선시하세요.\n'
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
