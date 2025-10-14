class Camera {
  final int id;
  final String name;
  final String location;
  final String status; // 'online', 'offline'

  Camera({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
  });
}
