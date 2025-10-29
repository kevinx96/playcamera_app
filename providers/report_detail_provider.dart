import 'package:flutter/material.dart';
import '../models/report_detail.dart';
import '../services/api_service.dart';

enum FeedbackStatus { idle, loading, success }

class ReportDetailProvider with ChangeNotifier {
  final ApiService _apiService;

  ReportDetail? _reportDetail;
  bool _isLoading = true;
  String? _error;

  // Feedback state
  FeedbackStatus _feedbackStatus = FeedbackStatus.idle;
  String _selectedReason = '人が映っていない'; // デフォルト値
  String _feedbackNotes = '';
  int? _currentImageIdForFeedback;

  ReportDetail? get reportDetail => _reportDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FeedbackStatus get feedbackStatus => _feedbackStatus;
  String get selectedReason => _selectedReason;
  String get feedbackNotes => _feedbackNotes;
  int? get currentImageIdForFeedback => _currentImageIdForFeedback;

  final List<String> errorReasons = [
    '人が映っていない',
    '危険な行動がない',
    '危険の判断に誤りがある',
    '危険判断の種類に誤りがある',
    '遅延が発生する／画像が破損している／画質が悪い／画像が全く合っていない',
  ];

  ReportDetailProvider(this._apiService);

  void resetFeedbackState() {
    _feedbackStatus = FeedbackStatus.idle;
    _feedbackNotes = '';
    _selectedReason = errorReasons.first;
    _currentImageIdForFeedback = null;
    notifyListeners();
  }

  void updateSelectedReason(String? newValue) {
    if (newValue != null) {
      _selectedReason = newValue;
      notifyListeners();
    }
  }

  void updateFeedbackNotes(String notes) {
    _feedbackNotes = notes;
    notifyListeners();
  }

  void prepareFeedback(int imageId) {
    _currentImageIdForFeedback = imageId;
    _feedbackStatus = FeedbackStatus.idle;
    notifyListeners();
  }


Future<void> fetchReportDetail(String caseId) async {
  _isLoading = true;
  _error = null;
  _reportDetail = null;
  notifyListeners();

  try {
    print('🔵 Provider: Fetching report detail for caseId: $caseId'); // 添加日志
    
    final Map<String, dynamic> data = await _apiService.getEventDetail(caseId);
    
    print('✅ Provider: Received data: $data'); // 添加日志
    
    if (data == null) {
      throw Exception('サーバーからデータが返されませんでした');
    }
    
    _reportDetail = ReportDetail.fromJson(data);
    print('✅ Provider: ReportDetail parsed successfully'); // 添加日志
    
  } catch (e, stackTrace) {
    print('❌ Provider ERROR: $e');
    print('Stack trace: $stackTrace');
    _error = 'レポート詳細の取得に失敗しました: ${e.toString()}';
    _reportDetail = null;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> submitFeedback({
    required String eventId, // [FIX] APIサービスに合わせて String に変更
    required int imageId,
    required String reason,
    required String notes,
  }) async {
    _feedbackStatus = FeedbackStatus.loading;
    notifyListeners();

    try {
      // [FIX] 必要なパラメータをすべて渡す
      await _apiService.submitFeedback(
        eventId: eventId,
        imageId: imageId,
        reason: reason,
        notes: notes,
      );
      _feedbackStatus = FeedbackStatus.success;
    } catch (e) {
      _error = "フィードバックの送信に失敗しました: ${e.toString()}";
      _feedbackStatus = FeedbackStatus.idle; // 失敗したらアイドル状態に戻す
    } finally {
      notifyListeners();
    }
  }
}

