// import 'dart:convert';
// import 'package:chungbuk_ict/pill_information.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'find_pill.dart'; // Ensure this file has the necessary imports

// class SearchHistoryScreen extends StatefulWidget {
//   final String userId;

//   const SearchHistoryScreen({Key? key, required this.userId}) : super(key: key);

//   @override
//   _SearchHistoryScreenState createState() => _SearchHistoryScreenState();
// }

// class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
//   late Future<List<PillInfo>> _searchHistory;
  

//   @override
//   void initState() {
//     super.initState();
//     _searchHistory = _fetchSearchHistory();
//   }

//   Future<List<PillInfo>> _fetchSearchHistory() async {
//     final response = await http.get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/get_search_history/${widget.userId}'));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);

//       // Check if 'results' key is present and not null
//       if (data['results'] != null) {
//         final List<dynamic> results = data['results'];
//         return results.map((json) => PillInfo.fromJson(json)).toList();
//       } else {
//         // Handle case where 'results' key is null
//         return [];
//       }
//     } else {
//       throw Exception('Failed to load search history');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('검색 기록'),
//       ),
//       body: FutureBuilder<List<PillInfo>>(
//         future: _searchHistory,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('오류: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('저장된 검색 기록이 없습니다.'));
//           } else {
//             final searchHistory = snapshot.data!;

//             return ListView.builder(
//               itemCount: searchHistory.length,
//               itemBuilder: (context, index) {
//                 final pillInfo = searchHistory[index];

//                 return ListTile(
//                   title: Text(pillInfo.pillName),
//                   subtitle: Text(pillInfo.efficacy),
//                   onTap: () {
//                     Navigator.of(context).push(
//                      MaterialPageRoute(
//             builder: (context) => InformationScreen(
//               pillCode: pillInfo.pillCode,
//               pillName: pillInfo.pillName,
//               confidence: pillInfo.confidence,
//               userId: widget.userId,
//               usage: pillInfo.usage,
//               precautionsBeforeUse: pillInfo.precautionsBeforeUse,
//               usagePrecautions: pillInfo.usagePrecautions,
//               drugFoodInteractions: pillInfo.drugFoodInteractions,
//               sideEffects: pillInfo.sideEffects,
//               storageInstructions: pillInfo.storageInstructions,
//               efficacy: pillInfo.efficacy,
//               manufacturer: pillInfo.manufacturer,
//               extractedText: '',
//             ),
//           ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }


