import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:provider/provider.dart';

import 'Camera.dart';
import 'NewAlarm/edit_alarm.dart';


class FindText extends StatefulWidget {
  const FindText({Key? key}) : super(key: key);

  @override
  State<FindText> createState() => _FindTextState();
}

class _FindTextState extends State<FindText> with AutomaticKeepAliveClientMixin {
  late CameraController controller;
  late List<CameraDescription> _cameras;
  XFile? _image;
  File? imageFile;
  bool _isLoading = false;
  String _ocrResult = "OCR 결과가 여기에 표시됩니다.";

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final Cameras = Provider.of<Camera>(context, listen: false);
    _cameras = Cameras.cameras;
    if (_cameras.isNotEmpty) {
      controller = CameraController(
        _cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      try {
        await controller.initialize();
        if (!mounted) return;
        setState(() {
          controller.setZoomLevel(7.0);
        });
      } catch (e) {
        print("CameraController Error: $e");
      }
    }
  }

  Future<void> _takePicture() async {
    if (!controller.value.isInitialized) {
      print("Camera controller is not initialized.");
      return;
    }
    try {
      final XFile file = await controller.takePicture();
      ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
      var cropSize = min(properties.width!, properties.height!);
      int offsetX = (properties.width! - cropSize) ~/ 2;
      int offsetY = (properties.height! - cropSize) ~/ 2;
      imageFile = await FlutterNativeImage.cropImage(file.path, offsetX, offsetY, cropSize, cropSize);

      setState(() {
        _image = file;
        _isLoading = false;
      });

      await sendImageToServer(imageFile!);
      print("Image captured and processed successfully.");
    } catch (e) {
      print('Error taking picture: $e');
      _showErrorDialog('이미지 촬영 중 오류가 발생했습니다.');
    }
  }

  Future<void> getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      setState(() {
        _image = pickedFile;
        _isLoading = false;
      });

      await sendImageToServer(imageFile!);
      print("Image selected from gallery and processed.");
    }
  }
Future<void> sendImageToServer(File imageFile) async {
  setState(() {
    _isLoading = true;
    _ocrResult = "OCR 요청 중입니다...";
  });

  var request = http.MultipartRequest('POST', Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/ocr/'));
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);

      setState(() {
        // 응답이 리스트로 되어 있는지 확인하고 처리
        if (result is List) {
          List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(result);
          _ocrResult = results.map((data) {
            String drugCode = data['drug_code'] ?? '알 수 없음';
            String dosage = data['dosage'] ?? '알 수 없음';
            String time = data['time'] ?? '알 수 없음';
            return """
            약품 코드: $drugCode
            복용 횟수: $dosage
            복용 시간: $time
            """;
          }).join('\n');
          List<bool> timeSet;
          List<int> meal;
          ExampleAlarmEditScreen(alarmSettings: null,);
        } else {
          _ocrResult = 'OCR 결과가 예상한 형태가 아닙니다.';
        }
      });
    } else {
      setState(() {
        _ocrResult = 'OCR 요청 실패: 상태 코드 ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      _ocrResult = 'OCR 요청 실패: 오류가 발생했습니다.';
    });
    print('Error during OCR request: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('처방전'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: size.height * 0.4,
                  height: size.height * 0.4,
                  child: _isLoading
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('이미지 처리 중입니다...'),
                    ],
                  )
                      : (_image != null
                      ? Image.file(
                    imageFile!,
                    fit: BoxFit.contain,
                  )
                      : (controller.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: 1,
                    child: CameraPreview(controller),
                  )
                      : Container(color: Colors.grey))),
                ),
                SizedBox(height: size.height * 0.05),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _ocrResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                  width: size.width * 0.7,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: _image == null ? _takePicture : () => setState(() => _image = null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _image == null ? Color(0xffC22AF8) : Color(0xff852C83),
                      shape: BeveledRectangleBorder(),
                    ),
                    child: Text(
                      _image == null ? '촬영하기' : '다시 촬영하기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.height * 0.025,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.7,
                  height: size.height * 0.06,
                  child: TextButton(
                    onPressed: () {
                      if (_image == null) {
                        getImage(ImageSource.gallery);
                      } else {
                        setState(() {
                          _image = null;
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
                  ),
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
