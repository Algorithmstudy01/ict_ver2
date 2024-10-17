import 'dart:io';

import 'package:chungbuk_ict/My_alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  const ExampleAlarmEditScreen({super.key, this.alarmSettings, this.timeSelected, this.mealTime});

  final AlarmSettings? alarmSettings;
  final List<bool>? timeSelected;
  final List<int>? mealTime;

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  List<DateTime> selectedDateTime = List<DateTime>.filled(5, DateTime.now());
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  late String alarmName;
  late bool mon, tue, wed, thu, fri, sat, sun;
  late String predict = "약이름";
  List<bool> setTime = List<bool>.filled(5, false);
  List<int> meal = List<int>.filled(5, 0);
  List<String> time = ["기상", "취침", "아침", "점심", "저녁"];

  late

  final myController = TextEditingController();

  Future<File> _getFile(String fileName) async {
    // 앱의 디렉토리 경로를 가져옴
    final directory = await getApplicationDocumentsDirectory();
    // 파일 경로와 파일 이름을 합쳐서 전체 파일 경로를 만듬
    return File('${directory.path}/$fileName');
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

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;


    for(int i=0; i<5; i++){
      if(widget.timeSelected != null && widget.mealTime != null) {
        setTime[i] = widget.timeSelected![i];
        meal[i] = widget.mealTime![i];
      }
      switch(i){
        case 0:
          pickTime("wake", i);
        case 1:
          pickTime("sleep", i);
        case 2:
          pickTime("morning", i);
        case 3:
          pickTime("lunch", i);
        case 4:
          pickTime("dinner", i);


      }
    }

    if (creating) {
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
      alarmName = '';
      mon = true;
      tue = true;
      wed = true;
      thu = true;
      fri = true;
      sat = true;
      sun = true;

    } else {
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
      alarmName = widget.alarmSettings!.alarmName;
      mon = widget.alarmSettings!.mon;
      tue = widget.alarmSettings!.tue;
      wed = widget.alarmSettings!.wed;
      thu = widget.alarmSettings!.thu;
      fri = widget.alarmSettings!.fri;
      sat = widget.alarmSettings!.sat;
      sun = widget.alarmSettings!.sun;
    }
  }

  @override
  void dispose(){
    super.dispose();
    myController.dispose();
  }

  // String getDay() {
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);
  //   final difference = selectedDateTime.difference(today).inDays;
  //
  //   switch (difference) {
  //     case 0:
  //       return '오늘';
  //     case 1:
  //       return '내일';
  //     case 2:
  //       return '모레';
  //     default:
  //       return ' $difference일 후';
  //   }
  // }

  DateTime getPeriodDays(int id){
    int i=0;
    DateTime periodDateTime = selectedDateTime[id];

    for(i; i<8; i++){
      periodDateTime = selectedDateTime[id].add(Duration(days: i));
      switch(periodDateTime.weekday) {
        case 1:
          if(mon == true){ i=8; }
          break;
        case 2:
          if(tue == true){ i=8; }
          break;
        case 3:
          if(wed == true){ i=8; }
          break;
        case 4:
          if(thu == true){ i=8; }
          break;
        case 5:
          if(fri == true){ i=8; }
          break;
        case 6:
          if(sat == true){ i=8; }
          break;
        case 7:
          if(sun == true){ i=8; }
          break;
      }
      if(i==7)periodDateTime = selectedDateTime[id];
    }

    return periodDateTime;
  }

  Future<void> pickTime(String fileName, int i) async {
    // final res = await showTimePicker(
    //   initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    //   context: context,
    // );
    String temp = await _loadFile(fileName);
    String tod = temp.split(" ")[1];
    TimeOfDay res = TimeOfDay(hour: int.parse(tod.split(":")[0]) + (temp.split(" ")[0]=="오후"?12:0), minute: int.parse(tod.split(":")[1]));

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime[i] = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime[i].isBefore(now)) {
          selectedDateTime[i] = selectedDateTime[i].add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings(int id, int i) {
    // final id = creating
    //     ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
    //     : widget.alarmSettings!.id;

    alarmName = myController.text;

    DateTime periodDateTime = getPeriodDays(id);
    final iD = periodDateTime.hour+periodDateTime.minute;
    final alarmSettings = AlarmSettings(
      id: iD,
      dateTime: periodDateTime.add(Duration(minutes: i*30)),
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: '야금야금',
      notificationBody: '$alarmName 드실 시간이에요',
      enableNotificationOnKill: Platform.isAndroid,
      alarmName: Alarm.getAlarm(iD)?.alarmName != null? Alarm.getAlarm(iD)?.alarmName != alarmName? "${Alarm.getAlarm(iD)?.alarmName}, $alarmName": alarmName : alarmName,
      mon: mon,
      tue: tue,
      wed: wed,
      thu: thu,
      fri: fri,
      sat: sat,
      sun: sun,
    );
    return alarmSettings;
  }

  void saveAlarm(int id, int i) {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings(id, i));//.then((res) {
      //if (res) Navigator.pop(context, true);
    setState(() => loading = false);
    //});
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  SizedBox makeButton(int i){
    final Size size = MediaQuery.of(context).size;
    SizedBox elevatedButton = new SizedBox(
      width: size.width*0.4,
        child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: setTime[i]? Colors.blueAccent : Colors.white,
        ),
        onPressed: (){
          setState(() {
            setTime[i] = !setTime[i];
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time[i],
              style: TextStyle(
                  fontSize: size.height*0.03,
                  color: setTime[i] ? Colors.white:Colors.grey
              ),
            ),
            i==0? SizedBox() : i==1? SizedBox(): DropdownButton(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                dropdownColor: setTime[i]? Colors.blueAccent: Colors.white,
                value: meal[i],
                style: TextStyle(
                    fontSize: size.height*0.03,
                    color: setTime[i]? Colors.white: Colors.grey
                ),
                items: [
                  DropdownMenuItem<int>(
                      value: 0,
                      child: Text("즉시")
                  ),
                  DropdownMenuItem<int>(
                      value: -1,
                      child: Text("식전")
                  ),
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text("식후"),
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    meal[i] = value!;
                  });
                }
            )
          ],
        )
    ));
    return elevatedButton;
  }
  
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    myController.text = alarmName != ""? alarmName : predict;
    return SingleChildScrollView(
  child: Padding(
      padding: EdgeInsets.symmetric(vertical: size.height*0.02, horizontal: size.width*0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  '취소',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: (){
                  for(int i=0; i<5; i++){
                    if(setTime[i]){
                      saveAlarm(i, meal[i]);
                    }
                  }
                  Navigator.pop(context, true);
                  setState(() {
                  });
                },
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        '저장',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.blueAccent),
                      ),
              ),
            ],
          ),

          TextField(
            controller: myController,
            decoration: InputDecoration(
              hintText: alarmName != '' ? alarmName : predict
            ),
            onChanged: (value)=> alarmName =value,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  makeButton(0),
                  makeButton(1)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  makeButton(2),
                  makeButton(3),
                  
                ],
              ),
              SizedBox(
                height: size.height*0.01,
              ),
              Center(
                child: makeButton(4),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '알람음 반복',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진동',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '알람음',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                dropdownColor: Colors.white,
                value: assetAudio,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'assets/marimba.mp3',
                    child: Text('Marimba'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/nokia.mp3',
                    child: Text('Nokia'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/mozart.mp3',
                    child: Text('Mozart'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/star_wars.mp3',
                    child: Text('Star Wars'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/one_piece.mp3',
                    child: Text('One Piece'),
                  ),
                ],
                onChanged: (value) => setState(() => assetAudio = value!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '볼륨 조절',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) =>
                    setState(() => volume = value ? 0.5 : null),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: volume != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        volume! > 0.7
                            ? Icons.volume_up_rounded
                            : volume! > 0.1
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded,
                      ),
                      Expanded(
                        child: Slider(
                          value: volume!,
                          onChanged: (value) {
                            setState(() => volume = value);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          if (!creating)
            TextButton(
              onPressed: deleteAlarm,
              child: Text(
                '알람 제거',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    ));
  }
}

