class ReportCase {
  final int id;
  final String? thumbnailUrl; // 画像がない場合もあるためnull許容
  final int score;
  final DateTime timestamp;
  final String category;

  ReportCase({
    required this.id,
    this.thumbnailUrl,
    required this.score,
    required this.timestamp,
    required this.category,
  });
}
