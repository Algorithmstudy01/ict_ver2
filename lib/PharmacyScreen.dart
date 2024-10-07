import 'dart:async';
import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  await _initialize();
  runApp(const NaverMapApp());
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: '<client ID>',
      onAuthFailed: (ex) => log("********* 네이버맵 인증오류 : $ex *********"));
}

class NaverMapApp extends StatelessWidget {
  final int? testId;

  const NaverMapApp({super.key, this.testId});

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: testId == null
          ? const FirstPage()
          : TestPage(key: Key("testPage_$testId")));
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('First Page')),
        body: Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TestPage()));
                },
                child: const Text('Go to Second Page'))));
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize =
    Size(mediaQuery.size.width - 32, mediaQuery.size.height - 72);
    final physicalSize =
    Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      body: Center(
          child: SizedBox(
              width: mapSize.width,
              height: mapSize.height,
              // color: Colors.greenAccent,
              child: _naverMapSection())),
    );
  }

  Widget _naverMapSection() => NaverMap(
    options: const NaverMapViewOptions(
        zoomGesturesEnable: true,// 줌(확대)
        rotationGesturesEnable: true,// 회전
      mapType : NMapType.navi,
        activeLayerGroups: [
          NLayerGroup.building,
          NLayerGroup.transit
        ], // 건물(건물 형상, 주소 심벌 등)과 대중교통 레이어(철도, 지하철 노선 등)
        indoorEnable: true,
        locationButtonEnable: false,
        consumeSymbolTapEvents: false),



    onMapTapped: (point, latLng) {}, // 지도를 클릭했을 때 발생
    onSymbolTapped: (symbol) {}, // 심볼을 클릭했을 때 발생
    onMapReady: (controller) async { // 지도가 준비되었을 때 발생
      _mapController = controller;
      mapControllerCompleter.complete(controller);
      log("onMapReady", name: "onMapReady");
    },
  );
}