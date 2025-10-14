import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/report_detail_provider.dart';
import '../models/report_detail.dart'; // [FIXED] Added this import

class ReportDetailScreen extends StatefulWidget {
  final String caseId;
  const ReportDetailScreen({super.key, required this.caseId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Re-fetch details when the screen is initialized
    // This ensures that if the provider is re-used, it shows the correct data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportDetailProvider>().fetchReportDetail(widget.caseId);
    });

    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentImageIndex) {
        setState(() {
          _currentImageIndex = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // The feedback dialog is now more complex
  void _showFeedbackDialog(BuildContext context) {
    final provider = context.read<ReportDetailProvider>();
    provider.resetFeedbackForm(); // Reset form state when dialog opens
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<ReportDetailProvider>(
          builder: (context, provider, child) {
            if (provider.submissionSuccess) {
              return AlertDialog(
                title: const Text('フィードバック送信完了'),
                content:
                    const Text('ご報告ありがとうございました。\n今後の精度向上のために活用させていただきます。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('確認'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('誤検知を報告'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('報告内容に最も近いものを選択してください。'),
                      const SizedBox(height: 16),
                      // Dropdown menu for error types
                      DropdownButtonFormField<String>(
                        value: provider.selectedReason,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'エラーの種類',
                        ),
                        hint: const Text('種類を選択'),
                        items: provider.feedbackReasons
                            .map((reason) => DropdownMenuItem(
                                  value: reason,
                                  child: Text(reason,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (value) {
                          provider.selectReason(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'エラーの種類を選択してください。';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Text field for supplementary notes
                      TextFormField(
                        controller: notesController,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '補足情報 (任意)',
                          hintText: '具体的な状況などを入力してください。',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: provider.isSubmitting
                  ? [const Center(child: CircularProgressIndicator())]
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            provider.submitFeedback(
                              reason: provider.selectedReason!,
                              notes: notesController.text,
                            );
                          }
                        },
                        child: const Text('送信'),
                      ),
                    ],
            );
          },
        );
      },
    );
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
          final currentImage = report.images[_currentImageIndex];

          return Column(
            children: [
              // Image slider section
              Expanded(
                flex: 1,
                child: _buildImageSlider(report.images),
              ),
              // Image details section
              Expanded(
                flex: 1,
                child: _buildImageDetails(
                    context, report, currentImage, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSlider(List<ImageDetail> images) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported,
                        color: Colors.white, size: 100),
                    const SizedBox(height: 16),
                    Text('画像 ${index + 1}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white54,
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageDetails(BuildContext context, ReportDetail report,
      ImageDetail currentImage, ReportDetailProvider provider) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm:ss');

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(report.category),
                backgroundColor: Colors.blue.shade100,
              ),
              Text(
                '画像 ${currentImage.imageId.split('_').last} / ${report.imageCount}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Score and Time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(context, 'スコア', '${currentImage.score}点',
                      Colors.red.shade700),
                  _buildInfoItem(
                      context, '発生時刻', dateFormat.format(currentImage.timestamp)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Deduction items
          Text('検知された項目', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: currentImage.deductionItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange),
                    title: Text(currentImage.deductionItems[index]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Feedback button
          ElevatedButton.icon(
            onPressed: provider.submissionSuccess
                ? null
                : () => _showFeedbackDialog(context),
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('誤検知を報告'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value,
      [Color? valueColor]) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }
}

