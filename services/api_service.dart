import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For Platform check AND SocketException
import 'dart:async'; // For TimeoutException
import 'dart:developer' as developer; // [NEW] 导入 developer

class ApiService {
  // !!! 重要: 请再次确认此 URL 完全正确 !!!
  static const String _renderUrl = 'https://playground-api-32jz.onrender.com/api'; // [USER PROVIDED URL - Please double check!]

  // 本地测试时使用 (Android 模拟器)
  static const String _localUrl = 'http://10.0.2.2:5000/api';

  // [DEBUG] 确保使用 Render URL
  static const String baseUrl = _renderUrl;

  final String? _token;
  ApiService(this._token);

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
     // ... (之前的 _handleResponse 代码保持不变) ...
    // 修复UTF-8编码问题
    final body = utf8.decode(response.bodyBytes);
    developer.log('API Response Status: ${response.statusCode}, Body: $body', name: 'ApiService._handleResponse');
    final jsonResponse = jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (jsonResponse is Map && jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
        return jsonResponse.containsKey('data')
            ? jsonResponse['data']
            : jsonResponse as Map<String, dynamic>;
      } else if (jsonResponse is Map && jsonResponse.containsKey('success') && jsonResponse['success'] == false) {
         developer.log('API reported error: ${jsonResponse['message']}', name: 'ApiService._handleResponse', error: jsonResponse['message']);
        throw Exception(jsonResponse['message'] ?? 'API reported an error');
      } else {
        return jsonResponse;
      }
    } else {
       developer.log('HTTP error: ${response.statusCode}, Message: ${jsonResponse is Map ? jsonResponse['message'] : body}', name: 'ApiService._handleResponse', error: jsonResponse is Map ? jsonResponse['message'] : body);
      throw Exception((jsonResponse is Map ? jsonResponse['message'] : body) ?? 'Failed with status code ${response.statusCode}');
    }
  }


  Future<Map<String, dynamic>> login(String username, String password) async {
     // ... (login code remains the same) ...
     developer.log('Sending login request to $baseUrl/auth/login for user: $username', name: 'ApiService.login');
    try {
      developer.log('Inside try block, before http.post', name: 'ApiService.login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = utf8.decode(response.bodyBytes);
      developer.log('Login Response Status: ${response.statusCode}, Body: $body', name: 'ApiService.login');
      final jsonResponse = jsonDecode(body);

      if (response.statusCode == 200 && jsonResponse is Map && jsonResponse['success'] == true) {
        return jsonResponse as Map<String, dynamic>;
      } else {
         final message = (jsonResponse is Map ? jsonResponse['message'] : '未知错误') ?? 'ログインに失敗しました';
         developer.log('Login failed in ApiService', name: 'ApiService.login', error: message);
        throw Exception(message);
      }
    } on SocketException catch (e, stackTrace) {
      developer.log('Network Error (SocketException) during login', name: 'ApiService.login', error: e, stackTrace: stackTrace);
      throw Exception('ネットワーク接続を確認してください: ${e.message}');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Network Error (TimeoutException) during login', name: 'ApiService.login', error: e, stackTrace: stackTrace);
      throw Exception('サーバーへの接続がタイムアウトしました。');
    } catch (e, stackTrace) {
       developer.log('Error during login HTTP call or processing', name: 'ApiService.login', error: e, stackTrace: stackTrace);
      throw Exception('ネットワークエラーが発生しました: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
  }) async {
    final url = '$baseUrl/auth/register';
    final body = jsonEncode({
      'username': username,
      'password': password,
      'email': email,
      'full_name': fullName,
    });
    developer.log('Sending register request to $url with body: $body', name: 'ApiService.register');

    try {
      developer.log('Inside try block, before http.post', name: 'ApiService.register');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: body,
      ).timeout(const Duration(seconds: 15)); // 保持增加的超时时间

      print('✅ Register response received: ${response.statusCode}'); // Use print for immediate visibility
      final responseBody = utf8.decode(response.bodyBytes);
      print('📄 Response body: $responseBody'); // Use print for immediate visibility
      final jsonResponse = jsonDecode(responseBody);

      // [FIXED] Check for 201 Created status code for successful registration
      if (response.statusCode == 201 && jsonResponse is Map && jsonResponse['success'] == true) {
        developer.log('Registration successful in ApiService. Returning response.', name: 'ApiService.register');
        return jsonResponse as Map<String, dynamic>; // 直接返回 Map<String, dynamic>
      } else {
        // Handle failure cases (e.g., 409 Conflict, other errors)
        final message = (jsonResponse is Map ? jsonResponse['message'] : '未知错误') ?? '登録に失敗しました';
        developer.log('Register failed in ApiService with status ${response.statusCode}', name: 'ApiService.register', error: message);
        print('❌ Register failed: $message'); // Use print for immediate visibility
        throw Exception(message); // Throw exception to be caught by AuthProvider
      }
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Timeout error during register', name: 'ApiService.register', error: e, stackTrace: stackTrace);
      print('❌ TIMEOUT ERROR in register: $e'); // Use print for immediate visibility
      throw Exception('ネットワークタイムアウトが発生しました');
    } on SocketException catch (e, stackTrace) {
      developer.log('Network error during register', name: 'ApiService.register', error: e, stackTrace: stackTrace);
      print('❌ NETWORK ERROR in register: $e'); // Use print for immediate visibility
      throw Exception('ネットワークエラーが発生しました: ${e.message}');
    } on FormatException catch (e, stackTrace) {
      developer.log('JSON parse error during register', name: 'ApiService.register', error: e, stackTrace: stackTrace);
       print('❌ JSON PARSE ERROR in register: $e'); // Use print for immediate visibility
      throw Exception('サーバーからの応答が不正です');
    } catch (e, stackTrace) {
      developer.log('Unexpected error during register', name: 'ApiService.register', error: e, stackTrace: stackTrace);
      print('❌ UNEXPECTED ERROR in register: $e'); // Use print for immediate visibility
      print('Stack trace: $stackTrace');
      throw Exception('予期しないエラーが発生しました: ${e.toString()}');
    }
  }


 // ... (getCameras, getEvents, getEventDetail, submitFeedback, getPeriodicReport) ...
 // [NOTE] The catch blocks in other methods were also updated to provide better logging
 // --- 2. 摄像头 (Cameras) ---
  Future<List<dynamic>> getCameras() async {
     developer.log('Fetching cameras from $baseUrl/cameras', name: 'ApiService.getCameras');
    try {
       developer.log('Inside try block, before http.get', name: 'ApiService.getCameras');
      final response = await http.get(
        Uri.parse('$baseUrl/cameras'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException catch (e, stackTrace) {
      developer.log('Network Error (SocketException) fetching cameras', name: 'ApiService.getCameras', error: e, stackTrace: stackTrace);
      throw Exception('ネットワーク接続を確認してください: ${e.message}');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Network Error (TimeoutException) fetching cameras', name: 'ApiService.getCameras', error: e, stackTrace: stackTrace);
      throw Exception('サーバーへの接続がタイムアウトしました。');
    } catch (e, stackTrace) {
       developer.log('Error fetching cameras', name: 'ApiService.getCameras', error: e, stackTrace: stackTrace);
      throw Exception('カメラリストの取得中にエラーが発生しました: ${e.toString()}');
    }
  }

  // --- 3. 事件 (Events) ---
  Future<Map<String, dynamic>> getEvents({DateTimeRange? dateRange, int page = 1, int limit = 20}) async {
    // ... (queryParams 和 uri 构建) ...
     final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (dateRange != null) ...{
        'start_date': dateRange.start.toIso8601String().split('T').first,
        'end_date': dateRange.end.toIso8601String().split('T').first,
      }
    };
    final uri = Uri.parse('$baseUrl/events').replace(queryParameters: queryParams);
     developer.log('Fetching events from $uri', name: 'ApiService.getEvents');

    try {
       developer.log('Inside try block, before http.get', name: 'ApiService.getEvents');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));

      // ... (response 处理) ...
      final body = utf8.decode(response.bodyBytes);
       developer.log('GetEvents Response Status: ${response.statusCode}, Body: $body', name: 'ApiService.getEvents');
      final jsonResponse = jsonDecode(body);

      if (response.statusCode == 200 && jsonResponse is Map && jsonResponse['success'] == true) {
        return jsonResponse as Map<String, dynamic>;
      } else {
         final message = (jsonResponse is Map ? jsonResponse['message'] : '未知错误') ?? 'イベントの取得に失败しました';
          developer.log('getEvents failed in ApiService', name: 'ApiService.getEvents', error: message);
        throw Exception(message);
      }
    } on SocketException catch (e, stackTrace) {
      developer.log('Network Error (SocketException) fetching events', name: 'ApiService.getEvents', error: e, stackTrace: stackTrace);
      throw Exception('ネットワーク接続を確認してください: ${e.message}');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Network Error (TimeoutException) fetching events', name: 'ApiService.getEvents', error: e, stackTrace: stackTrace);
      throw Exception('サーバーへの接続がタイムアウトしました。');
    } catch (e, stackTrace) {
       developer.log('Error fetching events', name: 'ApiService.getEvents', error: e, stackTrace: stackTrace);
       throw Exception('イベントの取得中にエラーが発生しました: ${e.toString()}');
    }
  }

Future<Map<String, dynamic>> getEventDetail(String eventId) async {
  print('🔵 Fetching event detail from $baseUrl/events/$eventId'); // 添加日志
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: _headers,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('⏱️ getEventDetail timeout for eventId: $eventId');
        throw TimeoutException('Event detail request timeout');
      },
    );

    print('✅ getEventDetail response: ${response.statusCode}');
    print('📄 Response body: ${utf8.decode(response.bodyBytes)}');

    // 手动处理响应，避免 _handleResponse 可能返回 null
    final body = utf8.decode(response.bodyBytes);
    final jsonResponse = jsonDecode(body);

    if (response.statusCode == 200 && jsonResponse is Map && jsonResponse['success'] == true) {
      // 确保返回的是 data 字段，且不为 null
      final data = jsonResponse['data'];
      if (data == null) {
        print('❌ Response data is null');
        throw Exception('サーバーからデータが返されませんでした');
      }
      return data as Map<String, dynamic>;
    } else {
      final message = (jsonResponse is Map ? jsonResponse['message'] : '未知错误') ?? 'イベント詳細の取得に失敗しました';
      print('❌ getEventDetail failed: $message');
      throw Exception(message);
    }

  } on TimeoutException catch (e, stackTrace) {
    print('❌ TIMEOUT ERROR in getEventDetail: $e');
    developer.log('Timeout error', name: 'ApiService.getEventDetail', error: e, stackTrace: stackTrace);
    throw Exception('ネットワークタイムアウトが発生しました');
  } on SocketException catch (e, stackTrace) {
    print('❌ NETWORK ERROR in getEventDetail: $e');
    developer.log('Network error', name: 'ApiService.getEventDetail', error: e, stackTrace: stackTrace);
    throw Exception('ネットワークエラーが発生しました: ${e.message}');
  } on FormatException catch (e, stackTrace) {
    print('❌ JSON PARSE ERROR in getEventDetail: $e');
    developer.log('JSON parse error', name: 'ApiService.getEventDetail', error: e, stackTrace: stackTrace);
    throw Exception('サーバーからの応答が不正です');
  } catch (e, stackTrace) {
    print('❌ UNEXPECTED ERROR in getEventDetail: $e');
    print('Stack trace: $stackTrace');
    developer.log('Unexpected error', name: 'ApiService.getEventDetail', error: e, stackTrace: stackTrace);
    throw Exception('予期しないエラーが発生しました: ${e.toString()}');
  }
}

  // --- 4. 反馈 (Feedback) ---
  Future<Map<String, dynamic>> submitFeedback({required String eventId, required int imageId, required String reason, required String notes}) async {
    // ... (url 和 body 构建) ...
     final url = '$baseUrl/feedback';
     final body = jsonEncode({
        'event_id': int.tryParse(eventId) ?? 0,
        'image_id': imageId,
        'reason': reason,
        'notes': notes,
      });
     developer.log('Submitting feedback to $url with body: $body', name: 'ApiService.submitFeedback');

    try {
       developer.log('Inside try block, before http.post', name: 'ApiService.submitFeedback');
      final response = await http.post(Uri.parse(url), headers: _headers, body: body).timeout(const Duration(seconds: 20));
      return await _handleResponse(response) as Map<String, dynamic>;
     } on SocketException catch (e, stackTrace) {
      developer.log('Network Error (SocketException) submitting feedback', name: 'ApiService.submitFeedback', error: e, stackTrace: stackTrace);
      throw Exception('ネットワーク接続を確認してください: ${e.message}');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Network Error (TimeoutException) submitting feedback', name: 'ApiService.submitFeedback', error: e, stackTrace: stackTrace);
      throw Exception('サーバーへの接続がタイムアウトしました。');
    } catch (e, stackTrace) {
       developer.log('Error submitting feedback', name: 'ApiService.submitFeedback', error: e, stackTrace: stackTrace);
       throw Exception('フィードバックの送信中にエラーが発生しました: ${e.toString()}');
    }
  }

  // --- 5. 定期报告 (Reports) ---
  Future<Map<String, dynamic>> getPeriodicReport({String type = 'monthly'}) async {
    // ... (uri 构建) ...
    final uri = Uri.parse('$baseUrl/reports').replace(queryParameters: {'type': type});
     developer.log('Fetching periodic report from $uri', name: 'ApiService.getPeriodicReport');

    try {
       developer.log('Inside try block, before http.get', name: 'ApiService.getPeriodicReport');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));

      // ... (response 处理) ...
       final body = utf8.decode(response.bodyBytes);
      developer.log('GetPeriodicReport Response Status: ${response.statusCode}, Body: $body', name: 'ApiService.getPeriodicReport');
      final jsonResponse = jsonDecode(body);

      if (response.statusCode == 200 && jsonResponse is Map && jsonResponse['success'] == true) {
        return jsonResponse as Map<String, dynamic>;
      } else {
         final message = (jsonResponse is Map ? jsonResponse['message'] : '未知错误') ?? 'レポートの取得に失败しました';
         developer.log('getPeriodicReport failed in ApiService', name: 'ApiService.getPeriodicReport', error: message);
        throw Exception(message);
      }
     } on SocketException catch (e, stackTrace) {
      developer.log('Network Error (SocketException) fetching periodic report', name: 'ApiService.getPeriodicReport', error: e, stackTrace: stackTrace);
      throw Exception('ネットワーク接続を確認してください: ${e.message}');
    } on TimeoutException catch (e, stackTrace) {
      developer.log('Network Error (TimeoutException) fetching periodic report', name: 'ApiService.getPeriodicReport', error: e, stackTrace: stackTrace);
      throw Exception('サーバーへの接続がタイムアウトしました。');
    } catch (e, stackTrace) {
       developer.log('Error fetching periodic report', name: 'ApiService.getPeriodicReport', error: e, stackTrace: stackTrace);
       throw Exception('レポートの取得中にエラーが発生しました: ${e.toString()}');
    }
  }

}

