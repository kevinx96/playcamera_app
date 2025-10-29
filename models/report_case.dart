import 'package:intl/intl.dart'; // [NEW] 导入 intl 包

class ReportCase {
  final int id;
  final int cameraId;
  final String equipmentType; // [MODIFIED] 从 category 改为 equipmentType
  final int score;
  final String thumbnailUrl;
  final String status;
  final DateTime eventTime; // [MODIFIED] 从 timestamp 改为 eventTime

  ReportCase({
    required this.id,
    required this.cameraId,
    required this.equipmentType, // [MODIFIED]
    required this.score,
    required this.thumbnailUrl,
    required this.status,
    required this.eventTime, // [MODIFIED]
  });

  factory ReportCase.fromJson(Map<String, dynamic> json) {
    String dateString = json['event_time'] as String? ?? '';
    DateTime parsedDate;

    try {
      // [FIXED] 尝试解析 RFC 1123 格式 (e.g., "Mon, 27 Oct 2025 22:48:30 GMT")
      // 注意：HttpDate.parse() 更健壮，但需要 dart:io 导入，模型中不推荐
      // 我们使用 intl 的 DateFormat
      parsedDate = DateFormat("E, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(dateString);
    } catch (e) {
      try {
        // 如果 RFC 1123 失败，尝试解析 ISO 8601 (备用方案)
        parsedDate = DateTime.parse(dateString);
      } catch (e2) {
        // 如果都失败，使用当前时间或一个默认时间
        print("⚠️ Failed to parse date: $dateString. Error: $e and $e2");
        parsedDate = DateTime.now(); // 或者 DateTime(1970)
      }
    }

    return ReportCase(
      id: json['id'] as int,
      cameraId: json['camera_id'] as int? ?? 0,
      equipmentType: json['equipment_type'] as String? ?? '不明', // [MODIFIED]
      score: json['score'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '', // [MODIFIED] 使用后端别名
      status: json['status'] as String? ?? '不明',
      eventTime: parsedDate, // [MODIFIED] 使用解析后的日期
    );
  }
}

