import 'package:chungbuk_ict/CustomAlarm/alarm.dart';
import 'package:flutter/material.dart';

class ExampleAlarmTile extends StatelessWidget {
  const ExampleAlarmTile({
    required this.title,
    required this.onPressed,
    required this.alarmsettings,
    super.key,
    this.onDismissed,
  });

  final String title;
  final void Function() onPressed;
  final void Function()? onDismissed;
  final AlarmSettings alarmsettings;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //String pillName = '이름';
    //String usage = '용법';
    return Dismissible(
      key: key!,
      direction: onDismissed != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(
          Icons.delete,
          size: 30,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: RawMaterialButton(
        onPressed: onPressed,
        child: Center (
          child: Container(
            width: size.width * 0.95,
            height: 120,
            decoration: ShapeDecoration(
              color: Color(0xFFF4F4F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child:Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/img/pill.png',
                      width: 83,
                      height: 83,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width * 0.4,
                          child: Text(
                            '약이름: $pillName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Inter',
                              height: 0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.4,
                          child: Text(
                            '용법: $usage',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Inter',
                              height: 0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ) */
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  alarmsettings.alarmName,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
