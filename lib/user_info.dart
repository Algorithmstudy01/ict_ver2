// import 'package:chungbuk_ict/my_page.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class UserInfo extends StatefulWidget {
//   final String username;

//   const UserInfo({Key? key, required this.username}) : super(key: key);

//   @override
//   State<UserInfo> createState() => _UserInfoState();
// }

// class _UserInfoState extends State<UserInfo> {
//   late final TextEditingController _nicknameController =
//       TextEditingController();
//   late final TextEditingController _idController = TextEditingController();
//   late final TextEditingController _locationController =
//       TextEditingController();
//   late final TextEditingController _emailController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserInfo();
//   }

//   void _fetchUserInfo() async {
//     final response = await http
//         .get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/user_info/${widget.username}'));
//     if (response.statusCode == 200) {
//       final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
//       setState(() {
//         _nicknameController.text = data['nickname'] ?? ''; // null 체크 및 기본값 설정
//         _locationController.text = data['location'] ?? 'Unknown';
//         _emailController.text = data['email'] ?? '';
//         _idController.text = widget.username;
//       });
//     } else {
//       // 에러 처리
//       print('Failed to load user info');
//     }
//   }

 

//   void _updateUserInfo() async {
//     final String nickname = _nicknameController.text;
//     final String location = _locationController.text;
//     final String email = _emailController.text;

//     if (!isValidEmail(email)) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('이메일 형식 오류'),
//             content: Text('유효한 이메일을 입력하세요.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('확인'),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }

//     final Map<String, String> data = {
//       'username': widget.username,
//       'nickname': nickname,
//       'location': location,
//       'email': email,
//     };

//     final response = await http.post(
//       Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/update_user_info/'),
//       body: json.encode(data),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       // 회원정보 업데이트 성공
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('성공'),
//             content: Text('회원정보가 성공적으로 수정되었습니다.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => MyPage(username: widget.username)),
//                   );
//                 },
//                 child: Text('확인'),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       // 회원정보 업데이트 실패
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('오류'),
//             content: Text('회원정보를 업데이트하는 중 오류가 발생했습니다.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('확인'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   bool isValidEmail(String email) {
//     // 이메일 형식 검증 함수
//     // 여기에 필요한 이메일 형식을 정의하세요
//     return true; // 임시로 true 반환
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Color.fromARGB(255, 255, 255, 255),
//         title: Image.asset(
//           'image/boggleimg.png',
//           height: 28, // 이미지 높이 설정
//           fit: BoxFit.cover, // 이미지 fit 설정
//         ),
//         centerTitle: false,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 300,
//                 child: Text(
//                   '아이디',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.start,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               SizedBox(
//                 width: 300,
//                 child: TextField(
//                   controller: _idController,
//                   readOnly: true,
//                   decoration: const InputDecoration(
//                     filled: true,
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.all(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: 300,
//                 child: Text(
//                   '닉네임',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.start,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               SizedBox(
//                 width: 300,
//                 child: TextField(
//                   controller: _nicknameController,
//                   decoration: const InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.all(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: 300,
//                 child: Text(
//                   '지역',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.start,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               SizedBox(
//                 width: 300,
//                 child: TextField(
//                   controller: _locationController,
//                   decoration: const InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.all(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: 300,
//                 child: Text(
//                   '이메일',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.start,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               SizedBox(
//                 width: 300,
//                 child: TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.all(8),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: 300,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFC42AFA),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: _updateUserInfo,
//                   child: const Text('회원정보 수정'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
     
//     );
//   }
// }
