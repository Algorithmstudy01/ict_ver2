import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Plus_information.dart';


class InformationScreen extends StatefulWidget {

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
  final String imageUrl;
  final String predictedCategoryId; // 이미지 URL 추가

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
    required this.predictedCategoryId, // 카테고리 아이디를 생성자에 추가
  }) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool isFavorite = false;
  late FlutterTts flutterTts;
  
Future<String> fetchImageUrl(String predictedCategoryId) async {
  final response = await http.get(Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/images/$predictedCategoryId.png'));

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

  await flutterTts.setSpeechRate(0.4); // 빠른 말하기 속도


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
      'predicted_category_id': widget.predictedCategoryId,  // categoryId 추가
    }),
  );

  if (response.statusCode == 201) {
    print('Favorite added successfully');
  } else if (response.statusCode == 409) {
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
  void dispose() {
    // TTS를 사용하지 않을 때 해제
    flutterTts.stop();
    super.dispose();
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

  void recommendPill() async {
    try {
      final familyMembers = await _fetchFamilyMembers();
      if (familyMembers.isEmpty) {
        _showNoFamilyDialog();
      } else {
        _showFamilyDialog(familyMembers);
      }
    } catch (e) {
      _showErrorDialog();
    }
  }void _showFamilyDialog(List<dynamic> familyMembers) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '추천',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: familyMembers.map<Widget>((member) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5), // 리스트 간격
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.purple,
                    size: 50, // 아이콘 크기를 30으로 설정
                  ),
                  title: Text(
                    member['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // 텍스트 색상
                    ),
                  ),
                  subtitle: Text(
                    '관계: ${member['relationship']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey, // 서브타이틀 색상
                    ),
                  ),
                  onTap: () {
                    // 선택한 가족에게 추천 기능을 구현
                    Navigator.of(context).pop();
                    _recommendToFamily(member['name']); // 추천 기능 호출
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                color: Colors.black, // 취소 버튼 색상
              ),
            ),
          ),
        ],
      );
    },
  );
}


  void _showNoFamilyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text('등록된 가족이 없습니다. 가족을 먼저 추가하세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text('가족 목록을 불러오는 데 실패했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

void _recommendToFamily(String familyMemberName) async {
  // Prepare the data to be sent in the request
  final recommendationData = {
    'user_id': widget.userId,  // B의 user ID
    'family_member_name': familyMemberName, // 추천받는 사람의 이름
    'pill_code': widget.pillCode, // 약 코드
    'pill_name': widget.pillName, // 약 이름
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
    'predicted_category_id': widget.predictedCategoryId, 
  };

  try {
    // Send the recommendation request to the Django backend
    final response = await http.post(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/recommend/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recommendationData),
    );

    // Handle the response
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body); // Parse the response
      print('추천이 성공적으로 전송되었습니다: ${responseData['recommendation']}');
      
      // 추천이 성공적으로 전송되었을 때 팝업 표시
      _showSuccessDialog();
    } else {
      print('추천 전송 실패: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('예외 발생: $e'); // Handle exceptions
  }
}

