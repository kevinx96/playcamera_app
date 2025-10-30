import 'package:intl/intl.dart'; // [FIXED] 修复了导入路径 (package:intl)

class ReportCase {
  final int id;
  final int cameraId;
  final String equipmentType;
  final int score;
  final String iconUrl;
  final String status;
  final DateTime eventTime;

  ReportCase({
    required this.id,
    required this.cameraId,
    required this.equipmentType,
    required this.score,
    required this.iconUrl,
    required this.status,
    required this.eventTime,
  });

  factory ReportCase.fromJson(Map<String, dynamic> json) {
    String dateString = json['event_time'] as String? ?? '';
    DateTime parsedDate;

    try {
      // [FIXED] 尝试解析 RFC 1123 格式 (e.g., "Mon, 27 Oct 2025 22:48:30 GMT")
      // 我们使用 intl 的 DateFormat
      parsedDate = DateFormat("E, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(dateString);
    } catch (e) {
      try {
        // 如果 RFC 1123 失败，尝试解析 ISO 8601 (备用方案)
        parsedDate = DateTime.parse(dateString);
      } catch (e2) {
        // 如果都失败，使用当前时间或一个默认时间
        print("⚠️ Failed to parse date: $dateString. Error: $e and $e2");
        parsedDate = DateTime.now();
      }
    }

    return ReportCase(
      id: json['id'] as int,
      cameraId: json['camera_id'] as int? ?? 0,
      equipmentType: json['equipment_type'] as String? ?? '不明',
      score: json['score'] as int? ?? 0,
      
      // 直接读取由 api.py 提供的完整 URL。
      iconUrl: json['icon_url'] as String? ?? json['image_url'] as String? ?? '', 
      
      status: json['status'] as String? ?? '不明',
      eventTime: parsedDate,
    );
  }
}

