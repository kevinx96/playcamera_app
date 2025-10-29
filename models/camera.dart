class Camera {
  final int id;
  final String name;
  final String status;

  Camera({
    required this.id,
    required this.name,
    required this.status,
  });

  // fromJson 构造函数，用于将 API 返回的 JSON (Map) 转换为 Camera 对象
  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as int,
      name: json['name'] as String,
      // [FIX] 确保 status 字段被解析，并提供一个默认值
      status: json['status'] as String? ?? 'offline', 
    );
  }
}

