import 'package:flutter/material.dart';

class DeleteAlarmScreen extends StatelessWidget {
  final Map<String, dynamic> alarm;
  final VoidCallback onDelete;

  const DeleteAlarmScreen({super.key, required this.alarm, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Alarm'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('알람을 삭제하시겠습니까?'),
            const SizedBox(height: 20),
            Text(alarm['time']),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
          ],
        ),
      ),
    );
  }
}