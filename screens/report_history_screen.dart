import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/report_provider.dart';
import '../models/report_case.dart';
import 'report_detail_screen.dart';
import '../providers/report_detail_provider.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // 画面が初期化された時にデータを取得する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final provider = context.read<ReportProvider>();
    final initialRange =
        provider.selectedDateRange ?? // Use existing range if available
            DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            );

    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024), // A more reasonable start date
      lastDate: DateTime.now(),   // Can't select future dates
      initialDateRange: initialRange,
    );

    if (newRange != null) {
      provider.fetchReports(dateRange: newRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildDateSelector(context, provider),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Text(provider.error!))
                      : provider.reports.isEmpty
                          ? const Center(
                              child: Text('指定された期間のレポートはありません。',
                                  style: TextStyle(fontSize: 16)))
                          : _buildReportList(provider.reports),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelector(
      BuildContext context, ReportProvider provider) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final range = provider.selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () => _selectDateRange(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today,
                  color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                '${dateFormat.format(range.start)} - ${dateFormat.format(range.end)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportList(List<ReportCase> reports) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final reportCase = reports[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => ReportDetailProvider(),
                    child: ReportDetailScreen(
                        caseId: reportCase.id
                            .toString()),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'スコア: ${reportCase.score}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: reportCase.score < 50
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(reportCase.category,
                              style: const TextStyle(fontSize: 12)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(reportCase.timestamp),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

