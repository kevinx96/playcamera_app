import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/report_detail.dart';
import '../providers/report_detail_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final int caseId;
  const ReportDetailScreen({super.key, required this.caseId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportDetailProvider>(context, listen: false)
          .fetchReportDetail(widget.caseId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  void _showFeedbackDialog() {
    final reportDetailProvider =
        Provider.of<ReportDetailProvider>(context, listen: false);
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // ChangeNotifierProvider to change dialog
        return ChangeNotifierProvider.value(
          value: reportDetailProvider,
          child: Consumer<ReportDetailProvider>(
            builder: (context, provider, child) {
              if (provider.isSubmitSuccess) {
                return AlertDialog(
                  title: const Text('フィードバック送信完了'),
                  content: const Text('ご報告ありがとうございました。'),
                  actions: [
                    TextButton(
                      child: const Text('確認'),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                );
              }

              if (provider.isSubmitting) {
                return const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 24),
                      Text("送信中..."),
                    ],
                  ),
                );
              }

              return AlertDialog(
                title: const Text('誤検知を報告'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      const Text('この検知は誤りですか？理由を記入してください。'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: feedbackController,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: '例：誰も遊んでいませんでした。',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('キャンセル'),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  FilledButton(
                    child: const Text('送信'),
                    onPressed: () {
                      provider.submitFeedback(feedbackController.text);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('レポート詳細 (ID: ${widget.caseId})'),
      ),
      body: Consumer<ReportDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null || provider.reportDetail == null) {
            return Center(child: Text(provider.error ?? 'エラーが発生しました。'));
          }

          final reportDetail = provider.reportDetail!;
          final selectedImageDetail =
              reportDetail.images[provider.selectedImageIndex];

          return Column(
            children: [
              
              Expanded(
                child: _buildImageSlider(context, reportDetail.images),
              ),
              
              Expanded(
                child: _buildImageDetails(
                    context, reportDetail, selectedImageDetail),
              ),
            ],
          );
        },
      ),
    );
  }

  // slider
  Widget _buildImageSlider(BuildContext context, List<ImageDetail> images) {
    final provider = context.read<ReportDetailProvider>();
    final selectedIndex = context.watch<ReportDetailProvider>().selectedImageIndex;

    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                provider.setSelectedImageIndex(index);
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.grey, size: 80),
                  ),
                );
              },
            ),
          ),
          // image
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // details
  Widget _buildImageDetails(BuildContext context, ReportDetail reportDetail,
      ImageDetail imageDetail) {
    final textTheme = Theme.of(context).textTheme;
    final isFeedbackSubmitted = context.watch<ReportDetailProvider>().isSubmitSuccess;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow('発生時刻',
              DateFormat('yyyy/MM/dd HH:mm').format(reportDetail.timestamp)),
          _buildInfoRow('カテゴリ', reportDetail.category),
          _buildInfoRow('スコア', imageDetail.score.toString(),
              isHighlight: true),
          _buildInfoRow('検出された画像枚数', '${reportDetail.images.length} 枚'),
          const Divider(height: 32),
          Text('減点項目', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          if (imageDetail.deductionItems.isEmpty)
            const Text('・減点項目はありませんでした。')
          else
            ...imageDetail.deductionItems
                .map((item) => Text('・$item'))
                .toList(),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('誤検知を報告'),
            onPressed: isFeedbackSubmitted ? null : _showFeedbackDialog,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: textTheme.titleMedium,
              backgroundColor: isFeedbackSubmitted ? Colors.grey : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge),
          Text(
            value,
            style: isHighlight
                ? textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)
                : textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

