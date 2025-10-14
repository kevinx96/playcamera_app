import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// メインの画面ウィジェット
class PeriodicReportScreen extends StatelessWidget {
  const PeriodicReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定期レポート'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildModelMetrics(context),
            const SizedBox(height: 24),
            _buildIncidentStats(context),
            const SizedBox(height: 24),
            _buildModelComparisonTable(context),
          ],
        ),
      ),
    );
  }

  // --- 各セクションのビルドメソッド ---

  // ヘッダー
  Widget _buildHeader(BuildContext context) {
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
            '公園内事故予測モデル 分析ダッシュボード',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '現在稼働中のモデル: Model-2',
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
  Widget _buildModelMetrics(BuildContext context) {
    return Column(
      children: [
        _buildChartCard(
          context, // [FIXED] Pass context
          title: 'モデルの適合率 (Precision)',
          chart: _buildLineChart(
            data: [60, 90, 70, 85],
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          context, // [FIXED] Pass context
          title: 'モデルの再現率 (Recall)',
          chart: _buildLineChart(
            data: [60, 40, 50, 70],
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          context, // [FIXED] Pass context
          title: 'モデルのF1-Score',
          chart: _buildLineChart(
            data: [60.0, 56.25, 58.33, 76.67], // 計算済みデータ
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  // 事故統計セクション
  Widget _buildIncidentStats(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildMetricCard(
                context, // [FIXED] Pass context
                label: '今月の事故発生件数',
                value: '15',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildChartCard(
                context, // [FIXED] Pass context
                title: '事故の分類',
                chart: _buildPieChart(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          context, // [FIXED] Pass context
          title: '時間帯別の事故発生状況',
          chart: _buildBarChart(),
        ),
      ],
    );
  }

  // モデル比較テーブル
  Widget _buildModelComparisonTable(BuildContext context) {
    return _buildDashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最近3つのモデルのF1-Score比較',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildComparisonTableRow(
              context,
              modelName: 'model-prototype',
              score: '76.32%',
              status: '旧',
              statusColor: Colors.grey,
              progress: 0.7632,
              progressColor: Colors.blueGrey,
            ),
            const Divider(),
            _buildComparisonTableRow(
              context,
              modelName: 'model-1',
              score: '79.87%',
              status: '旧',
              statusColor: Colors.grey,
              progress: 0.7987,
              progressColor: Colors.blue,
            ),
            const Divider(),
            _buildComparisonTableRow(
              context,
              modelName: 'model-2',
              score: '80.12%',
              status: '稼働中',
              statusColor: Colors.green,
              progress: 0.8012,
              progressColor: Colors.green,
            ),
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
  Widget _buildChartCard(BuildContext context, // [FIXED] Accept context
      {required String title,
      required Widget chart}) {
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
  Widget _buildMetricCard(BuildContext context, // [FIXED] Accept context
      {required String label,
      required String value}) {
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
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
              value: 40,
              title: '40%',
              color: Colors.purple,
              radius: 50,
              titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
          PieChartSectionData(
              value: 33.3,
              title: '33%',
              color: Colors.orange,
              radius: 50,
              titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
          PieChartSectionData(
              value: 20,
              title: '20%',
              color: Colors.teal,
              radius: 50,
              titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
          PieChartSectionData(
              value: 6.7,
              title: '7%',
              color: Colors.grey,
              radius: 50,
              titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 棒グラフ
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                ['12-14時', '14-16時', '16-18時'][value.toInt()],
                style: const TextStyle(fontSize: 12),
              ),
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: 4, color: Colors.amber, width: 20)
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: 4, color: Colors.blue, width: 20)
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(toY: 7, color: Colors.red, width: 20)
          ]),
        ],
      ),
    );
  }
}

