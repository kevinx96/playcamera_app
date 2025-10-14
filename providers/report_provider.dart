import 'dart:math';
import 'package:flutter/material.dart';
import '../models/report_case.dart';

class ReportProvider with ChangeNotifier {
  final List<ReportCase> _allReports; 
  List<ReportCase> _filteredReports = []; 
  bool _isLoading = true;
  String? _error;

  List<ReportCase> get reports => _filteredReports;
  bool get isLoading => _isLoading;
  String? get error => _error;


  ReportProvider() : _allReports = _generateDemoCases(50);


  Future<void> fetchReports({DateTimeRange? dateRange}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ネットワーク通信をシミュレート
      await Future.delayed(const Duration(milliseconds: 500));

      DateTimeRange rangeToFilter;
      if (dateRange == null) {
        final now = DateTime.now();
        rangeToFilter = DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      } else {
        rangeToFilter = dateRange;
      }

      _filteredReports = _allReports.where((report) {
        final inclusiveEndDate = DateTime(rangeToFilter.end.year, rangeToFilter.end.month, rangeToFilter.end.day, 23, 59, 59);
        return report.timestamp.isAfter(rangeToFilter.start.subtract(const Duration(seconds: 1))) && 
               report.timestamp.isBefore(inclusiveEndDate);
      }).toList();

      _filteredReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    } catch (e) {
      _error = "レポートの取得に失敗しました。";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static List<ReportCase> _generateDemoCases(int count) {
    final random = Random();
    final categories = ['滑り台', 'ブランコ', 'ジャングルジム'];
    
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final differenceInSeconds = now.difference(oneYearAgo).inSeconds;

    return List.generate(count, (index) {
      final randomSeconds = random.nextInt(differenceInSeconds);
      final randomTimestamp = oneYearAgo.add(Duration(seconds: randomSeconds));

      return ReportCase(
        id: 100 + index,
        score: random.nextInt(60), // 0から59までのランダムなスコア
        timestamp: randomTimestamp,
        category: categories[random.nextInt(categories.length)],
        thumbnailUrl: null, // 画像は後で実装
      );
    });
  }
}

