import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/report_case.dart';
import '../providers/report_provider.dart';
import 'report_detail_screen.dart';

import '../providers/report_detail_provider.dart'; 

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false)
          .fetchReports(dateRange: _selectedDateRange);
    });
  }

  Future<void> _selectDateRange() async {
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
      Provider.of<ReportProvider>(context, listen: false)
          .fetchReports(dateRange: _selectedDateRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Column(
      children: [
        _buildDateSelector(context),
        Expanded(
          child: _buildReportList(context, reportProvider),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final String displayRange = _selectedDateRange == null
        ? '日付を選択'
        : '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}';
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('期間', style: Theme.of(context).textTheme.labelSmall),
                  Text(
                    displayRange,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('変更'),
              onPressed: _selectDateRange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(BuildContext context, ReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (provider.reports.isEmpty) {
      return const Center(child: Text('この期間のレポートはありません。'));
    }

    return ListView.builder(
      itemCount: provider.reports.length,
      itemBuilder: (context, index) {
        final reportCase = provider.reports[index];
        return _buildCaseItem(context, reportCase);
      },
    );
  }

  Widget _buildCaseItem(BuildContext context, ReportCase reportCase) {
    final Color scoreColor = reportCase.score < 20
        ? Colors.orange
        : reportCase.score < 40
            ? Colors.deepOrange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          // どのケースをタップしても詳細画面に遷移
          Navigator.of(context).push(MaterialPageRoute(
            // 詳細画面に遷移する際にProviderを渡す
            builder: (_) => ChangeNotifierProvider(
              create: (_) => ReportDetailProvider(),
              child: ReportDetailScreen(caseId: reportCase.id),
            ),
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カテゴリ: ${reportCase.category}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '発生時刻: ${DateFormat('yyyy/MM/dd HH:mm').format(reportCase.timestamp)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    'スコア',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  Text(
                    reportCase.score.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

