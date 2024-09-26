// import 'package:chungbuk_ict/delete_alarm.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'homepage.dart';
// import 'my_page.dart';

// class AlarmPage extends StatefulWidget {
//   final String userId;

//   AlarmPage({required this.userId});

//   @override
//   _AlarmPageState createState() => _AlarmPageState();
// }

// class _AlarmPageState extends State<AlarmPage> with AutomaticKeepAliveClientMixin {
//   int _selectedIndex = 2;
//   List<Map<String, dynamic>> alarms = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchAlarms(); // 페이지 로드 시 알람 목록 가져오기
//   }

//   void _onItemTapped(int index) {
//     if (index != _selectedIndex) {
//       setState(() {
//         _selectedIndex = index;
//       });

//       if (index == 0) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => MyHomePage(userId: widget.userId)),
//         );
//       } else if (index == 3) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => TabbarFrame(userId: widget.userId)),
//         );
//       }
//     }
//   }

//   Future<void> _fetchAlarms() async {
//     final url = 'https://80d4-113-198-180-184.ngrok-free.app/alarms/${widget.userId}/'; // Ensure correct port
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
//         setState(() {
//           alarms = responseData.map((item) {
//             return {
//               'id': item['id'].toString(),
//               'user_id': item['user_id'].toString(),
//               'time': item['time'].toString(),
//               'days': List<String>.from(item['days']),
//               'name': item['name'] ?? '',
//               'usage': item['usage'] ?? '',
//             };
//           }).toList();
//         });
//         print('Fetched alarms: $alarms'); // For debugging
//       } else {
//         print('Failed to load alarms. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching alarms: $e');
//     }
//   }

//   Future<void> _updateAlarm(int index, String time, List<String> days, String name, String usage) async {
//     final alarm = alarms[index];
//     final alarmId = alarm['id'];

//     if (alarmId == null) {
//       print('Error: alarmId is null');
//       return;
//     }

//     final url = 'https://80d4-113-198-180-184.ngrok-free.app/alarms/update/$alarmId/';
//     try {
//       final response = await http.put(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, dynamic>{
//           'time': time,
//           'days': days,
//           'name': name,
//           'usage': usage,
//         }),
//       );
//       if (response.statusCode == 200) {
//         _fetchAlarms(); // 성공 시 알람 목록 새로고침
//       } else {
//         print('Failed to update alarm. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating alarm: $e');
//     }
//   }

//   Future<void> _deleteAlarm(int index) async {
//     final alarm = alarms[index];
//     final alarmId = alarm['id'];

//     if (alarmId == null) {
//       print('Error: alarmId is null');
//       return;
//     }

//     final url = 'https://80d4-113-198-180-184.ngrok-free.app/alarms/delete/$alarmId/';
//     try {
//       final response = await http.delete(Uri.parse(url));
//       if (response.statusCode == 204) {
//         setState(() {
//           alarms.removeAt(index); // 성공 시 해당 알람을 목록에서 제거
//         });
//         print('Alarm deleted successfully');
//       } else {
//         print('Failed to delete alarm. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error deleting alarm: $e');
//     }
//   }

//     void _navigateToDeleteAlarmScreen(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DeleteAlarmScreen(
//           alarm: alarms[index],
//           onDelete: () => _deleteAlarm(index),
//         ),
//       ),
//     );
//   }

