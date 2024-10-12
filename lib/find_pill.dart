import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chungbuk_ict/low_prediction.dart';
import 'package:chungbuk_ict/pill_information.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_image/flutter_native_image.dart';


import 'Camera.dart';
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
  final String predictedCategoryId;

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

  Map<String, dynamic> toJson() {
    return {
      'pillCode': pillCode,
      'pillName': pillName,
      'confidence': confidence,
      'usage': usage,
      'precautionsBeforeUse': precautionsBeforeUse,
      'usagePrecautions': usagePrecautions,
      'drugFoodInteractions': drugFoodInteractions,
      'sideEffects': sideEffects,
      'storageInstructions': storageInstructions,
      'efficacy': efficacy,
      'manufacturer': manufacturer,
    };
  }

  factory PillInfo.fromJson(Map<String, dynamic> json) {
    return PillInfo(
      pillCode: json['pillCode'] ?? 'Unknown',
      pillName: json['pillName'] ?? 'Unknown',
      confidence: json['confidence'] ?? 'Unknown',
      usage: json['usage'] ?? 'No information',
      precautionsBeforeUse: json['precautionsBeforeUse'] ?? 'No information',
      usagePrecautions: json['usagePrecautions'] ?? 'No information',
      drugFoodInteractions: json['drugFoodInteractions'] ?? 'No information',
      sideEffects: json['sideEffects'] ?? 'No information',
      storageInstructions: json['storageInstructions'] ?? 'No information',
      efficacy: json['efficacy'] ?? 'No information',
      manufacturer: json['manufacturer'] ?? 'No information',
      predictedCategoryId: json['predictedCategoryId'] ?? 'Default Category', // Add this line
    );
  }
}

class FindPill extends StatefulWidget {
  final String userId;

  const FindPill({super.key, required this.userId});

  @override
  State<FindPill> createState() => _FindPillState();
}

class _FindPillState extends State<FindPill> with AutomaticKeepAliveClientMixin {
  late CameraController controller;
  late List<CameraDescription> _cameras;
  XFile? _image;
  File? imageFile;
  bool _isLoading = false;
  Map<String, dynamic> _pillInfo = {};

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pillInfo = {};
    _initializeCamera();
  }

  void _initializeCamera() {
    final Cameras = Provider.of<Camera>(context, listen: false);
    _cameras = Cameras.cameras;
    if (_cameras.isNotEmpty) {
      controller = CameraController(
        _cameras[0],
        ResolutionPreset.low,
        enableAudio: false,
      );

    }
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
         controller.setZoomLevel(7.0);
      });
    })
        .catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("CameraController Error : CameraAccessDenied");
            break;
          default:
            print("CameraController Error");
            break;
        }
      }
    });
  }

Future<void> _takePicture() async {

  if (!controller.value.isInitialized) {
    print("Camera controller is not initialized.");
    return;
  }
  try {
    final XFile file = await controller.takePicture();

    ImageProperties properties = await FlutterNativeImage. getImageProperties (file.path);
    var cropSize =  min (properties.width!, properties.height!);
    int offsetX = (properties.width! - cropSize) ~/2;
    int offsetY = (properties.height! - cropSize) ~/2;
    imageFile = await FlutterNativeImage. cropImage (file.path, offsetX, offsetY, cropSize, cropSize);

    if  (imageFile != null)
      print ( "Good" );
  
    setState(() {
      _image = file;
      _pillInfo = {};
      _isLoading = true; // 업로드가 시작될 때 로딩 상태를 표시
    });


    // 촬영한 이미지를 서버로 업로드
    await _uploadImage(imageFile!);
  } catch (e) {
    print('Error taking picture: $e');
    _showErrorDialog('이미지 촬영 중 오류가 발생했습니다.');
  }
  
}

Future<void> getImage(ImageSource imageSource) async {
  final XFile? pickedFile = await picker.pickImage(source: imageSource);
  if (pickedFile != null) {
    setState(() {
      _image = pickedFile;
      imageFile = File(pickedFile.path); // imageFile을 제대로 설정
      _pillInfo = {};
      _isLoading = true;
    });

    // 선택한 이미지를 서버로 업로드
    await _uploadImage(imageFile!);
    // await _uploadImage(File(pickedFile.path));
  }
}




  Future<void> _startSearch() async {
  if (_image != null) {
    setState(() {
      _isLoading = true;
    });
    await _uploadImage(File(_image!.path)); // Ensure _image is non-null
  } else {
    _showErrorDialog('이미지를 먼저 선택해 주세요.');
  }
}


Future<void> _uploadImage(File image) async {
  final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/predict2/');

  final request = http.MultipartRequest('POST', url)
    ..files.add(await http.MultipartFile.fromPath('image', image.path));

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);

      // 디버그: 응답 데이터 출력
      print(decodedData);

      if (decodedData == null || decodedData.containsKey('error')) {
  _showErrorDialog(decodedData?['error'] ?? 'Unknown error occurred');
  setState(() {
    _isLoading = false;
  });
  return;
}

