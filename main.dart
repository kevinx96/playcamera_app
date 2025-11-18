import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [NEW] 导入 Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/camera_provider.dart';
import 'providers/report_provider.dart';

// [NEW] 为通知点击导航做准备
import 'package:flutter/widgets.dart'; // 导入 GlobalKey
import 'screens/report_detail_screen.dart';
import 'providers/report_detail_provider.dart';


// [NEW] 必须是顶层函数 (Top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 注意：这里不能执行任何依赖 Provider 或 BuildContext 的操作
  // 仅用于数据分析或后台任务
  await Firebase.initializeApp();
  print("FCM: 收到后台消息: ${message.messageId}");
}

// [NEW] 用于导航的全局 Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // [NEW] 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // [NEW] 初始化 Firebase
  await Firebase.initializeApp();
  
  // [NEW] 设置后台消息处理器
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
  
  // [NEW] 在 App 运行后，设置“已终止”状态的点击监听器
  _setupTerminatedNotificationHandler();
}

// [NEW] 处理从“已终止”状态打开 App 的通知
void _setupTerminatedNotificationHandler() async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleNotificationTap(initialMessage);
  }

  // [NEW] 处理从“后台”状态打开 App 的通知
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
}

// [NEW] 处理通知点击的通用函数
void _handleNotificationTap(RemoteMessage message) {
  print('FCM: 通知被点击, 数据: ${message.data}');
  final String? eventId = message.data['event_id'];

  if (eventId != null) {
    // 使用 GlobalKey 进行导航
    
    // 确保 navigatorKey.currentState 可用
    if (navigatorKey.currentState != null) {
      // 导航到详情页
      // (我们假设 ReportDetailScreen 会从 Widget 获取 ID 并自行加载)
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(caseId: eventId)
        ),
      );
    }
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider (Independent)
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),

        // 2. ApiService (Depends on AuthProvider's token)
        ProxyProvider<AuthProvider, ApiService>(
          update: (context, authProvider, previousApiService) {
            return ApiService(authProvider.token);
          },
        ),

        // 3. CameraProvider (Depends on ApiService)
        ChangeNotifierProxyProvider<ApiService, CameraProvider>(
          create: (context) => CameraProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (context, apiService, previousCameraProvider) {
            return CameraProvider(apiService);
          },
        ),

        // 4. ReportProvider (Depends on ApiService)
        ChangeNotifierProxyProvider<ApiService, ReportProvider>(
          create: (context) => ReportProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (context, apiService, previousReportProvider) {
            return ReportProvider(apiService);
          },
        ),

        // [NEW] 为通知点击导航准备 ReportDetailProvider
        // 当 ReportDetailScreen 被导航到时，它会查找这个 Provider。
        ChangeNotifierProxyProvider<ApiService, ReportDetailProvider>(
          create: (context) => ReportDetailProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (context, apiService, previousDetailProvider) {
            return ReportDetailProvider(apiService);
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Safety Playground App',
            // [NEW] 将 GlobalKey 传递给 MaterialApp
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primaryColor: const Color(0xFF0D6EFD),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
               colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D6EFD),
              ),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            home: auth.isAuthenticated ? const MainScreen() : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}