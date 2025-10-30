import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import '../models/camera.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart'; // [NEW] 导入 ApiService

class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            // [MODIFIED] 传入 context 以便 _LiveVideoPlayer 能访问 ApiService
            _LiveVideoPlayer(
              camera: cameraProvider.selectedCamera,
              key: ValueKey(cameraProvider.selectedCamera?.id ?? 'no_camera'), // [NEW] 添加 Key 确保正确重建
            ),
            
            // 2. カメラリストのタイトル
            _buildListHeader(context),
            
            // 3. カメラリスト
            _buildCameraList(cameraProvider),
          ],
        );
      },
    );
  }

  // カメラリストのヘッダー (不变)
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
              context.read<CameraProvider>().fetchCameras();
            },
          )
        ],
      ),
    );
  }

  // カメラリスト (不变)
  Widget _buildCameraList(CameraProvider provider) {
    return Expanded(
      child: ListView.builder(
        itemCount: provider.cameras.length,
        itemBuilder: (context, index) {
          final camera = provider.cameras[index];
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
                provider.selectCamera(camera);
              },
            ),
          );
        },
      ),
    );
  }
}

// [MODIFIED] _LiveVideoPlayer 逻辑大改
class _LiveVideoPlayer extends StatefulWidget {
  final Camera? camera;

  // [MODIFIED] 构造函数
  const _LiveVideoPlayer({this.camera, Key? key}) : super(key: key);

  @override
  State<_LiveVideoPlayer> createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends State<_LiveVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.camera != null && widget.camera!.status == 'online') {
      // [MODIFIED] 初始化流程改为调用 API
      _initializeVideoPlayerFuture = _initializeController(widget.camera!);
    }
  }

  // [MODIFIED] 重写 didUpdateWidget 
  @override
  void didUpdateWidget(covariant _LiveVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.camera != oldWidget.camera) {
      _controller?.dispose(); // 释放旧控制器
      _errorMessage = null;
      if (widget.camera != null && widget.camera!.status == 'online') {
        _initializeVideoPlayerFuture = _initializeController(widget.camera!);
      } else {
         _initializeVideoPlayerFuture = null;
      }
    }
  }

  // [MODIFIED] _initializeController 现在调用 ApiService
  Future<void> _initializeController(Camera camera) async {
    // 1. 从 Provider 获取 ApiService
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    String streamUrl;
    try {
      // 2. 调用 API 获取 HLS URL
      print('Fetching stream URL for camera ${camera.id}...');
      streamUrl = await apiService.getCameraStreamUrl(camera.id);
      print('Received stream URL: $streamUrl');
      
      if (!mounted) return; // 异步间隙检查
      
      // 3. 初始化 VideoPlayerController
      _controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();
      
      setState(() { _errorMessage = null; }); // 清除错误

    } catch (e) {
      print("Error initializing video player: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "映像の読み込みに失敗しました。\n(${e.toString()})";
        });
      }
      // 抛出异常, FutureBuilder 会捕获它
      // [FIXED] 明确地重新抛出捕获的异常 e
      throw e; 
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: _buildPlayerContent(),
      ),
    );
  }

  Widget _buildPlayerContent() {
    // 1. 未选择摄像头
    if (widget.camera == null) {
      return const Center(
        child: Text('カメラが選択されていません', style: TextStyle(color: Colors.white)),
      );
    }
    
    // 2. 摄像头离线
    if (widget.camera!.status != 'online') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            '${widget.camera!.name} はオフラインです',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      );
    }

    // 3. 摄像头在线, 使用 FutureBuilder 处理初始化
    if (_initializeVideoPlayerFuture == null) {
       return const Center(child: Text('不明な状態です', style: TextStyle(color: Colors.red)));
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        // 3a. 成功加载
        if (snapshot.connectionState == ConnectionState.done && _controller != null && _controller!.value.isInitialized) {
          return VideoPlayer(_controller!);
        }
        
        // 3b. 加载失败
        if (snapshot.hasError || _errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? '映像の読み込みに失敗しました。',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        // 3c. 正在加载
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              '${widget.camera!.name} の映像を読み込み中...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        );
      },
    );
  }
}