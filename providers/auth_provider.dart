import 'package:flutter/material.dart';
import 'dart:developer' as developer; 
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

  Future<bool> login(String username, String password) async {
    // ... (login code remains the same) ...
    _isLoading = true;
    _error = null;
    notifyListeners();

    final tempApiService = ApiService(null);

    try {
      developer.log('Attempting login for user: $username', name: 'AuthProvider.login'); 
      final response = await tempApiService.login(username, password);
      developer.log('Login API response received: $response', name: 'AuthProvider.login'); 

      _token = response['token'];
      _user = User.fromJson(response['user']);

      _isLoading = false;
      developer.log('Login successful. Token set. Notifying listeners.', name: 'AuthProvider.login'); 
      notifyListeners(); 
      return true;

    } catch (e, stackTrace) { 
      _error = "ログインに失敗しました: ${e.toString()}";
      _isLoading = false;
      developer.log(
        'Login failed!', 
        name: 'AuthProvider.login', 
        error: e, 
        stackTrace: stackTrace
      ); 
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
    // ... (register code remains the same) ...
    _isLoading = true;
    _error = null;
    notifyListeners();

    final tempApiService = ApiService(null);

    try {
      developer.log('Attempting registration for user: $username', name: 'AuthProvider.register'); 
      final response = await tempApiService.register(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
      );
      developer.log('Register API response received: $response', name: 'AuthProvider.register'); 
      _isLoading = false;
      developer.log('Registration successful. Notifying listeners.', name: 'AuthProvider.register'); 
      notifyListeners();
      return true; 

    } catch (e, stackTrace) { 
      _error = "ユーザー登録に失敗しました: ${e.toString()}";
      _isLoading = false;
      developer.log(
        'Registration failed!', 
        name: 'AuthProvider.register', 
        error: e, 
        stackTrace: stackTrace
      );
      notifyListeners();
      return false; 
    }
  }

  Future<void> logout() async {
    // ... (logout code remains the same) ...
    _token = null;
    _user = null;
    developer.log('User logged out. Notifying listeners.', name: 'AuthProvider.logout'); 
    notifyListeners();
  }

  // [NEW] アカウント情報更新後にローカルのユーザー情報を更新するメソッド
  void updateLocalUser({
    String? newUsername,
    String? newEmail,
    String? newFullName,
  }) {
    if (_user == null) return;

    // 現在のユーザー情報に基づいて、新しい User オブジェクトを作成
    _user = User(
      id: _user!.id,
      username: newUsername ?? _user!.username, // 新しい名前があれば更新
      email: newEmail ?? _user!.email,         // 新しいEmailがあれば更新
      fullName: newFullName ?? _user!.fullName,   // 新しい氏名があれば更新
      role: _user!.role,
    );
    
    developer.log('Local user updated. New username: ${_user!.username}', name: 'AuthProvider.updateLocalUser');
    notifyListeners(); // UI (例: MypageScreen) に変更を通知
  }
}
