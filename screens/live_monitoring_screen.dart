import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import '../models/camera.dart';

class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [FIX] 使用 Consumer 来监听 CameraProvider 的变化
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        if (cameraProvider.isLoading && cameraProvider.cameras.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cameraProvider.error != null) {
          return Center(child: Text(cameraProvider.error!));
        }

        if (cameraProvider.cameras.isEmpty) {
          return const Center(child: Text('利用可能なカメラがありません。'));
        }

        // メインレイアウト
        return Column(
          children: [
            // 1. ビデオプレイヤーエリア
            _buildVideoPlayer(context, cameraProvider.selectedCamera),
            
            // 2. カメラリストのタイトル
            _buildListHeader(context),
            
            // 3. カメラリスト
            _buildCameraList(cameraProvider),
          ],
        );
      },
    );
  }

  // ビデオプレイヤーウィジェット
  Widget _buildVideoPlayer(BuildContext context, Camera? selectedCamera) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: Center(
          child: selectedCamera == null
              ? const Text('カメラが選択されていません', style: TextStyle(color: Colors.white))
              : (selectedCamera.status == 'online'
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam, color: Colors.green, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          '${selectedCamera.name} の映像 (デモ)',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const Text(
                          '（実際のストリームはここに表示されます）',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          '${selectedCamera.name} はオフラインです',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    )),
        ),
      ),
    );
  }

  // カメラリストのヘッダー
  Widget _buildListHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'カメラ一覧',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // データを再取得
              context.read<CameraProvider>().fetchCameras();
            },
          )
        ],
      ),
    );
  }

  // カメラリスト
  Widget _buildCameraList(CameraProvider provider) {
    return Expanded(
      child: ListView.builder(
        itemCount: provider.cameras.length,
        itemBuilder: (context, index) {
          final camera = provider.cameras[index];
          // [FIX] provider.selectedCamera?.id で安全に比較
          final isSelected = provider.selectedCamera?.id == camera.id;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: isSelected ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Icon(
                camera.status == 'online' ? Icons.videocam : Icons.videocam_off,
                color: camera.status == 'online' ? Colors.green : Colors.red,
              ),
              title: Text(
                camera.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // [FIXED] camera.location -> camera.name
              // APIは 'name' を返すが、'location' は返さない
              // ここではカメラ名を subtitle に表示する（もしくは status を表示する）
              subtitle: Text(
                camera.status == 'online' ? 'オンライン' : 'オフライン',
                style: TextStyle(
                  color: camera.status == 'online' ? Colors.green : Colors.red,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              onTap: () {
                // [FIX] provider.selectCamera を呼び出す
                provider.selectCamera(camera);
              },
            ),
          );
        },
      ),
    );
  }
}

