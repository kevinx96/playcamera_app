import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [NEW] 导入 FCM 包和我们的服务
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';

import '../providers/auth_provider.dart';
import 'live_monitoring_screen.dart';
import 'report_history_screen.dart';
import 'mypage_screen.dart';
import 'login_screen.dart';

// [NEW] 为通知点击导航做准备
import 'report_detail_screen.dart';
import '../providers/report_detail_provider.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // [NEW] 添加 FCM 初始化逻辑
  @override
  void initState() {
    super.initState();
    _initializeFcm();
  }

  Future<void> _initializeFcm() async {
    // 1. 获取 ApiService 实例 (已认证)
    final apiService = context.read<ApiService>();

    // 2. 获取 FCM 实例
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 3. 向用户请求通知权限 (iOS 和 Android 13+ 需要)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM: 用户已授权');
      
      // 4. 获取 FCM 设备令牌
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        print('FCM: 获取到令牌: $fcmToken');
        try {
          // 5. 将令牌发送到您的 API
          await apiService.registerDeviceToken(fcmToken);
          print('FCM: 令牌已成功注册到 API');
        } catch (e) {
          print('FCM: 令牌注册失败: $e');
        }
      }

      // 6. [可选] 监听令牌刷新
      messaging.onTokenRefresh.listen((newToken) {
        if (mounted) {
          apiService.registerDeviceToken(newToken);
        }
      });

    } else {
      print('FCM: 用户未授权通知');
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // [MODIFIED] 将列表移入 build 方法 (修复 video_player 问题)
    final List<Widget> widgetOptions = <Widget>[
      const LiveMonitoringScreen(),
      const ReportHistoryScreen(),
      const MypageScreen(),
    ];

    final List<String> appBarTitles = <String>[
      'リアルタイム監視',
      'レポート履歴',
      'マイページ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      // [MODIFIED] 保持使用 IndexedStack (还原)
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
           BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            activeIcon: Icon(Icons.videocam),
            label: '監視',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: '履歴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}