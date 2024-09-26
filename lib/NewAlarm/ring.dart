import 'package:chungbuk_ict/My_alarm/alarm.dart';
import 'package:flutter/material.dart';

class ExampleAlarmRingScreen extends StatelessWidget {
  const ExampleAlarmRingScreen({required this.alarmSettings, required this.refreshAlarms, super.key});

  final AlarmSettings alarmSettings;
  final void Function() refreshAlarms;
  
  Future<void> stopAlarm(AlarmSettings alarmSettings) async {

    int i=1;
    DateTime newdDateTime = alarmSettings.dateTime;

    for(i; i<8; i++){
      newdDateTime = alarmSettings.dateTime.add(Duration(days: i));
      switch(newdDateTime.weekday) {
        case 1:
          if(alarmSettings.mon == true){ i=8; }
          break;
        case 2:
          if(alarmSettings.tue == true){ i=8; }
          break;
        case 3:
          if(alarmSettings.wed == true){ i=8; }
          break;
        case 4:
          if(alarmSettings.thu == true){ i=8; }
          break;
        case 5:
          if(alarmSettings.fri == true){ i=8; }
          break;
        case 6:
          if(alarmSettings.sat == true){ i=8; }
          break;
        case 7:
          if(alarmSettings.sun == true){ i=8; }
          break;
      }
      if(i==7)newdDateTime = alarmSettings.dateTime;
    }

      final newalarmSettings = AlarmSettings(
        id: alarmSettings.id,
        dateTime: newdDateTime,
        loopAudio: alarmSettings.loopAudio,
        vibrate: alarmSettings.vibrate,
        volume: alarmSettings.volume,
        assetAudioPath: alarmSettings.assetAudioPath,
        notificationTitle: alarmSettings.notificationTitle,
        notificationBody: alarmSettings.notificationBody,
        enableNotificationOnKill: alarmSettings.enableNotificationOnKill,
        alarmName: alarmSettings.alarmName,
        sun: alarmSettings.sun,
        mon: alarmSettings.mon,
        tue: alarmSettings.tue,
        wed: alarmSettings.wed,
        thu: alarmSettings.thu,
        fri: alarmSettings.fri,
        sat: alarmSettings.sat,
      );


    Alarm.stop(alarmSettings.id).then((bool result) {
      if(newalarmSettings.dateTime != alarmSettings.dateTime) Alarm.set(alarmSettings: newalarmSettings);
      refreshAlarms();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              '${alarmSettings.alarmName} 드실 시간이에요',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Image(image: AssetImage('assets/img/pill.gif')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                        ).add(const Duration(minutes: 1)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    '나중에 울리기',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    stopAlarm(alarmSettings).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    '정지',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
