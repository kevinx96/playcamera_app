import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  final ApiService _apiService = ApiService();

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: same
      // final response = await _apiService.login(username, password);
      
      // デモデータ
      await Future.delayed(const Duration(seconds: 1));
      _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      _user = User(
        id: 1,
        username: 'admin', // ユーザー名を'admin'に固定
        email: 'admin@example.com',
        fullName: 'システム管理者', //  フルネームを更新
        role: 'admin',
        createdAt: DateTime.now(),
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: api still not online
      // final response = await _apiService.register(...);
      
      // デモデータ
      await Future.delayed(const Duration(seconds: 1));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}

