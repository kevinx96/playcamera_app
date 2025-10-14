class ReportDetail {
  final String caseId;
  final String category;
  final int score;
  final DateTime timestamp;
  final int imageCount;
  final List<ImageDetail> images;

  ReportDetail({
    required this.caseId,
    required this.category,
    required this.score,
    required this.timestamp,
    required this.imageCount,
    required this.images,
  });
}

class ImageDetail {
  final String imageId;
  final int score;
  final DateTime timestamp;
  final List<String> deductionItems;

  ImageDetail({
    required this.imageId,
    required this.score,
    required this.timestamp,
    required this.deductionItems,
  });
}

