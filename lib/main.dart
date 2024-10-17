import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'start_section.dart';  // Import the start section
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'Camera.dart';
import 'My_alarm/alarm.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widget binding is initialized
  _cameras = await availableCameras();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Alarm.init();
  
  runApp(const MyApp());

  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
  }

  // Request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.storage,
    Permission.notification,
    Permission.scheduleExactAlarm,
  ].request();
  print(statuses[Permission.camera]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Camera(_cameras),  // Pass the cameras to the provider
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko', 'KR'),
        ],
        home: StartSection(), // Start the app with StartSection
      ),
    );
  }
}
