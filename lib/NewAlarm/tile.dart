import 'package:chungbuk_ict/My_alarm/alarm.dart';
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
    String pillName = '이름';
    String usage = '용법';
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
            height: 150,
            decoration: ShapeDecoration(
              color: const Color(0xFF959595),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Text(
                    title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.sun ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '일',
                                style: TextStyle(
                                  color: alarmsettings.sun ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.mon ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '월',
                                style: TextStyle(
                                  color: alarmsettings.mon ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.tue ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '화',
                                style: TextStyle(
                                  color: alarmsettings.tue ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.wed ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '수',
                                style: TextStyle(
                                  color: alarmsettings.wed ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.thu ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '목',
                                style: TextStyle(
                                  color: alarmsettings.thu ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.fri ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '금',
                                style: TextStyle(
                                  color: alarmsettings.fri ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: alarmsettings.sat ? const Color(0xFFC42AFA) : const Color(0xFF959595),
                                  shape: const OvalBorder(),
                                ),
                              ),
                              Text(
                                '토',
                                style: TextStyle(
                                  color: alarmsettings.sat ? const Color(0xFFC42AFA) : Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
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
                    color: Colors.white,
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
