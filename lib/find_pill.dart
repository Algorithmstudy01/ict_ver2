import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

  const FindPill({Key? key, required this.userId}) : super(key: key);

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
        ResolutionPreset.max,
        enableAudio: false,
      );

    }
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
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

    if  (file != null) {
      ImageProperties properties = await FlutterNativeImage. getImageProperties (file.path);
      var cropSize =  min (properties.width!, properties.height!);
      int offsetX = (properties.width! - cropSize) ~/2;
      int offsetY = (properties.height! - cropSize) ~/2;
      imageFile = await FlutterNativeImage. cropImage (file.path, offsetX, offsetY, cropSize, cropSize);

      if  (imageFile != null)
        print ( "Good" );
    }  else  {
      print ( "Error" );
    }

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
      _pillInfo = {};
      _isLoading = true;
    });

    // 선택한 이미지를 서버로 업로드
    await _uploadImage(File(pickedFile.path));
  }
}




  Future<void> _startSearch() async {
    if (_image != null) {
      setState(() {
        _isLoading = true;
      });
      await _uploadImage(File(_image!.path));
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

      // Check if the decodedData contains the expected keys
      if (decodedData.isEmpty || !decodedData.containsKey('pill_code')) {
        _showErrorDialog('사진을 다시 촬영해주세요.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      int predictedCategoryId = decodedData['predicted_category_id'] ?? 0;
if (predictedCategoryId == 0) {
    _showErrorDialog('예상 범주 ID를 찾을 수 없습니다.'); // 적절한 오류 메시지 출력
    return;
}

      // Setting the state with the decoded data
      setState(() {
        _pillInfo = decodedData;
        _isLoading = false;
      });

      // Create PillInfo instance
      final pillInfo = PillInfo.fromJson(_pillInfo);
      await _saveSearchHistory(pillInfo);

      // Navigate to the InformationScreen with extracted data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InformationScreen(
            pillCode: _pillInfo['pill_code'] ?? 'Unknown',
            pillName: _pillInfo['product_name'] ?? 'Unknown',
            confidence: _pillInfo['prediction_score']?.toString() ?? 'Unknown',
            userId: widget.userId,
            usage: _pillInfo['usage'] ?? 'No information',
            precautionsBeforeUse: _pillInfo['precautions_before_use'] ?? 'No information',
            usagePrecautions: _pillInfo['usage_precautions'] ?? 'No information',
            drugFoodInteractions: _pillInfo['drug_food_interactions'] ?? 'No information',
            sideEffects: _pillInfo['side_effects'] ?? 'No information',
            storageInstructions: _pillInfo['storage_instructions'] ?? 'No information',
            efficacy: _pillInfo['efficacy'] ?? 'No information',
            manufacturer: _pillInfo['manufacturer'] ?? 'No information',
            imageUrl: _pillInfo['image_url'] ?? '', // 이미지 URL 추가
            extractedText: '',
            // categoryId: _pillInfo['category_id'] ?? 'No information',
            predictedCategoryId: predictedCategoryId.toString(), // 이 부분이 중요 // Ensure categoryId is included
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
          title: Text('오류'),
          content: Text(message),
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
  void dispose() {
    controller.dispose();
    super.dispose();
  }@override
Widget build(BuildContext context) {
  super.build(context);
  final Size size = MediaQuery.of(context).size;

 return Scaffold(
  appBar: AppBar(
    title: Text('알약 검색'),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: size.width * 0.85,
                  height: size.height * 0.06,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                    '알약 촬영하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.height * 0.03,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                      width: size.width * 0.85,
                      height: size.height * 0.09,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child:Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '정확한 알약 확인을 위해 사진을 준비해 주세요.\n아래의 ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.02,
                                fontFamily: 'Manrope',

                              ),
                            ),
                            TextSpan(
                              text: '촬영하기',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.021,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.bold,

                              ),
                            ),
                            TextSpan(
                              text: ' 버튼을 눌러 사진을 찍어주세요.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * 0.02,
                                fontFamily: 'Manrope',

                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: size.height * 0.4,
                        height: size.height * 0.4,
                        child: _isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10),
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
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child:Text(
                        '사진을 촬영, 등록하면, 위의 그림과 같이 텍스트를 \n인식하여 자동으로 알약의 정보를 불러옵니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF4F4F4F),
                          fontSize: size.height * 0.02,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),),
                  ],
                ),
                Column(
                  children: [
                    Column(
                      children: [
                        /*GestureDetector(
                          onTap: controller.value.isInitialized ? _takePicture : null,
                          child: Image.asset(
                            'assets/img/camera.png',
                            width: size.width * 0.7,
                            height: size.height * 0.05,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: size.width * 0.038),
                        GestureDetector(
                          onTap: _startSearch,
                          child: Image.asset(
                            'assets/img/search.png',
                            width: size.width * 0.7,
                            height: size.height * 0.05,
                            fit: BoxFit.contain,
                          ),
                        ),*/
                        Container(
                            margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                          width: size.width * 0.7,
                          height: size.height * 0.06,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: ElevatedButton(
                                onPressed: _image == null ? _takePicture : _startSearch,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _image == null ? Color(0xffC22AF8) : Color(0xff852C83),
                                  shape: BeveledRectangleBorder(),
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
                            });
                          }
                        },
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                          _image == null ? '갤러리에서 사진 가져오기' : '다른 사진 등록하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF383838),
                            fontSize: size.height * 0.02,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),),
                    ),),
                  ],
                ),
              ],
            ),
          ),

      ),),
    );

}


  @override
  bool get wantKeepAlive => true;
}





class ImageUploadScreen extends StatefulWidget {
  final String userId;

  const ImageUploadScreen({Key? key, required this.userId}) : super(key: key);

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
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
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
        title: Text('이미지 업로드'),
      ),
      body: Center(
        child: _isLoading ? CircularProgressIndicator() : Text('이미지 업로드 화면'),
      ),
    );
  }
}
