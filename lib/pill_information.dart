import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chungbuk_ict/BookMark.dart';
import 'package:chungbuk_ict/pill_information.dart';  // Import if necessary






class InformationScreen extends StatefulWidget {
  final String categoryId;
  // 기존 변수들
  final String pillCode;
  final String pillName;
  final String confidence;
  final String extractedText;
  final String userId;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;
  final String efficacy;
  final String manufacturer;
  final String imageUrl; // 이미지 URL 추가

  const InformationScreen({
    Key? key,
    required this.pillCode,
    required this.pillName,
    required this.confidence,
    required this.extractedText,
    required this.userId,
    required this.usage,
    required this.precautionsBeforeUse,
    required this.usagePrecautions,
    required this.drugFoodInteractions,
    required this.sideEffects,
    required this.storageInstructions,
    required this.efficacy,
    required this.manufacturer,
    required this.imageUrl,
    required this.categoryId, // 카테고리 아이디를 생성자에 추가
  }) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool isFavorite = false;
  late FlutterTts flutterTts;
  
Future<String> fetchImageUrl(String categoryId) async {
  final response = await http.get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/images/$categoryId.png'));

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}'); // 응답 내용을 출력합니다.

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    String imageUrl = jsonResponse['image_url']; // Ensure this key exists in your response
    return imageUrl; // Return the image URL as a String
  } else {
    throw Exception('Failed to load image');
  }
}




  @override
  void initState() {
    super.initState();
    _initTts();  // TTS 초기화 함수 호출
  }
Future<void> _initTts() async {
    flutterTts = FlutterTts();

    // TTS 엔진 초기화
    await flutterTts.awaitSpeakCompletion(true);
    
    // 언어 설정 (한국어 예시)
    var result = await flutterTts.setLanguage('ko-KR');
    if (result == 1) {
      print("언어 설정 성공");
    } else {
      print("선택한 언어가 지원되지 않습니다. 기본 언어로 설정합니다.");
    }

    // TTS가 초기화될 때 오류가 발생하면 로그 출력
    flutterTts.setErrorHandler((msg) {
      print("TTS 오류 발생: $msg");
    });
  }

  void _checkFavorite() async {
    final response = await http.get(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.appfavorites/check?user_id=${widget.userId}&pill_code=${widget.pillCode}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        isFavorite = data['is_favorite'];
      });
    } else {
      print('Failed to check favorite status');
    }
  }
void toggleFavorite() async {
  setState(() {
    isFavorite = !isFavorite;
  });

  if (isFavorite) {
    // Try to add to favorites
    await _addToFavorites();
  } else {
    // Try to remove from favorites
    await _removeFromFavorites();
  }
}

Future<void> _addToFavorites() async {
  final response = await http.post(
    Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/favorites/add/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': widget.userId,
      'pill_code': widget.pillCode,
      'pill_name': widget.pillName,
      'confidence': widget.confidence,
      'efficacy': widget.efficacy,
      'manufacturer': widget.manufacturer,
      'usage': widget.usage,
      'precautions_before_use': widget.precautionsBeforeUse,
      'usage_precautions': widget.usagePrecautions,
      'drug_food_interactions': widget.drugFoodInteractions,
      'side_effects': widget.sideEffects,
      'storage_instructions': widget.storageInstructions,
      'pill_image': '',
      'pill_info': '',
    }),
  );

  if (response.statusCode == 201) {
    print('Favorite added successfully');
  } else if (response.statusCode == 409) {
    // Handle the case where the favorite already exists
    print('Favorite already exists');
  } else {
    print('Failed to add favorite: ${response.statusCode} - ${response.body}');
  }
}

