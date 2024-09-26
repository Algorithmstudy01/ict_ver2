import 'package:flutter/material.dart';

class DeleteAlarmScreen extends StatelessWidget {
  final Map<String, dynamic> alarm;
  final VoidCallback onDelete;

  DeleteAlarmScreen({required this.alarm, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Alarm'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('알람을 삭제하시겠습니까?'),
            SizedBox(height: 20),
            Text(alarm['time']),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              child: Text('삭제'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
          ],
        ),
      ),
    );
  }
}