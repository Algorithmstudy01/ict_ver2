
import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class FirstAlarmSet extends StatefulWidget {
  final String userId;

  const FirstAlarmSet({Key? key, required this.userId}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _FirstAlarmSet();
}

class _FirstAlarmSet extends State<FirstAlarmSet> {

  void setTime(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      // 성공 시 페이지 이동
      return TabbarFrame(userId: widget.userId);
    }));
  }

  void skip(){

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      // 성공 시 페이지 이동
      return TabbarFrame(userId: widget.userId);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: setTime,
                    child: Text(
                        "시간 설정",
                      style: TextStyle(
                        fontSize: size.height*0.038,
                        color: Colors.white
                      ),
                    )
                ),
                ElevatedButton(
                    onPressed: skip,
                    child: Text(
                        "건너뛰기",
                      style: TextStyle(
                        fontSize:  size.height*0.02,
                      ),
                    ),

                )
              ],
            )),
            //Text(test)
          ],
        ),
      ),
    );

  }
}