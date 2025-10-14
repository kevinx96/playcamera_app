import 'package:flutter/material.dart';
import '../models/camera.dart';

class CameraProvider with ChangeNotifier {
  List<Camera> _cameras = [];
  Camera? _selectedCamera;
  bool _isLoading = false;
  String? _error;

  List<Camera> get cameras => _cameras;
  Camera? get selectedCamera => _selectedCamera;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // デモ用のカメラリストを非同期で取得する
  Future<void> fetchCameras() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _cameras = [
        Camera(id: 1, name: '運動場 全体', location: 'グラウンド', status: 'online'),
        Camera(id: 2, name: '滑り台エリア', location: '遊具ゾーン', status: 'offline'),
        Camera(id: 3, name: '鉄棒・うんてい', location: '遊具ゾーン', status: 'online'),
        Camera(id: 4, name: '正門', location: '出入口', status: 'online'),
      ];
      _error = null;
    } catch (e) {
      _error = "カメラリストの取得に失敗しました。";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void selectCamera(Camera camera) {
    _selectedCamera = camera;
    notifyListeners();
  }
}