int predictedCategoryId = decodedData['predicted_category_id'] ?? 0; // 이 부분에서 null일 경우

      double predictionScore = decodedData['prediction_score']?.toDouble() ?? 0.0;

      if (predictedCategoryId == 0) {
        _showErrorDialog('사진을 다시 촬영해주세요');
        setState(() {
          _isLoading = false;
        });
        return;
      }

       setState(() {
  _pillInfo = decodedData;
  print("Pill Info: $_pillInfo"); // Debugging line
  _isLoading = false;
});

      // 예측 확률에 따른 내비게이션
      if (predictionScore >= 0.6) {
        // Save search history only for high confidence
        final pillInfo = PillInfo.fromJson(decodedData);
        await _saveSearchHistory(pillInfo);

        // 바로 정보 화면으로 이동
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => InformationScreen(
      pillCode: _pillInfo['pill_code'] ?? 'Unknown',

      pillName: _pillInfo['product_name'] ?? 'Unknown',
      confidence: predictionScore.toString(),
      userId: widget.userId,
      usage: _pillInfo['usage'] ?? 'No information',
      precautionsBeforeUse: _pillInfo['precautions_before_use'] ?? 'No information',
      usagePrecautions: _pillInfo['usage_precautions'] ?? 'No information',
      drugFoodInteractions: _pillInfo['drug_food_interactions'] ?? 'No information',
      sideEffects: _pillInfo['side_effects'] ?? 'No information',
      storageInstructions: _pillInfo['storage_instructions'] ?? 'No information',
      efficacy: _pillInfo['efficacy'] ?? 'No information',
      manufacturer: _pillInfo['manufacturer'] ?? 'No information',
      imageUrl: _pillInfo['image_url'] ?? '',
      extractedText: '',
      predictedCategoryId: predictedCategoryId.toString(),
    ),
  ),
);

      } else if (predictionScore >= 0.1 && predictionScore < 0.6) {
        // 낮은 확신의 예측
        List<dynamic> pillOptions = decodedData['pill_options'] ?? [];
        List<double> predScores = decodedData['pred_scores']?.map<double>((score) => score.toDouble()).toList() ?? [];

        if (pillOptions.isNotEmpty) {
          // 선택지의 개수에 따라 처리
          if (pillOptions.length == 1) {
            var option = pillOptions[0]; // pillOptions의 첫 번째 항목
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => InformationScreen(
                  pillCode: option['pill_code'] ?? 'Unknown', 
                  pillName: option['product_name'] ?? 'Unknown',
                  confidence: (option['confidence'] is String 
                      ? double.parse(option['confidence']) 
                      : option['confidence']).toStringAsFixed(2),
                  extractedText: '',
                  userId: widget.userId,
                  usage: option['usage'] ?? 'No information',
                  precautionsBeforeUse: option['precautions_before_use'] ?? 'No information',
                  usagePrecautions: option['usage_precautions'] ?? 'No information',
                  drugFoodInteractions: option['drug_food_interactions'] ?? 'No information',
                  sideEffects: option['side_effects'] ?? 'No information',
                  storageInstructions: option['storage_instructions'] ?? 'No information',
                  efficacy: option['efficacy'] ?? 'No information',
                  manufacturer: option['manufacturer'] ?? 'Unknown',
                  imageUrl: option['image_url'] ?? '',
                  predictedCategoryId: option['predicted_category_id']?.toString() ?? 'Unknown',
                ),
              ),
            );
          } else {
            // 여러 개일 경우: 선택할 수 있도록 LowPrediction 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LowPrediction(
                  options: pillOptions,
                  userId: widget.userId,
                ),
              ),
            );
          }
        } else {
          _showErrorDialog('알약 옵션을 찾을 수 없습니다.');
        }
      } else {
        _showErrorDialog('예측 실패');
      }
    } else {
      _showErrorDialog('서버에서 오류가 발생했습니다. 상태 코드: ${response.statusCode}');
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e) {
    _showErrorDialog('업로드 중 오류가 발생했습니다: $e');
    setState(() {
      _isLoading = false;
    });
  }
  


    print("Image: $_image");
print("Image File: $imageFile");
}


