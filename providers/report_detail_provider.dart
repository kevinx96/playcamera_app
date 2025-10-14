import 'package:flutter/material.dart';
import '../models/report_detail.dart';

class ReportDetailProvider with ChangeNotifier {
  ReportDetail? _reportDetail;
  bool _isLoading = false;
  String? _error;

  String? _selectedReason;
  bool _isSubmitting = false;
  bool _submissionSuccess = false;

  final List<String> feedbackReasons = [
    '人が映っていない',
    '危険な行動がない',
    '危険の判断に誤りがある',
    '危険判断の種類に誤りがある',
    '遅延が発生する／画像が破損している／画質が悪い／画像が全く合っていない'
  ];

  ReportDetail? get reportDetail => _reportDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedReason => _selectedReason;
  bool get isSubmitting => _isSubmitting;
  bool get submissionSuccess => _submissionSuccess;

  Future<void> fetchReportDetail(String caseId) async {
    _isLoading = true;
    // Reset submission status when fetching new detail
    _submissionSuccess = false;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _reportDetail = _getDummyReportDetail(caseId);
      _error = null;
    } catch (e) {
      _error = "詳細の取得に失敗しました: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitFeedback(
      {required String reason, required String notes}) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      print('フィードバック送信: 理由="$reason", 詳細="$notes"');
      _submissionSuccess = true;
    } catch (e) {
      // Handle error
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void selectReason(String? reason) {
    if (_selectedReason != reason) {
      _selectedReason = reason;
      notifyListeners();
    }
  }

  void resetFeedbackForm() {
    _selectedReason = null;
    _submissionSuccess = false;
    _isSubmitting = false;
  }

  // --- Dummy Data ---
  ReportDetail _getDummyReportDetail(String caseId) {
    return ReportDetail(
      caseId: caseId,
      category: '滑り台',
      score: 35,
      timestamp: DateTime(2025, 9, 15, 14, 30, 10),
      imageCount: 5,
      images: [
        ImageDetail(
          imageId: 'slide_01',
          score: 40,
          timestamp: DateTime(2025, 9, 15, 14, 30, 8),
          deductionItems: ['減点: 不適切な座り姿勢（腰が膝より低い）', '減点: 立ち姿勢を検出'],
        ),
        ImageDetail(
          imageId: 'slide_02',
          score: 35,
          timestamp: DateTime(2025, 9, 15, 14, 30, 10),
          deductionItems: ['減点: 不適切な座り姿勢（腰が膝より低い）', '減点: 立ち姿勢を検出'],
        ),
        ImageDetail(
          imageId: 'slide_03',
          score: 55,
          timestamp: DateTime(2025, 9, 15, 14, 30, 12),
          deductionItems: ['減点: 体が横向きの状態', '減点: 不適切な座り姿勢（膝が伸びすぎ）'],
        ),
        ImageDetail(
          imageId: 'slide_04',
          score: 20,
          timestamp: DateTime(2025, 9, 15, 14, 30, 14),
          deductionItems: ['減点: 頭から滑る危険な動作'],
        ),
        ImageDetail(
          imageId: 'slide_05',
          score: 85,
          timestamp: DateTime(2025, 9, 15, 14, 30, 16),
          deductionItems: ['減点: 不適切な座り姿勢（膝が伸びすぎ）'],
        ),
      ],
    );
  }
}

