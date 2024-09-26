import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera with ChangeNotifier {
  late List<CameraDescription> _cameras;

  // Update the constructor to accept a list of cameras
  Camera(List<CameraDescription> cameras) {
    _cameras = cameras;
  }

  List<CameraDescription> get cameras => _cameras;

  void setCameras(List<CameraDescription> newCameras) {
    _cameras = newCameras;
    notifyListeners();
  }

  List<CameraDescription> getCameras() {
    return _cameras;
  }
}
