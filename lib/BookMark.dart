import 'package:chungbuk_ict/pill_information.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Add this import for the InformationScreen

class BookmarkScreen extends StatefulWidget {
  final String userId;

  const BookmarkScreen({super.key, required this.userId});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, String>>>? _favoritesFuture;
  List<Map<String, String>> _allFavorites = [];
  List<Map<String, String>> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = fetchFavorites(widget.userId);
    _searchController.addListener(_filterFavorites);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, String>>> fetchFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/favorites/$userId/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Map<String, String>> favorites = data.map<Map<String, String>>((item) => {
        'pillCode': item['pill_code'] as String,
        'pillName': item['pill_name'] as String,
        'confidence': item['confidence'] as String,
        'efficacy': item['efficacy'] as String,
        'manufacturer': item['manufacturer'] as String,
        'usage': item['usage'] as String,
        'precautionsBeforeUse': item['precautions_before_use'] as String,
        'usagePrecautions': item['usage_precautions'] as String,
        'drugFoodInteractions': item['drug_food_interactions'] as String,
        'sideEffects': item['side_effects'] as String,
        'storageInstructions': item['storage_instructions'] as String,
        'pillImage': item['pill_image'] as String,
        'pillInfo': item['pill_info'] as String? ?? '',
        'predicted_category_id': item['predicted_category_id']?.toString() ?? '',  // null 및 타입 변환 대비



      }).toList();
      setState(() {
        _allFavorites = favorites;
        _filteredFavorites = favorites;
      });
      return favorites;
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  void _filterFavorites() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFavorites = _allFavorites.where((item) {
        final pillName = item['pillName']!.toLowerCase();
        return pillName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('즐겨찾기 목록'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No favorites added yet.'));
                  } else {
                    return ListView.builder(
                      itemCount: _filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final favorite = _filteredFavorites[index];
                        return _buildBookmarkItem(favorite);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.black),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '검색',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _filterFavorites();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildBookmarkItem(Map<String, String> favorite) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InformationScreen(
              pillCode: favorite['pillCode']!,
              pillName: favorite['pillName']!,
              confidence: favorite['confidence']!,
              userId: widget.userId,
              usage: favorite['usage']!,
              precautionsBeforeUse: favorite['precautionsBeforeUse']!,
              usagePrecautions: favorite['usagePrecautions']!,
              drugFoodInteractions: favorite['drugFoodInteractions']!,
              sideEffects: favorite['sideEffects']!,
              storageInstructions: favorite['storageInstructions']!,
              efficacy: favorite['efficacy']!,
              manufacturer: favorite['manufacturer']!,
              extractedText: favorite['pillInfo']!,
              imageUrl: '',
              predictedCategoryId: favorite['predicted_category_id']!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.grey.withOpacity(0.2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                favorite['pillImage']!,
                width: 80,  // 이미지의 가로 길이를 넓게 조정
                height: 80,  // 이미지의 세로 길이를 넓게 조정
                fit: BoxFit.contain,  // 이미지가 박스에 모두 들어오도록 설정
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/data/${favorite['predicted_category_id']}.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,  // 에러 이미지도 동일하게 적용
                ),
              ),
            ),
            const SizedBox(width: 16),  // 이미지와 텍스트 사이 간격
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '약 이름 : ${favorite['pillName']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '효과 : ${favorite['efficacy']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),  // 카테고리 간격
                  Text(
                    '카테고리 ID: ${favorite['predicted_category_id']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () async {
                await _removeFavoriteFromServer(favorite['pillCode']!);
                setState(() {
                  _favoritesFuture = fetchFavorites(widget.userId);
                });
              },
            ),
          ],
        ),
      ),
    );
  }




Future<void> _removeFavoriteFromServer(String pillCode) async {
  final response = await http.post(
    Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/favorites/remove/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'pill_code': pillCode,
      'user_id': widget.userId,
    }),
  );

  if (response.statusCode == 200) {
    print('Favorite removed successfully');
  } else {
    print('Failed to remove favorite');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}
}