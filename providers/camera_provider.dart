import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../services/api_service.dart';

class CameraProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Camera> _cameras = [];
  bool _isLoading = true;
  String? _error;
  Camera? _selectedCamera; // [FIX] 状态管理中添加 selectedCamera

  List<Camera> get cameras => _cameras;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Camera? get selectedCamera => _selectedCamera; // [FIX] 添加 getter

  CameraProvider(this._apiService) {
    fetchCameras();
  }

  // [FIX] 添加 selectCamera 方法
  void selectCamera(Camera camera) {
    _selectedCamera = camera;
    notifyListeners();
  }

  Future<void> fetchCameras() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // _apiService.getCameras() 已经返回了 List<dynamic>
      final List<dynamic> response = await _apiService.getCameras();

      // [FIXED] 'response' 本身就是列表, 不再需要 ['data']
      final List<dynamic> cameraData = response;

      _cameras = cameraData
          .map((data) => Camera.fromJson(data as Map<String, dynamic>))
          .toList();
      
      // 默认选择第一个摄像头
      if (_cameras.isNotEmpty) {
        _selectedCamera = _cameras.first;
      }

    } catch (e) {
      _error = "カメラリストの取得に失敗しました: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

