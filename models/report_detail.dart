import 'package:flutter/foundation.dart';

// 对应 GET /api/events/{id} 返回的 data 对象
class ReportDetail {
  final int id;
  final int cameraId;
  final String category;
  final int score;
  final DateTime timestamp;
  final int imageCount;
  final List<ImageDetail> images;

  ReportDetail({
    required this.id,
    required this.cameraId,
    required this.category,
    required this.score,
    required this.timestamp,
    required this.imageCount,
    required this.images,
  });

  // [FIX] 添加 fromJson 工厂构造函数
  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    var imagesList = json['images'] as List? ?? [];
    List<ImageDetail> parsedImages = imagesList
        .map((i) => ImageDetail.fromJson(i as Map<String, dynamic>))
        .toList();

    return ReportDetail(
      id: json['id'] as int,
      cameraId: json['camera_id'] as int? ?? 0,
      category: json['category'] as String? ?? '不明',
      score: json['score'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String? ?? ''),
      imageCount: json['image_count'] as int? ?? 0,
      images: parsedImages,
    );
  }
}

// 对应 ReportDetail.images 列表中的单个图片对象
class ImageDetail {
  final int imageId;
  final String imageUrl;
  final DateTime timestamp;
  final int score;
  final List<String> deductionItems;

  ImageDetail({
    required this.imageId,
    required this.imageUrl,
    required this.timestamp,
    required this.score,
    required this.deductionItems,
  });

  // [FIX] 添加 fromJson 工厂构造函数
  factory ImageDetail.fromJson(Map<String, dynamic> json) {
    var deductionsList = json['deduction_items'] as List? ?? [];
    List<String> parsedDeductions =
        deductionsList.map((item) => item.toString()).toList();

    return ImageDetail(
      imageId: json['image_id'] as int,
      imageUrl: json['image_url'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String? ?? ''),
      score: json['score'] as int? ?? 0,
      deductionItems: parsedDeductions,
    );
  }
}

