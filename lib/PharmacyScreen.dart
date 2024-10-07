import 'dart:async';
import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NearbyPharmacyPage extends StatefulWidget {
  const NearbyPharmacyPage({Key? key}) : super(key: key);

  @override
  State<NearbyPharmacyPage> createState() => _NearbyPharmacyPageState();
}

class _NearbyPharmacyPageState extends State<NearbyPharmacyPage> {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
  }

  Future<void> _initializeNaverMap() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NaverMapSdk.instance.initialize(
      clientId: '<Client id>',
      onAuthFailed: (ex) => log("********* 네이버맵 인증오류 : $ex *********"),
    );
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 약국')),
      body: _isInitialized
          ? Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          height: MediaQuery.of(context).size.height - 72,
          child: _naverMapSection(),
        ),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
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
