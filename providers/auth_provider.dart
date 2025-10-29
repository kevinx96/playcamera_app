import 'package:flutter/material.dart';
import 'dart:developer' as developer; // [NEW] 导入 developer 库用于更详细的日志
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

  // [REMOVED] ApiService 实例将由 ProxyProvider 注入
  // final ApiService _apiService = ApiService(null);

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // 登录时临时创建一个 ApiService 实例 (不需要 token)
    final tempApiService = ApiService(null);

    try {
      developer.log('Attempting login for user: $username', name: 'AuthProvider.login'); // [NEW LOG]
      final response = await tempApiService.login(username, password);
      developer.log('Login API response received: $response', name: 'AuthProvider.login'); // [NEW LOG]

      _token = response['token'];
      _user = User.fromJson(response['user']);

      // [REMOVED] 不再需要 setToken
      // _apiService.setToken(_token!);

      _isLoading = false;
      developer.log('Login successful. Token set. Notifying listeners.', name: 'AuthProvider.login'); // [NEW LOG]
      notifyListeners(); // 此时 _token 已经更新，ProxyProvider 会检测到
      return true;

    } catch (e, stackTrace) { // [MODIFIED] 捕获堆栈跟踪
      // [MODIFIED] 添加详细的错误日志
      _error = "ログインに失敗しました: ${e.toString()}";
      _isLoading = false;
      // **** 这里添加了更详细的日志 ****
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    // 注册时临时创建一个 ApiService 实例 (不需要 token)
    final tempApiService = ApiService(null);

    try {
      developer.log('Attempting registration for user: $username', name: 'AuthProvider.register'); // [NEW LOG]
      final response = await tempApiService.register(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
      );
      developer.log('Register API response received: $response', name: 'AuthProvider.register'); // [NEW LOG]

      // 注册成功后，通常不会自动登录或设置 token，只返回成功状态
      // 如果您的 API 设计是注册后自动登录，则需要在这里处理 token 和 user

      _isLoading = false;
      developer.log('Registration successful. Notifying listeners.', name: 'AuthProvider.register'); // [NEW LOG]
      notifyListeners();
      return true; // 返回 true 表示 API 调用成功

    } catch (e, stackTrace) { // [MODIFIED] 捕获堆栈跟踪
      // [MODIFIED] 添加详细的错误日志
      _error = "ユーザー登録に失敗しました: ${e.toString()}";
      _isLoading = false;
       // **** 这里添加了更详细的日志 ****
      developer.log(
        'Registration failed!', 
        name: 'AuthProvider.register', 
        error: e, 
        stackTrace: stackTrace
      );
      notifyListeners();
      return false; // 返回 false 表示 API 调用失败
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    // [REMOVED] 不再需要 setToken
    // _apiService.setToken('');
    developer.log('User logged out. Notifying listeners.', name: 'AuthProvider.logout'); // [NEW LOG]
    notifyListeners();
  }
}

