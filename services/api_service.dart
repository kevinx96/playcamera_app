import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://your-api-server.com/api';
  
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // authorise
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('ログインに失敗しました');
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('登録に失敗しました');
    }
  }

  // camera
  Future<List<dynamic>> getCameras() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cameras'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('カメラリストの取得に失敗しました');
    }
  }

  Future<String> getCameraStreamUrl(int cameraId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cameras/$cameraId/stream'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['stream_url'];
    } else {
      throw Exception('ストリームURLの取得に失敗しました');
    }
  }

  // event
  Future<List<dynamic>> getEvents({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('イベントリストの取得に失敗しました');
    }
  }

  Future<Map<String, dynamic>> getEventDetail(int eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('イベント詳細の取得に失敗しました');
    }
  }

  Future<void> submitFeedback(int imageId, String? notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: _headers,
      body: jsonEncode({
        'image_id': imageId,
        'notes': notes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('フィードバックの送信に失敗しました');
    }
  }

  // report
  Future<List<dynamic>> getReports({String? type}) async {
    String url = '$baseUrl/reports';
    if (type != null) {
      url += '?type=$type';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('レポートリストの取得に失敗しました');
    }
  }

  Future<Map<String, dynamic>> getReportDetail(int reportId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('レポート詳細の取得に失敗しました');
    }
  }
}