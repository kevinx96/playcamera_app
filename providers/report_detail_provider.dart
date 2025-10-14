import 'package:flutter/material.dart';
import '../models/report_detail.dart';

class ReportDetailProvider with ChangeNotifier {
  ReportDetail? _reportDetail;
  bool _isLoading = true;
  String? _error;
  int _selectedImageIndex = 0;


  bool _isSubmitting = false;
  bool _isSubmitSuccess = false;

  ReportDetail? get reportDetail => _reportDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedImageIndex => _selectedImageIndex;
  bool get isSubmitting => _isSubmitting;
  bool get isSubmitSuccess => _isSubmitSuccess;


  Future<void> fetchReportDetail(int caseId) async {
    _isLoading = true;
    _error = null;
    _isSubmitSuccess = false; 
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _reportDetail = _generateDemoDetail(caseId);
    } catch (e) {
      _error = "レポート詳細の取得に失敗しました。";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void setSelectedImageIndex(int index) {
    if (index != _selectedImageIndex) {
      _selectedImageIndex = index;
      notifyListeners();
    }
  }

  // 誤検知報告を送信
  Future<void> submitFeedback(String reason) async {
    _isSubmitting = true;
    notifyListeners();


    await Future.delayed(const Duration(seconds: 2));

    _isSubmitting = false;
    _isSubmitSuccess = true;
    notifyListeners();
  }
  

  ReportDetail _generateDemoDetail(int caseId) {
    return ReportDetail(
      caseId: caseId,
      category: '滑り台',
      timestamp: DateTime(2025, 9, 25, 14, 32, 10),
      images: [
        ImageDetail(
          imageId: 1001,
          score: 45,
          deductionItems: ["減点: 不適切な座り姿勢（腰が膝より低い）", "減点: 体が横向きの状態"],
        ),
        ImageDetail(
          imageId: 1002,
          score: 40,
          deductionItems: ["減点: 立ち姿勢を検出"],
        ),
        ImageDetail(
          imageId: 1003,
          score: 20,
          deductionItems: ["減点: 立ち乗りかつ大きく揺らす動作"],
        ),
        ImageDetail(
          imageId: 1004,
          score: 50,
          deductionItems: ["減点: 頭が腰より低い状態"],
        ),
        ImageDetail(
          imageId: 1005,
          score: 30,
          deductionItems: ["減点: 頭から滑る危険な動作"],
        ),
      ],
    );
  }
}