Future<void> _saveSearchHistory(PillInfo pillInfo) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = widget.userId;

  final response = await http.post(
    Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/save_search_history/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'prediction_score': _pillInfo['prediction_score']?.toString() ?? 'Unknown',
      'product_name': _pillInfo['product_name'] ?? 'Unknown',
      'manufacturer': pillInfo.manufacturer,
      'pill_code': _pillInfo['pill_code'] ?? 'Unknown',
      'efficacy': pillInfo.efficacy,
      'usage': _pillInfo['usage'] ?? 'No information',
      'precautions_before_use': _pillInfo['precautions_before_use'] ?? 'No information',
      'usage_precautions': _pillInfo['usage_precautions'] ?? 'No information',
      'drug_food_interactions': _pillInfo['drug_food_interactions'] ?? 'No information',
      'side_effects': _pillInfo['side_effects'] ?? 'No information', // 수정된 부분
      'storage_instructions': _pillInfo['storage_instructions'] ?? 'No information',
      'predicted_category_id': _pillInfo['predicted_category_id'] ?? 'Unknown', // 추가된 부분,
      

    }),
  );

  if (response.statusCode == 201) {
    print('Search history saved successfully.');
  } else {
    print('Failed to save search history. Status code: ${response.statusCode}');
  }
}



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    
  super.build(context);
  final Size size = MediaQuery.of(context).size;


 return Scaffold(
   backgroundColor: Colors.white,
  appBar: AppBar(
    title: const Text('알약 검색'),
    backgroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
    foregroundColor: Colors.black,
    shadowColor: Colors.grey.withOpacity(0.5),
    automaticallyImplyLeading: true,  // 기본 뒤로가기 버튼 추가
  ),

    body: SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
      color: Colors.white, // AppBar 제외한 백그라운드 흰색 설정
     // AppBar 제외한 백그라운드 흰색 설정

         child: Center(
        
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                
                Column(
                  children: [
                     
                    Padding(
                      padding: EdgeInsets.only(top: size.height*0.1),
                      child: SizedBox(
                        width: size.height * 0.4,
                        height: size.height * 0.4,
                        child: _isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 10),
                                  Text(
                                    '알약 검색 중입니다...',
                                    style: TextStyle(
                                      fontSize: size.width * 0.038,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )
                            : (_image != null
                                ? Image.file(
                                    imageFile!,
                                    fit: BoxFit.contain,
                                  ) 
                            
                                : (controller.value.isInitialized
                                    ? AspectRatio(aspectRatio: 1,
                        child: ClipRect(
                          child: Transform.scale(
                            scale: controller.value.aspectRatio,
                              child: Center(
                                child: CameraPreview(controller),
                              ),
                          ),
                        ),)
                                    : Container(color: Colors.grey))),
                      ),
                    ),
                
                    SizedBox(
                      width: size.width * 0.9,
                      height: size.height * 0.09,
                    ),
                  ],
                ),
            
                Column(
                  children: [
                       Column(
                      children: [
                    //  GestureDetector(
                    //   onTap: controller.value.isInitialized ? _takePicture : null,
                    //   child: Image.asset(
                    //     'assets/img/camera.png',
                    //     width: size.width * 0.7,
                    //         height: size.height * 0.05,
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                    // SizedBox(height: size.width * 0.038),
                    // GestureDetector(
                    //   onTap: _startSearch,
                    //   child: Image.asset(
                    //     'assets/img/search.png',
                    //     width: size.width * 0.7,
                    //         height: size.height * 0.05,
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                    Container(
                            margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                          width: size.width * 0.7,
                          height: size.height * 0.06,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: ElevatedButton(
                                onPressed: _image == null ? _takePicture : _startSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _image == null ? const Color(0xffC22AF8) : const Color(0xff852C83),
                                  shape: const BeveledRectangleBorder(),
                                  minimumSize: Size(size.width * 0.7, size.height * 0.06),
                                ),
                                child: Text(
                                  _image == null ? '촬영하기': '검색하기',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.height * 0.025
                                  ),
                                )),
                          )
                        )
                      ],
                    ),
                    SizedBox(
                      width: size.width * 0.7,
                      height: size.height * 0.06,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: TextButton(
                        onPressed: () {
                          if (_image == null) {
                            getImage(ImageSource.gallery);
                          } else {
                            setState(() {
                              _image = null; // Clear the current image
                              imageFile = null;
                            });
                          }
                        },
                        child: Text(
                          _image == null ? '갤러리에서 사진 가져오기' : '다른 사진 등록하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF383838),
                            fontSize: size.width * 0.038,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),),
                    ),
                  ],
                ),
              ],
            ),
          ),

      ),
    ),
 );

    

}
  @override
  bool get wantKeepAlive => true;
}





class ImageUploadScreen extends StatefulWidget {
  final String userId;

  const ImageUploadScreen({super.key, required this.userId});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  bool _isLoading = false;
  late Map<String, dynamic> _pillInfo;
Future<void> _uploadImage(File image) async {
  final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/predict2/');

  final request = http.MultipartRequest('POST', url)
    ..files.add(await http.MultipartFile.fromPath('image', image.path));

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);

      if (decodedData.isEmpty || !decodedData.containsKey('pill_code')) {
        _showErrorDialog('사진을 다시 촬영해주세요.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _pillInfo = decodedData;
        _isLoading = false;
      });

      final pillInfo = PillInfo.fromJson(_pillInfo);
      await _saveSearchHistory(pillInfo);

      Navigator.push(
        context,
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
            extractedText: '', imageUrl:'' ,
            predictedCategoryId: pillInfo.predictedCategoryId, // Now available

          ),
        ),
      );
    } else {
      _showErrorDialog('서버에서 오류가 발생했습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e) {
    _showErrorDialog('업로드 중 오류가 발생했습니다.');
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSearchHistory(PillInfo pillInfo) async {
 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 업로드'),
      ),
      body: Center(
        child: _isLoading ? const CircularProgressIndicator() : const Text('이미지 업로드 화면'),
      ),
    );
  }
}
   