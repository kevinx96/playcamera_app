import 'dart:math';
import 'package:flutter/material.dart';
import '../models/report_case.dart';

class ReportProvider with ChangeNotifier {
  List<ReportCase> _allReports = [];
  List<ReportCase> _filteredReports = [];
  bool _isLoading = false;
  String? _error;
  DateTimeRange? _selectedDateRange;

  List<ReportCase> get reports => _filteredReports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  ReportProvider() {
    _generateAllDummyReports();
  }

  void _generateAllDummyReports() {
    final random = Random();
    final now = DateTime.now();
    _allReports = List.generate(200, (index) {
      final category = ['滑り台', 'ブランコ', 'ジャングルジム'][random.nextInt(3)];
      final score = random.nextInt(61);
      final timestamp = now.subtract(Duration(days: random.nextInt(365), hours: random.nextInt(24)));
      return ReportCase(
        id: index,
        score: score,
        category: category,
        timestamp: timestamp,
      );
    });
    // Sort all reports by date initially
    _allReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> fetchReports({DateTimeRange? dateRange}) async {
    _isLoading = true;
    
    // Set default date range if not provided
    _selectedDateRange = dateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );

    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      _filteredReports = _allReports.where((report) {
        // Normalize dates to ignore time component for comparison
        final reportDate = DateTime(report.timestamp.year, report.timestamp.month, report.timestamp.day);
        final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day);
        
        return !reportDate.isBefore(startDate) && !reportDate.isAfter(endDate);
      }).toList();
      
      _error = null;
    } catch (e) {
      _error = "レポートの取得に失敗しました: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

