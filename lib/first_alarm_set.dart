
import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class FirstAlarmSet extends StatefulWidget {
  final String userId;

  const FirstAlarmSet({Key? key, required this.userId}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _FirstAlarmSet();
}

class _FirstAlarmSet extends State<FirstAlarmSet> {

  // late List<HashMap<String, DateTime>> timeList;
  late HashMap<String, DateTime> timeList;
  final now = DateTime.now();
  var selectedTime = List<TimeOfDay>.filled(5, TimeOfDay.now());
  late DateTime timeSet;
  final _formKey = GlobalKey<FormState>();
  late String test ="";

  void setSelectedTime(int i, int hour, int min){
    selectedTime[i] = TimeOfDay(hour: hour, minute: min);
  }

  @override
  void initState() {
    super.initState();
    for(int i =0; i<5; i++){
      switch (i){
        case 0:
          setSelectedTime(i, 6, 0);
        case 1:
          setSelectedTime(i, 22, 0);
        case 2:
          setSelectedTime(i, 7, 30);
        case 3:
          setSelectedTime(i, 12, 30);
        case 4:
          setSelectedTime(i, 18, 30);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

// 파일 경로를 생성하는 함수
  Future<File> _getFile(String fileName) async {
    // 앱의 디렉토리 경로를 가져옴
    final directory = await getApplicationDocumentsDirectory();
    // 파일 경로와 파일 이름을 합쳐서 전체 파일 경로를 만듬
    return File('${directory.path}/$fileName');
  }

  Future<void> setAlarmTime(String fileName, int i) async {
    final file = await _getFile(fileName);
    await file.writeAsString(selectedTime[i].format(context));
    setState(() {});

    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
    //   // 성공 시 페이지 이동
    //   return TabbarFrame(userId: widget.userId);
    // }));

  }

  Future<String> _loadFile(String fileName) async {
    try {
      //파일을 불러옴
      final file = await _getFile(fileName);
      //불러온 파일의 데이터를 읽어옴
      String fileContents = await file.readAsString();
      return fileContents;
    } catch (e) {
      return '';
    }
  }

  void skip(){

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      // 성공 시 페이지 이동
      return TabbarFrame(userId: widget.userId);
    }));
  }

  Future<void> setTime(int i) async{
    final res = await showTimePicker(
      initialTime: selectedTime[i],
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if(res != null){
      setState(() {
        selectedTime[i] = res;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final selection = CupertinoTextSelectionControls();

    RawMaterialButton timeButton(int i, String time){
      RawMaterialButton  button = new RawMaterialButton(
        onPressed: (){setTime(i);},
        child: Container(
          alignment: Alignment.centerLeft,
          height: size.height*0.1,
          width: size.width,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1)
              )
          ),
          child: Text(
            "$time "+selectedTime[i].format(context),
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: Colors.blueAccent),

          ),
        ),
      );
      return button;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('알람 세팅'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
        automaticallyImplyLeading: true,  // 기본 뒤로가기 버튼 추가
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: size.height*0.03,),
            timeButton(0, "기상시간"),
            timeButton(1, "취침시간"),
            timeButton(2, "아침식사"),
            timeButton(3, "점심식사"),
            timeButton(4, "저녁식사"),
            SizedBox(height: size.height*0.03,),
            SizedBox(
              width: size.width*0.9,
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                ElevatedButton(
                    onPressed: (){
                        for(int i=0; i<5; i++) {
                          setAlarmTime(
                              i == 0 ? "wake" : i == 1 ? "sleep" : i == 2
                                  ? "morning"
                                  : i == 3 ? "lunch" : i == 4
                                  ? "dinner"
                                  : "fail", i);
                        }

                      },
                    child: Text(
                        "시간 설정",
                      style: TextStyle(
                        fontSize: size.height*0.02
                      ),
                    )
                ),
                ElevatedButton(
                    onPressed: () async {
                      test = await _loadFile("morning");
                      setState(() {
                      });
                    },
                    child: Text(
                        "건너뛰기",
                      style: TextStyle(
                        fontSize:  size.height*0.02,
                      ),
                    ),

                ),
              ],
            )),
            //Text(test)
          ],
        ),
      ),
    );

  }
}