void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('성공'),
        content: Text('추천이 완료되었습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      );
    },
  );
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
            if (widget.predictedCategoryId.isNotEmpty)
              Center(
                child: GestureDetector(
                  child: Image.asset(
                    'assets/data/${widget.predictedCategoryId}.png',
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Icon(
                        Icons.healing,
                        size: MediaQuery.of(context).size.height * 0.09,
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
                  /*if (widget.pillCode.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('품목기준코드: ${widget.pillCode}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('품목기준코드: ${widget.pillCode}'),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(child: Text('예측된 카테고리 ID: ${widget.predictedCategoryId}\n', style: TextStyle(fontSize: 16))),
                      IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () => speak('예측된 카테고리 ID: ${widget.predictedCategoryId}'),
                      ),
                    ],
                  ),*/
                  if (widget.pillName.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '제품명 : \n${widget.pillName}\n',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold, // 글씨체를 굵게 설정
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제품명 ${widget.pillName}'),
                        ),
                      ],
                    ),
                 /* if (widget.confidence.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('예측 확률: ${widget.confidence}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('예측 확률: ${widget.confidence}'),
                        ),
                      ],
                    ),*/
                  if (widget.efficacy.isNotEmpty)
                    Row(
                          children: [
                            Expanded(
                              child: Text(
                                '효능 : \n${widget.efficacy}\n',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold, // 글씨체를 굵게 설정
                                ),
                              ),
                            ),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('효능 ${widget.efficacy}'),
                        ),
                      ],
                    ),
                  /*if (widget.manufacturer.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('제조/수입사: ${widget.manufacturer}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제조/수입사: ${widget.manufacturer}'),
                        ),
                      ],
                    ),*/
                  if (widget.usage.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '사용법 : \n${widget.usage}\n',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold, // 글씨체를 굵게 설정
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('사용법 ${widget.usage}'),
                        ),
                      ],
                    ),
                 /* if (widget.precautionsBeforeUse.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?\n${widget.precautionsBeforeUse}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까? ${widget.precautionsBeforeUse}'),
                        ),
                      ],
                    ),*/
                  /*if (widget.usagePrecautions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용할 때 주의해야 할 점은 무엇입니까?\n${widget.usagePrecautions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용할 때 주의해야 할 점은 무엇입니까? ${widget.usagePrecautions}'),
                        ),
                      ],
                    ),*/
                  /*if (widget.drugFoodInteractions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약과 음식의 상호작용은 무엇입니까?\n${widget.drugFoodInteractions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약과 음식의 상호작용은 무엇입니까? ${widget.drugFoodInteractions}'),
                        ),
                      ],
                    ),*/
                  /*if (widget.sideEffects.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 부작용은 무엇입니까?\n${widget.sideEffects}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 부작용은 무엇입니까? ${widget.sideEffects}'),
                        ),
                      ],
                    ),*/
                  /*if (widget.storageInstructions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 보관 방법은 무엇입니까?\n${widget.storageInstructions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 보관 방법은 무엇입니까? ${widget.storageInstructions}'),
                        ),
                      ],
                    ),*/
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼을 양쪽에 정렬
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // 버튼의 패딩 조정
                    textStyle: TextStyle(
                      fontSize: 20, // 텍스트 크기 조정
                    ),
                    backgroundColor: Color.fromARGB(255, 238, 229, 248), // 버튼 배경색 설정
                    foregroundColor: Colors.black, // 텍스트 색상 설정
                    elevation: 2, // 그림자 깊이 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // 모서리를 둥글게 하지 않음
                    ),
                  ),
                  onPressed: () {
                    recommendPill(); // 추천하기 함수 호출
                  },
                  child: Text('추천하기'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // 버튼의 패딩 조정
                    textStyle: TextStyle(
                      fontSize: 20, // 텍스트 크기 조정
                    ),
                    backgroundColor: Color.fromARGB(255, 238, 229, 248), // 버튼 배경색 설정
                    foregroundColor: Colors.black, // 텍스트 색상 설정
                    elevation: 2, // 그림자 깊이 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // 모서리를 둥글게 하지 않음
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                        builder: (context) => DetailedInfoScreen(
                        pillCode: widget.pillCode,
                        pillName: widget.pillName,
                        confidence: widget.confidence,
                        userId: widget.userId,
                        usage: widget.usage,
                        precautionsBeforeUse: widget.precautionsBeforeUse,
                        usagePrecautions: widget.usagePrecautions,
                        drugFoodInteractions: widget.drugFoodInteractions,
                        sideEffects: widget.sideEffects,
                        storageInstructions: widget.storageInstructions,
                        efficacy: widget.efficacy,
                        manufacturer: widget.manufacturer,
                        predictedCategoryId: widget.predictedCategoryId,
                        ),
                        ),
                    );
                  },
                  child: Text('더보기'),
                ),
              ],
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
  final String confidence; // Ensure this is nullable or provide a default value
  final String efficacy;
  final String manufacturer;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;

  final String predictedCategoryId; // Ensure this is nullable or provide a default value

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

    required this.predictedCategoryId,
  });

  factory PillInfo.fromJson(Map<String, dynamic> json) {
    return PillInfo(
      pillCode: json['pill_code'] as String? ?? '', // Default to empty string if null
      pillName: json['pill_name'] as String? ?? '',
      confidence: json['confidence']?.toString() ?? '', // Convert to string, default to empty if null
      efficacy: json['efficacy'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
      precautionsBeforeUse: json['precautions_before_use'] as String? ?? '',
      usagePrecautions: json['usage_precautions'] as String? ?? '',
      drugFoodInteractions: json['drug_food_interactions'] as String? ?? '',
      sideEffects: json['side_effects'] as String? ?? '',
      storageInstructions: json['storage_instructions'] as String? ?? '',
      predictedCategoryId: json['predicted_category_id']?.toString() ?? '', // Convert to string, default to empty if null
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
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      backgroundColor: Colors.white,
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
                            extractedText: '', 
                            imageUrl: '',
    
                            predictedCategoryId: pillInfo.predictedCategoryId, // Now available
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
