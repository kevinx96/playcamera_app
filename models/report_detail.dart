// models/report_detail.dart


class ImageDetail {
  final int imageId;
  final String? imageUrl; // 将来的に使用
  final int score;
  final List<String> deductionItems; // 減点項目リスト

  ImageDetail({
    required this.imageId,
    this.imageUrl,
    required this.score,
    required this.deductionItems,
  });
}


class ReportDetail {
  final int caseId;
  final String category;
  final DateTime timestamp;
  final List<ImageDetail> images;

  ReportDetail({
    required this.caseId,
    required this.category,
    required this.timestamp,
    required this.images,
  });
}