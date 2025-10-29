import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/report_detail.dart';
import '../providers/report_detail_provider.dart';
import '../services/api_service.dart'; // [FIX] 导入 ApiService

class ReportDetailScreen extends StatefulWidget {
  final String caseId; // 接收 String 类型的 caseId

  const ReportDetailScreen({super.key, required this.caseId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 画面初期化時に詳細データを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportDetailProvider>().fetchReportDetail(widget.caseId);
    });

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レポート詳細'),
      ),
      body: Consumer<ReportDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.reportDetail == null) {
            return const Center(child: Text('レポートが見つかりません。'));
          }

          final report = provider.reportDetail!;
          final currentImage = report.images.isNotEmpty
              ? report.images[_currentPage]
              : null;

          return Column(
            children: [
              // 1. 画像スライダー (画面の50%)
              Expanded(
                flex: 5, // 50%
                child: _buildImageSlider(report.images),
              ),
              // 2. 詳細情報 (画面の50%)
              Expanded(
                flex: 5, // 50%
                child: _buildImageDetails(
                    context, report, currentImage, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Widgets ---

  Widget _buildImageSlider(List<ImageDetail> images) {
  if (images.isEmpty) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text('関連画像がありません。', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  return PageView.builder(
    controller: _pageController,
    itemCount: images.length,
    itemBuilder: (context, index) {
      final image = images[index];
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 显示网络图片
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    image.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.white, size: 100);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 图片标题
              Text(
                '画像 ${image.imageId} (デモ)',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Image URL: ${image.imageUrl}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildImageDetails(BuildContext context, ReportDetail report,
      ImageDetail? currentImage, ReportDetailProvider provider) {
    if (currentImage == null) {
      return const Center(child: Text('画像情報がありません。'));
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    bool hasSubmitted = provider.feedbackStatus == FeedbackStatus.success;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 画像インジケーター
          Text(
            // [FIX] currentImage.imageId は int なので .toString() を使用
            '画像 ${currentImage.imageId.toString()} / ${report.imageCount}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 情報カード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'スコア', currentImage.score.toString(),
                      isScore: true, score: currentImage.score),
                  const Divider(),
                  _buildDetailRow(
                      context, '発生時刻', dateFormat.format(currentImage.timestamp)),
                  const Divider(),
                  _buildDetailRow(context, 'カテゴリ', report.category),
                  const Divider(),
                  _buildDetailRow(
                      context, '検知された画像数', report.imageCount.toString()),
                  const Divider(),
                  _buildDeductionList(context, currentImage.deductionItems),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // フィードバックボタン
          ElevatedButton.icon(
            icon: Icon(
              hasSubmitted ? Icons.check_circle : Icons.error_outline,
            ),
            label: Text(hasSubmitted ? 'フィードバック送信済み' : '誤検知を報告'),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSubmitted ? Colors.grey : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            // [FIX] 既に送信成功した場合はボタンを無効化
            onPressed: hasSubmitted
                ? null
                : () {
                    // [FIX] フィードバック対象の画像IDをProviderにセット
                    provider.prepareFeedback(currentImage.imageId);
                    _showFeedbackDialog(context, provider, report.id.toString());
                  },
          ),
        ],
      ),
    );
  }

  // --- Feedback Dialog ---

  void _showFeedbackDialog(
      BuildContext context, ReportDetailProvider provider, String eventId) {
    // ダイアログは自身の状態を管理するため、StatefulBuilder を使用
    showDialog(
      context: context,
      barrierDismissible: provider.feedbackStatus != FeedbackStatus.loading,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Provider の状態をリッスン
            final status = context.watch<ReportDetailProvider>().feedbackStatus;

            if (status == FeedbackStatus.success) {
              return AlertDialog(
                title: const Text('フィードバック成功'),
                content: const Text('フィードバックが正常に送信されました。'),
                actions: [
                  TextButton(
                    child: const Text('確認'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // Provider の状態をリセット
                      context.read<ReportDetailProvider>().resetFeedbackState();
                    },
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('誤検知を報告'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('エラーの種類を選択してください:'),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: provider.selectedReason,
                      onChanged: (newValue) {
                        provider.updateSelectedReason(newValue);
                        // setDialogState は不要 (Provider が更新を通知するため)
                      },
                      items: provider.errorReasons
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 4,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: '補足情報 (任意)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        provider.updateFeedbackNotes(value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: status == FeedbackStatus.loading
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: status == FeedbackStatus.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('送信'),
                  onPressed: status == FeedbackStatus.loading
                      ? null
                      : () {
                          // [FIX] 必要なパラメータをすべて渡す
                          final imageId = provider.currentImageIdForFeedback;
                          if (imageId != null) {
                            context.read<ReportDetailProvider>().submitFeedback(
                                  eventId: eventId,
                                  imageId: imageId,
                                  reason: provider.selectedReason,
                                  notes: provider.feedbackNotes,
                                );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Detail Widgets ---

  Widget _buildDetailRow(BuildContext context, String title, String value,
      {bool isScore = false, int score = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isScore
                  ? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: score < 50 ? Colors.red : Colors.orange,
                    )
                  : Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionList(BuildContext context, List<String> deductions) {
    if (deductions.isEmpty) {
      return _buildDetailRow(context, '扣分项目', 'なし');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '扣分项目',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: deductions.map((item) {
                return Text(
                  '・ $item',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.red[700]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

