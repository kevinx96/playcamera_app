import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// [FIXED] 严格按照 code.txt 使用相对路径
import '../providers/auth_provider.dart';
import 'live_monitoring_screen.dart';
import 'report_history_screen.dart';
import 'mypage_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // [REMOVED] 移除 static const 列表以强制重建
  // static const List<Widget> _widgetOptions = <Widget>[...];
  // static const List<String> _appBarTitles = <String>[...];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // [FIXED] 将页面列表和标题移到 build 方法内部
    // 这将强制在每次 setState (即每次点击标签) 时创建新的页面实例。
    // 当旧实例被销毁时, VideoPlayerController 将被正确 dispose()。
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
        title: Text(appBarTitles[_selectedIndex]), // [MODIFIED] 使用本地列表
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
      // [FIXED] 还原回 IndexedStack
      // 这将修复数据加载和认证问题，但会带回 JNI 错误。
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

