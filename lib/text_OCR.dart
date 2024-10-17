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
  const FindText({super.key});

  @override
  State<FindText> createState() => _FindTextState();
}

class _FindTextState extends State<FindText> with AutomaticKeepAliveClientMixin {
  late CameraController controller;
  late List<CameraDescription> _cameras;
  XFile? _image;
  File? imageFile;
  bool _isLoading = false;
  List<String> uniqueDrugCodes = [];
  List<String> uniqueTimes = [];

  List<bool> timeSet = List<bool>.filled(5,false);
  List<int> meal = List<int>.filled(5, 0);

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
      uniqueDrugCodes.clear(); // Clear previous results
      uniqueTimes.clear();     // Clear previous results
    });

    var request = http.MultipartRequest('POST', Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/ocr/'));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var result = jsonDecode(responseBody);

        setState(() {
          if (result['drug_codes'] is List && result['times'] is List) {
            // Use Set to collect unique drug codes and times
            uniqueDrugCodes = Set<String>.from(result['drug_codes']).toList();
            uniqueTimes = Set<String>.from(result['times']).toList();

            for(int i=0; i<5; i++){
              if(uniqueTimes.contains("아침")){
                timeSet[2] = true;
                if(uniqueTimes.contains("식후")){
                  meal[2] = 1;
                }
              }
                if(uniqueTimes.contains("저녁")){
                  timeSet[4] = true;
                  if(uniqueTimes.contains("식후")){
                    meal[4] = 1;
                  }
                }

            }

          } else {
            _showErrorDialog('OCR 결과가 예상한 형태가 아닙니다.');
          }
        });
      } else {
        setState(() {
          _showErrorDialog('OCR 요청 실패: 상태 코드 ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _showErrorDialog('OCR 요청 실패: 오류가 발생했습니다.');
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
        title: const Text('처방전'),
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
                      ? const Column(
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
                // Display unique drug codes
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '약품 코드:\n' + (uniqueDrugCodes.isNotEmpty
                        ? uniqueDrugCodes.join(', ')
                        : '결과 없음'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                // Display unique times
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '복용 시간:\n' + (uniqueTimes.isNotEmpty
                        ? uniqueTimes.join(', ')
                        : '결과 없음'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                  width: size.width * 0.7,
                  height: size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: (){
                      if(_image ==null){
                        _takePicture();
                      }else{
                        showModalBottomSheet<bool?>(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.75,
                              child: ExampleAlarmEditScreen(alarmSettings: null, timeSelected: timeSet,mealTime: meal,name: "결막염"),
                            );
                          },
                        );
                        //_image = null;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _image == null ? const Color(0xffC22AF8) : const Color(0xff852C83),
                      shape: const BeveledRectangleBorder(),
                    ),
                    child: Text(
                      _image == null ? '촬영하기' : '알람 등록',
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