//   void _addNewAlarm() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlarmSettingModal(
//           onSave: (time, days, name, usage) async {
//             final url = 'https://80d4-113-198-180-184.ngrok-free.app/alarms/create/'; // Django URL
//             try {
//               final response = await http.post(
//                 Uri.parse(url),
//                 headers: <String, String>{
//                   'Content-Type': 'application/json; charset=UTF-8',
//                 },
//                 body: jsonEncode(<String, dynamic>{
//                   'user_id': widget.userId,
//                   'time': time,
//                   'days': days,
//                   'name': name,
//                   'usage': usage,
//                 }),
//               );
//               if (response.statusCode == 201) {
//                 _fetchAlarms();
//               } else {
//                 print('Failed to create alarm. Status code: ${response.statusCode}');
//               }
//             } catch (e) {
//               print('Error creating alarm: $e');
//             }
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 4,
//         title: Text(
//           '알림 설정',
//           style: TextStyle(color: Colors.black),
//         ),
//         centerTitle: true,
//         shadowColor: Colors.grey.withOpacity(0.5),
//         automaticallyImplyLeading: false,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16.0),
//         itemCount: alarms.length,
//         itemBuilder: (context, index) {
//           final alarm = alarms[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16.0),
//             child: GestureDetector(
//               onTap: () => _showOptionsMenu(context, index),
//               child: AlarmCard(
//                 activeDays: alarm['days'],
//                 time: alarm['time'],
//                 name: alarm['name'],
//                 usage: alarm['usage'],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addNewAlarm,
//         backgroundColor: Colors.purple[200],
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   void _showOptionsMenu(BuildContext context, int index) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Wrap(
//           children: [
//             ListTile(
//               leading: Icon(Icons.edit),
//               title: Text('알람 수정'),
//               onTap: () {
//                 Navigator.pop(context); // Close the modal
//                 _editAlarm(index);
//               },
//             ),
//              ListTile(
//               leading: Icon(Icons.delete),
//               title: Text('알람 삭제'),
//               onTap: () {
//                 Navigator.pop(context); // Close the modal
//                 _navigateToDeleteAlarmScreen(index);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

// void _editAlarm(int index) {
//   final alarm = alarms[index];
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlarmSettingModal(
//         initialTime: alarm['time'],  // String 형태의 시간 전달
//         initialDays: List<String>.from(alarm['days']),  // 리스트 형태의 요일 전달
//         initialMedName: alarm['name'],  // 초기 약 이름 전달
//         initialInstructions: alarm['usage'],  // 초기 사용 용도 전달
//         onSave: (time, days, name, usage) {
//           _updateAlarm(index, time, days, name, usage);
//         },
//       );
//     },
//   );
// }
//   @override
//   bool get wantKeepAlive => true;
// }




// class AlarmSettingModal extends StatefulWidget {
//   final Function(String, List<String>, String, String) onSave;
//   final String? initialTime;
//   final List<String>? initialDays;
//   final String? initialMedName;
//   final String? initialInstructions;

//   AlarmSettingModal({
//     required this.onSave,
//     this.initialTime,
//     this.initialDays,
//     this.initialMedName,
//     this.initialInstructions,
//   });

//   @override
//   _AlarmSettingModalState createState() => _AlarmSettingModalState();
// }

// class _AlarmSettingModalState extends State<AlarmSettingModal> {
//   late TimeOfDay _selectedTime;
//   late List<String> _selectedDays;
//   late TextEditingController _medNameController;
//   late TextEditingController _instructionsController;

//   @override
//   void initState() {
//     super.initState();
    
//     _selectedTime = widget.initialTime != null
//         ? TimeOfDay(
//             hour: int.parse(widget.initialTime!.split(":")[0]),
//             minute: int.parse(widget.initialTime!.split(":")[1]),
//           )
//         : TimeOfDay.now();

//     _selectedDays = widget.initialDays ?? ['월', '화', '수', '목', '금'];
    
//     _medNameController = TextEditingController(
//       text: widget.initialMedName ?? '',
//     );
    
//     _instructionsController = TextEditingController(
//       text: widget.initialInstructions ?? '',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.black,
//       title: Center(
//         child: Text(
//           '알람 설정',
//           style: TextStyle(fontSize: 24, color: Colors.white),
//         ),
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             GestureDetector(
//               onTap: () async {
//                 TimeOfDay? picked = await showTimePicker(
//                   context: context,
//                   initialTime: _selectedTime,
//                 );
//                 if (picked != null) {
//                   setState(() {
//                     _selectedTime = picked;
//                   });
//                 }
//               },
//               child: Text(
//                 _selectedTime.format(context),
//                 style: TextStyle(fontSize: 48, color: Colors.white),
//               ),
//             ),
//             SizedBox(height: 16),
//             Wrap(
//               spacing: 8.0,
//               children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
//                 bool isSelected = _selectedDays.contains(day);
//                 return ChoiceChip(
//                   label: Text(day),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     setState(() {
//                       if (selected) {
//                         _selectedDays.add(day);
//                       } else {
//                         _selectedDays.remove(day);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _medNameController,
//               decoration: InputDecoration(
//                 labelText: '약 이름',
//                 labelStyle: TextStyle(color: Colors.white),
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//               ),
//               style: TextStyle(color: Colors.white),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: _instructionsController,
//               decoration: InputDecoration(
//                 labelText: '용법',
//                 labelStyle: TextStyle(color: Colors.white),
//                 enabledBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.white),
//                 ),
//               ),
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: () {
//             final String formattedTime =
//                 '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
//             widget.onSave(
//               formattedTime,
//               _selectedDays,
//               _medNameController.text,
//               _instructionsController.text,
//             );
//             Navigator.pop(context);
//           },
//           child: Text('확인'),
//         ),
//       ],
//     );
//   }
// }

// class AlarmCard extends StatelessWidget {
//   final List<String> activeDays;
//   final String time;
//   final String name;
//   final String usage;

//   const AlarmCard({
//     required this.activeDays,
//     required this.time,
//     required this.name,
//     required this.usage,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[400], // Grey background color
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 time,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Row(
//                 children: [
//                   for (var day in ['월', '화', '수', '목', '금', '토', '일'])
//                     DayWithDot(
//                       day: day,
//                       isActive: activeDays.contains(day),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//           Spacer(),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left of the image
//             children: [
//               Image.asset(
//                 'assets/img/pill.png', // Replace with the path to your image asset
//                 width: 50,
//                 height: 50,
//               ),
//               SizedBox(height: 8),
//               Text(
//                 name,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white, // Set text color to white
//                 ),
//               ),
//               Text(
//                 usage,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white, // Set text color to white
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DayWithDot extends StatelessWidget {
//   final String day;
//   final bool isActive;

//   DayWithDot({required this.day, required this.isActive});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.0),
//       child: Column(
//         children: [
//           if (isActive)
//             Icon(
//               Icons.circle,
//               size: 6, // Smaller dot size
//               color: Colors.purple,
//             ),
//           Text(
//             day,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }