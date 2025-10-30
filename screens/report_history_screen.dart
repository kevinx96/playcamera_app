import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/report_provider.dart';
import '../models/report_case.dart'; // [MODIFIED] 确保我们使用的是更新后的 report_case.dart
import 'report_detail_screen.dart';
import '../providers/report_detail_provider.dart';
import '../services/api_service.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final provider = context.read<ReportProvider>();
    final initialRange = provider.selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      initialDateRange: initialRange,
    );

    if (newRange != null) {
      provider.fetchReports(dateRange: newRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildDateSelector(context, provider),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(child: Text('エラー: ${provider.error!}'))
                      : provider.reports.isEmpty
                          ? const Center(
                              child: Text('指定された期間のレポートはありません。',
                                  style: TextStyle(fontSize: 16)))
                          : _buildReportList(provider.reports, apiService),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelector(BuildContext context, ReportProvider provider) {
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
              const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
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

  Widget _buildReportList(List<ReportCase> reports, ApiService apiService) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final reportCase = reports[index];

        // [MODIFIED] 移除了所有旧的 debug print

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => ReportDetailProvider(apiService),
                    child: ReportDetailScreen(caseId: reportCase.id.toString()),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // [MODIFIED] 恢复为简洁的缩略图显示
                  Container(
                    width: 80,
                    height: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // [MODIFIED] 直接使用 reportCase.iconUrl，因为 api.py 和 report_case.dart 都已更新
                    child: Image.network(
                      reportCase.iconUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                color: Colors.red, size: 30),
                            SizedBox(height: 4),
                            Text('エラー',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.red)),
                          ],
                        );
                      },
                    ),
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
                          label: Text(reportCase.equipmentType,
                              style: const TextStyle(fontSize: 12)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(reportCase.eventTime),
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

  // [REMOVED] 移除了不再需要的 _buildThumbnailWithDebug 方法
}

