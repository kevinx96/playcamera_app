import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 导入文件
import 'providers/auth_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/report_provider.dart';
import 'providers/report_detail_provider.dart';
import 'screens/login_screen.dart';

// Flutter应用的入口点
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 MultiProvider 状态管理器提供
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CameraProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReportDetailProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Play Camera App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}

