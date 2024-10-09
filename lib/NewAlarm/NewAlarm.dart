import 'dart:async';

import 'package:chungbuk_ict/My_alarm/alarm.dart';
import 'package:flutter/material.dart';

import 'ring.dart';
import 'edit_alarm.dart';
import 'tile.dart';

class ExampleAlarmHomeScreen extends StatefulWidget {
  const ExampleAlarmHomeScreen({super.key});

  @override
  State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
}

class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> with AutomaticKeepAliveClientMixin{
  late List<AlarmSettings> alarms;

  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings, refreshAlarms: loadAlarms,),
      ),
    );
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ExampleAlarmEditScreen(alarmSettings: settings),
        );
      },
    );

    if (res != null && res == true) loadAlarms();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
<<<<<<< HEAD
   
=======

>>>>>>> a06fa944da92b934f8e934b38998c4ec9fe8505d
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.separated(
          itemCount: alarms.length,
          separatorBuilder: (context, index) => const Divider(height: 8),
          itemBuilder: (context, index) {
            return ExampleAlarmTile(
              key: Key(alarms[index].id.toString()),
              title: TimeOfDay(
                hour: alarms[index].dateTime.hour,
                minute: alarms[index].dateTime.minute,
              ).format(context),
              alarmsettings: alarms[index],
              onPressed: () => navigateToAlarmScreen(alarms[index]),
              onDismissed: () {
                Alarm.stop(alarms[index].id).then((_) => loadAlarms());
              },
            );
          },
        )
            : Center(
          child: Text(
            '알람을 등록해주세요',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
            FloatingActionButton(
              onPressed: loadAlarms,
              child: const Icon(Icons.refresh, size: 33,),
            ),
            FloatingActionButton(
              onPressed: () => navigateToAlarmScreen(null),
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}