import 'dart:io';

import 'package:chungbuk_ict/My_alarm/alarm.dart';
import 'package:flutter/material.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  const ExampleAlarmEditScreen({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  late String alarmName;
  late bool mon, tue, wed, thu, fri, sat, sun;

  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/marimba.mp3';
      alarmName = '';
      mon = false;
      tue = false;
      wed = false;
      thu = false;
      fri = false;
      sat = false;
      sun = false;

    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
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

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return '오늘';
      case 1:
        return '내일';
      case 2:
        return '모레';
      default:
        return ' $difference일 후';
    }
  }

  DateTime getPeriodDays(){
    int i=0;
    DateTime periodDateTime = selectedDateTime;

    for(i; i<8; i++){
      periodDateTime = selectedDateTime.add(Duration(days: i));
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
      if(i==7)periodDateTime = selectedDateTime;
    }

    return periodDateTime;
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
        : widget.alarmSettings!.id;

    alarmName = myController.text;

    DateTime periodDateTime = getPeriodDays();

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: periodDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: '야금야금',
      notificationBody: '$alarmName 드실 시간이에요',
      enableNotificationOnKill: Platform.isAndroid,
      alarmName: alarmName,
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

  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  void dayCount(){
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    selectedDateTime = selectedDateTime.subtract(Duration(days: selectedDateTime.difference(today).inDays));
    selectedDateTime = getPeriodDays();
  }@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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
                  onPressed: saveAlarm,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // The rest of your checkbox code remains unchanged
              ],
            ),
            Text(
              getDay(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
            ),
            RawMaterialButton(
              onPressed: pickTime,
              fillColor: Colors.grey[200],
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Text(
                  TimeOfDay.fromDateTime(selectedDateTime).format(context),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
            ),
            TextField(
              controller: myController,
              decoration: InputDecoration(
                hintText: alarmName != '' ? alarmName : '약 이름',
              ),
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
      ),
    ),
  );
}
}