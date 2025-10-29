import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

// [MODIFIED] 转换为 StatefulWidget 以管理状态
class PeriodicReportScreen extends StatefulWidget {
  const PeriodicReportScreen({super.key});

  @override
  State<PeriodicReportScreen> createState() => _PeriodicReportScreenState();
}

class _PeriodicReportScreenState extends State<PeriodicReportScreen> {
  // --- 状态变量 ---
  bool _isLoading = true;
  String? _error;
  // 用于存储从 API G/api/reports 返回的完整 JSON 对象
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    // 页面加载时自动获取数据
    _fetchReportData();
  }

  // --- 数据获取方法 ---
  Future<void> _fetchReportData() async {
    // 使用 Provider.of 获取由 ProxyProvider 提供的、已认证的 ApiService 实例
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final data = await apiService.getPeriodicReport();
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "レポートの読み込みに失敗しました: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // --- 主构建方法 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定期レポート'),
        actions: [
          // 添加一个刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchReportData,
          ),
        ],
      ),
      body: _buildBody(), // [MODIFIED] 使用 _buildBody 来处理状态
    );
  }

  // --- 状态处理 ---
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center),
        ),
      );
    }
    if (_reportData == null || _reportData!['success'] != true) {
      return const Center(child: Text('レポートデータを取得できませんでした。'));
    }

    // --- 数据解析 ---
    // [MODIFIED] 从 _reportData 中解析数据
    // 我们假设 _reportData 包含了 API 规范中定义的所有键
    final headerData = _reportData!['dashboard_header'] as Map<String, dynamic>;
    final metricsData = _reportData!['model_performance'] as Map<String, dynamic>;
    final statsData = _reportData!['incident_stats'] as Map<String, dynamic>;
    final comparisonData =
        _reportData!['model_comparison'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // [MODIFIED] 传递解析后的数据
          _buildHeader(context, headerData),
          const SizedBox(height: 24),
          _buildModelMetrics(context, metricsData),
          const SizedBox(height: 24),
          _buildIncidentStats(context, statsData),
          const SizedBox(height: 24),
          _buildModelComparisonTable(context, comparisonData),
        ],
      ),
    );
  }

  // --- 各セクションのビルドメソッド ---

  // ヘッダー
  Widget _buildHeader(
      BuildContext context, Map<String, dynamic> headerData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D6EFD), Color(0xFF6F42C1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            headerData['title'] ?? '公園内事故予測モデル 分析ダッシュボード',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            // [MODIFIED]
            '現在稼働中のモデル: ${headerData['current_model'] ?? 'N/A'}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // モデルの評価指標セクション
  Widget _buildModelMetrics(
      BuildContext context, Map<String, dynamic> metricsData) {
    // [MODIFIED] 从 metricsData 解析数据
    // 使用 .map 将 List<dynamic> 安全转换为 List<double>
    final precision = (metricsData['precision_data'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final recall = (metricsData['recall_data'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final f1score = (metricsData['f1_score_data'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return Column(
      children: [
        _buildChartCard(
          context,
          title: 'モデルの適合率 (Precision)',
          chart: _buildLineChart(
            data: precision.isNotEmpty ? precision : [0], // [MODIFIED]
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          context,
          title: 'モデルの再現率 (Recall)',
          chart: _buildLineChart(
            data: recall.isNotEmpty ? recall : [0], // [MODIFIED]
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          context,
          title: 'モデルのF1-Score',
          chart: _buildLineChart(
            data: f1score.isNotEmpty ? f1score : [0], // [MODIFIED]
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  // 事故統計セクション
  Widget _buildIncidentStats(
      BuildContext context, Map<String, dynamic> statsData) {
    // [MODIFIED] 解析数据
    final totalIncidents = statsData['total_incidents']?.toString() ?? '0';
    final categoryData =
        (statsData['category_distribution'] as List).cast<Map<String, dynamic>>();
    final hourlyData =
        (statsData['hourly_distribution'] as List).cast<Map<String, dynamic>>();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildMetricCard(
                context,
                label: '今月の事故発生件数',
                value: totalIncidents, // [MODIFIED]
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildChartCard(
                context,
                title: '事故の分類',
                chart: _buildPieChart(categoryData), // [MODIFIED]
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          context,
          title: '時間帯別の事故発生状況',
          chart: _buildBarChart(hourlyData), // [MODIFIED]
        ),
      ],
    );
  }

  // モデル比較テーブル
  Widget _buildModelComparisonTable(
      BuildContext context, Map<String, dynamic> comparisonData) {
    // [MODIFIED] 解析数据
    final models =
        (comparisonData['models'] as List).cast<Map<String, dynamic>>();

    return _buildDashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comparisonData['title'] ?? '最近3つのモデルのF1-Score比較',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // [MODIFIED] 动态生成表格行
            ...models.asMap().entries.map((entry) {
              final model = entry.value;
              final bool isLast = entry.key == models.length - 1;
              final status = model['status'] ?? '旧';
              final progress = (model['f1_score'] as num? ?? 0.0).toDouble();

              return Column(
                children: [
                  _buildComparisonTableRow(
                    context,
                    modelName: model['name'] ?? 'N/A',
                    score: '${(progress * 100).toStringAsFixed(2)}%',
                    status: status,
                    statusColor:
                        status == '稼働中' ? Colors.green : Colors.grey,
                    progress: progress,
                    progressColor:
                        status == '稼働中' ? Colors.green : Colors.blueGrey,
                  ),
                  if (!isLast) const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- 共通・個別ウィジェット ---

  // ダッシュボードカードの共通スタイル
  Widget _buildDashboardCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  // チャート用のカード
  Widget _buildChartCard(BuildContext context,
      {required String title, required Widget chart}) {
    return _buildDashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  // 数値表示用のカード
  Widget _buildMetricCard(BuildContext context,
      {required String label, required String value}) {
    return _buildDashboardCard(
      child: Container(
        height: 264, // PieChartの高さに合わせる
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 比較テーブルの行
  Widget _buildComparisonTableRow(
    BuildContext context, {
    required String modelName,
    required String score,
    required String status,
    required Color statusColor,
    required double progress,
    required Color progressColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(modelName, style: Theme.of(context).textTheme.titleMedium),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 20,
                    backgroundColor: progressColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(score,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // --- チャートの定義 ---

  // 折れ線グラフ
  Widget _buildLineChart({required List<double> data, required Color color}) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  // 円グラフ
  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('データがありません'));

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        // [MODIFIED] 动态生成饼图
        sections: data.map((item) {
          final value = (item['value'] as num? ?? 0.0).toDouble();
          return PieChartSectionData(
              value: value,
              title: '${value.toStringAsFixed(0)}%', // API が % を返すと仮定
              color: _getColorForCategory(item['label'] ?? ''), // ヘルパーで色を決定
              radius: 50,
              titleStyle: const TextStyle(fontWeight: FontWeight.bold));
        }).toList(),
      ),
    );
  }

  // 棒グラフ
  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('データがありません'));

    final labels = data.map((item) => item['label'] as String? ?? '').toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) return Container();
                // [MODIFIED] 动态设置标签
                return Text(
                  labels[index].replaceAll('時', ''), // '12-14時' -> '12-14'
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        // [MODIFIED] 动态生成柱状图
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = (item['value'] as num? ?? 0.0).toDouble();
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(
                toY: value,
                color: _getColorForCategory(item['label'] ?? '', index),
                width: 20)
          ]);
        }).toList(),
      ),
    );
  }

  // [ADDED] 动态颜色的辅助函数
  Color _getColorForCategory(String category, [int index = 0]) {
    switch (category.toLowerCase()) {
      case 'slide':
      case '滑り台':
        return Colors.purple;
      case 'swing':
      case 'ブランコ':
        return Colors.orange;
      case 'junglegym':
      case 'ジャングルジム':
        return Colors.teal;
      default:
        // 棒グラフや円グラフのフォールバック
        final colors = [
          Colors.amber,
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.purple
        ];
        return colors[index % colors.length];
    }
  }
}

