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
      clientId: 'rwquqodfmt',
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
      zoomGesturesEnable: true,
      rotationGesturesEnable: true,
      mapType: NMapType.navi,
      activeLayerGroups: [
        NLayerGroup.building,
        NLayerGroup.transit
      ],
      indoorEnable: true,
      locationButtonEnable: true, // 위치 버튼 활성화
      consumeSymbolTapEvents: false,
    ),
    onMapTapped: (point, latLng) {}, // 지도를 클릭했을 때 발생
    onSymbolTapped: (symbol) {}, // 심볼을 클릭했을 때 발생
    onMapReady: (controller) async {
      _mapController = controller;
      mapControllerCompleter.complete(controller);
      log("onMapReady", name: "onMapReady");

      // 마커 생성 및 추가
      final marker = NMarker(
        id: 'test',
        position: const NLatLng(37.506932467450326, 127.05578661133796),
      );
      final marker1 = NMarker(
        id: 'test1',
        position: const NLatLng(37.606932467450326, 127.05578661133796),
      );

      // 마커를 지도에 추가
      _mapController.addOverlayAll({marker, marker1});

      // 위치 추적 모드 설정
      _mapController.setLocationTrackingMode(NLocationTrackingMode.follow);

      // 마커에 인포 윈도우 추가
      final infoWindow = NInfoWindow.onMarker(
        id: marker.info.id,
        text: "약국 위치",
      );
      marker.openInfoWindow(infoWindow);
    },
  );
}