Future<void> _removeFromFavorites() async {
  final response = await http.post(
    Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/favorites/remove/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'pill_code': widget.pillCode,
      'user_id': widget.userId,
    }),
  );

  if (response.statusCode == 200) {
    print('Favorite removed successfully');
  } else {
    print('Failed to remove favorite: ${response.statusCode} - ${response.body}');
  }
}




  void speak(String text) async {
    await flutterTts.speak(text);
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FutureBuilder를 사용하여 비동기적으로 이미지 로드
//        if (widget.categoryId.isNotEmpty)
//   FutureBuilder<String>(
//   future: fetchImageUrl(widget.categoryId), // categoryId에 따른 이미지 URL을 비동기적으로 가져옴
//   builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Center(child: CircularProgressIndicator()); // 로딩 중
//     } else if (snapshot.hasError) {
//       return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
//     } else if (snapshot.hasData) {
//       String imageUrl = snapshot.data!; // 성공적으로 데이터가 로드됨
//       return Center(
//         child: Image.network(imageUrl, height: 200), // 이미지를 화면에 표시
//       );
//     } else {
//       return Center(child: Text('No image available')); // 이미지가 없을 때
//     }
//   },
// ),
if (widget.categoryId.isNotEmpty)
Center(
  child: GestureDetector(
    child: Image.asset(
      'assets/data/${widget.categoryId}.png',
      width: MediaQuery.of(context).size.width * 0.9,  // 화면 너비의 80%로 설정
      height: MediaQuery.of(context).size.height * 0.3,  // 화면 높이의 40%로 설정
      fit: BoxFit.contain,  // 비율을 유지하며 이미지 맞춤
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Icon(
               Icons.healing ,  // 병원 아이콘
              size: MediaQuery.of(context).size.height * 0.09,  // 아이콘 크기 설정
                    color: Colors.purple[200], 
    );
    },

    ),
  ),
),


            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.pillCode.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('품목기준코드: ${widget.pillCode}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('품목기준코드: ${widget.pillCode}'),
                        ),
                      ],
                    ),
                   // if (widget.categoryId.isNotEmpty)
//                    Row(
//   children: [
//     Expanded(child: Text('예측된 카테고리 ID: ${widget.categoryId}\n', style: TextStyle(fontSize: 16))),
//     IconButton(
//       icon: Icon(Icons.volume_up),
//       onPressed: () => speak('예측된 카테고리 ID: ${widget.categoryId}'),
//     ),
//   ],
// ),
 
                  if (widget.pillName.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('제품명: ${widget.pillName}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제품명: ${widget.pillName}'),
                        ),
                      ],
                    ),
                  if (widget.confidence.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('예측 확률: ${widget.confidence}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('예측 확률: ${widget.confidence}'),
                        ),
                      ],
                    ),
                  if (widget.efficacy.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 효능은 무엇입니까?\n${widget.efficacy}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 효능은 무엇입니까? ${widget.efficacy}'),
                        ),
                      ],
                    ),
                  if (widget.manufacturer.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('제조/수입사: ${widget.manufacturer}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제조/수입사: ${widget.manufacturer}'),
                        ),
                      ],
                    ),
                  if (widget.usage.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떻게 사용합니까?\n${widget.usage}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떻게 사용합니까? ${widget.usage}'),
                        ),
                      ],
                    ),
                  if (widget.precautionsBeforeUse.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?\n${widget.precautionsBeforeUse}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까? ${widget.precautionsBeforeUse}'),
                        ),
                      ],
                    ),
                  if (widget.usagePrecautions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 사용상 주의사항은 무엇입니까?\n${widget.usagePrecautions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 사용상 주의사항은 무엇입니까? ${widget.usagePrecautions}'),
                        ),
                      ],
                    ),
                  if (widget.drugFoodInteractions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?\n${widget.drugFoodInteractions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까? ${widget.drugFoodInteractions}'),
                        ),
                      ],
                    ),
                  if (widget.sideEffects.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떤 이상반응이 나타날 수 있습니까?\n${widget.sideEffects}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떤 이상반응이 나타날 수 있습니까? ${widget.sideEffects}'),
                        ),
                      ],
                    ),
                  if (widget.storageInstructions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떻게 보관해야 합니까?\n${widget.storageInstructions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떻게 보관해야 합니까? ${widget.storageInstructions}'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookmarkScreen(userId: widget.userId),
                  ),
                );
              },
              child: Text('View Favorites'),
            ),
          ],
        ),
      ),
    );
  }
}




