import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/camera.dart';
import '../providers/camera_provider.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  @override
  void initState() {
    super.initState();

    // listen: false 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CameraProvider>(context, listen: false).fetchCameras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    

    return Column(
      children: [
        // 1. ライブ映像表示エリア
        _buildVideoPlayer(context, cameraProvider.selectedCamera),

        // 2. カメラリスト表示エリア
        _buildCameraList(context, cameraProvider),
      ],
    );
  }


  Widget _buildVideoPlayer(BuildContext context, Camera? selectedCamera) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Center(
          child: _buildPlayerStatus(context, selectedCamera),
        ),
      ),
    );
  }


  Widget _buildPlayerStatus(BuildContext context, Camera? camera) {
    final style = TextStyle(color: Colors.grey.shade400, fontSize: 16);

    if (camera == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text('下のリストからカメラを選択', style: style.copyWith(color: Colors.white)),
        ],
      );
    }

    if (camera.status == 'online') {
      return Text(
        'ライブ映像 - ${camera.name}',
        style: style.copyWith(color: Colors.greenAccent),
      );
    }

    // "無接続" の状態を表示
    if (camera.status == 'offline') {
      return Text(
        '${camera.name} - オフライン (無接続)',
        style: style.copyWith(color: Colors.redAccent),
      );
    }
    
    return Text('不明なステータス', style: style);
  }


  Widget _buildCameraList(BuildContext context, CameraProvider provider) {
    if (provider.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (provider.error != null) {
      return Expanded(child: Center(child: Text(provider.error!)));
    }
    if (provider.cameras.isEmpty) {
      return const Expanded(child: Center(child: Text('利用可能なカメラがありません。')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: provider.cameras.length,
        itemBuilder: (context, index) {
          final camera = provider.cameras[index];
          final isSelected = provider.selectedCamera?.id == camera.id;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: isSelected ? Colors.blueAccent.withOpacity(0.1) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.videocam,
                color: camera.status == 'online' ? Colors.green : Colors.red,
              ),
              title: Text(camera.name),
              subtitle: Text(camera.location),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: camera.status == 'online' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  camera.status == 'online' ? 'オンライン' : 'オフライン',
                  style: TextStyle(
                    color: camera.status == 'online' ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                provider.selectCamera(camera);
              },
            ),
          );
        },
      ),
    );
  }
}

