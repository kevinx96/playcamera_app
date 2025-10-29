import 'package:flutter/material.dart';
import '../models/report_case.dart'; // 导入正确的 ReportCase 模型
import '../services/api_service.dart';

// 这是 ReportProvider 正确的类定义
class ReportProvider with ChangeNotifier {
  final ApiService _apiService; // 将由 ProxyProvider 注入

  List<ReportCase> _reports = [];
  bool _isLoading = false;
  String? _error;
  DateTimeRange _selectedDateRange;
  Map<String, dynamic>? _paginationInfo;

  List<ReportCase> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTimeRange get selectedDateRange => _selectedDateRange;

  // 构造函数现在接收 ApiService
  ReportProvider(this._apiService)
      : _selectedDateRange = DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ) {
    // 构造函数中自动获取一次数据
    // 注意：如果 ApiService 初始时没有 token, 这次 fetch 会失败
    // 更好的做法是在 MainScreen 或 ReportHistoryScreen 的 initState 中调用
    // fetchReports(); 
    // ^ 我们在 report_history_screen.dart 的 initState 中调用它，所以这里注释掉
  }

  Future<void> fetchReports({DateTimeRange? dateRange, int page = 1}) async {
    // 如果提供了新的日期范围，则更新
    if (dateRange != null) {
      _selectedDateRange = dateRange;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> response = await _apiService.getEvents(
        dateRange: _selectedDateRange,
        page: page,
      );

      final List<dynamic> responseData = response['data'] as List<dynamic>;
      _paginationInfo = response['pagination'] as Map<String, dynamic>;

      _reports = responseData
          .map((data) => ReportCase.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = "レポートの取得に失敗しました: ${e.toString()}";
      _reports = []; // 发生错误时清空列表
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