class PillInfo {
  final String pillCode;
  final String pillName;
  final String confidence;
  final String efficacy;
  final String manufacturer;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;
  final String pillImage;
  final String pillInfo;
  final String categoryId; // Add this line

  PillInfo({
    required this.pillCode,
    required this.pillName,
    required this.confidence,
    required this.efficacy,
    required this.manufacturer,
    required this.usage,
    required this.precautionsBeforeUse,
    required this.usagePrecautions,
    required this.drugFoodInteractions,
    required this.sideEffects,
    required this.storageInstructions,
    required this.pillImage,
    required this.pillInfo,
     required this.categoryId,
  });

  factory PillInfo.fromJson(Map<String, dynamic> json) {
    return PillInfo(
      pillCode: json['pill_code'] ?? 'Unknown',
      pillName: json['pill_name'] ?? 'Unknown',
      confidence: json['confidence'] ?? 'Unknown',
      efficacy: json['efficacy'] ?? 'No information',
      manufacturer: json['manufacturer'] ?? 'No information',
      usage: json['usage'] ?? 'No information',
      precautionsBeforeUse: json['precautions_before_use'] ?? 'No information',
      usagePrecautions: json['usage_precautions'] ?? 'No information',
      drugFoodInteractions: json['drug_food_interactions'] ?? 'No information',
      sideEffects: json['side_effects'] ?? 'No information',
      storageInstructions: json['storage_instructions'] ?? 'No information',
      pillImage: json['pill_image'] ?? 'No information',
      pillInfo: json['pill_info'] ?? 'No information',
       categoryId: json['categoryId'] ?? 'Default Category', // Add this line
    
      
    );
  }
}

class SearchHistoryScreen extends StatefulWidget {
  final String userId;

  const SearchHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchHistoryScreenState createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  late Future<List<PillInfo>> _searchHistory;

  @override
  void initState() {
    super.initState();
    _searchHistory = _fetchSearchHistory();
  }

  Future<List<PillInfo>> _fetchSearchHistory() async {
    final response = await http.get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/get_search_history/${widget.userId}'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Check the raw response

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['results'] != null) {
        final List<dynamic> results = data['results'];
        return results.map((json) => PillInfo.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load search history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 기록'),
        backgroundColor: Colors.white, // Light purple color for AppBar
      ),
      body: FutureBuilder<List<PillInfo>>(
        future: _searchHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('저장된 검색 기록이 없습니다.'));
          } else {
            final searchHistory = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                final pillInfo = searchHistory[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    tileColor: Colors.purple[70], // Very light purple color for the tile
                    title: Text(
                      pillInfo.pillName.isNotEmpty ? pillInfo.pillName : 'No Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      pillInfo.efficacy.isNotEmpty ? pillInfo.efficacy : 'No Efficacy Information',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InformationScreen(
                            pillCode: pillInfo.pillCode,
                            pillName: pillInfo.pillName,
                            confidence: pillInfo.confidence,
                            userId: widget.userId,
                            usage: pillInfo.usage,
                            precautionsBeforeUse: pillInfo.precautionsBeforeUse,
                            usagePrecautions: pillInfo.usagePrecautions,
                            drugFoodInteractions: pillInfo.drugFoodInteractions,
                            sideEffects: pillInfo.sideEffects,
                            storageInstructions: pillInfo.storageInstructions,
                            efficacy: pillInfo.efficacy,
                            manufacturer: pillInfo.manufacturer,
                            extractedText: '', imageUrl: '',
                            categoryId: pillInfo.categoryId, // Now available
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

