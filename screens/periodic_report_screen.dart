import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class PeriodicReportScreen extends StatefulWidget {
  const PeriodicReportScreen({super.key});

  @override
  State<PeriodicReportScreen> createState() => _PeriodicReportScreenState();
}

class _PeriodicReportScreenState extends State<PeriodicReportScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final apiService = context.read<ApiService>();
    try {
      // 使用现有的 getPeriodicReport 方法，但它现在返回新的结构
      final data = await apiService.getPeriodicReport();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定期レポート'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('エラー: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_data == null) return const SizedBox.shrink();

    final String reportMonth = _data!['report_month'] ?? '不明な月';
    final List modelStats = _data!['model_stats'] ?? [];
    final int totalEvents = _data!['total_events'] ?? 0;
    final List equipmentDist = _data!['equipment_distribution'] ?? [];
    final List timeDist = _data!['time_distribution'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 标题
          Center(
            child: Text(
              '事故予測モデル $reportMonth 報告',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. 模型列表
          Text('モデル稼働状況', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...modelStats.map((model) => _buildModelCard(model)).toList(),
          
          const SizedBox(height: 32),

          // 3. 统计数据 - 总数
          Text('統計データ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildStatCard('今月の検出イベント総数', '$totalEvents 件'),

          const SizedBox(height: 24),

          // 4. 饼图 - 游具种类
          Text('遊具別発生比率', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: equipmentDist.isEmpty 
                ? const Center(child: Text('データなし')) 
                : PieChart(
                    PieChartData(
                      sections: _generatePieSections(equipmentDist),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          _buildLegend(equipmentDist),

          const SizedBox(height: 32),

          // 5. 饼图 - 时间段
          Text('時間帯別発生比率', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: timeDist.isEmpty 
                ? const Center(child: Text('データなし'))
                : PieChart(
                    PieChartData(
                      sections: _generatePieSections(timeDist, isTime: true),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          _buildLegend(timeDist, isTime: true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final bool isActive = model['status'] == 'active';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive ? const BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '稼働中',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('F2-Score: ${model['f2_score']}'),
                Text('起動回数: ${model['activation_count']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(List data, {bool isTime = false}) {
    return data.asMap().entries.map((entry) {
      final int index = entry.key;
      final Map item = entry.value;
      final double value = (item['value'] as num).toDouble();
      final String title = '${item['value']}';
      
      return PieChartSectionData(
        color: _getColor(index, isTime),
        value: value,
        title: title,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List data, {bool isTime = false}) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: data.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map item = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColor(index, isTime),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(item['label']),
          ],
        );
      }).toList(),
    );
  }

  Color _getColor(int index, bool isTime) {
    const colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.green,
    ];
    // 时间图表使用不同的色系区分
    if (isTime) {
      const timeColors = [
        Color(0xFF64B5F6), // 0-12 Morning
        Color(0xFFFFD54F), // 12-14 Noon
        Color(0xFFFFB74D), // 14-16 Afternoon
        Color(0xFFE57373), // 16-18 Late Afternoon
        Color(0xFF9575CD), // 18-24 Night
      ];
      return timeColors[index % timeColors.length];
    }
    return colors[index % colors.length];
  }
}