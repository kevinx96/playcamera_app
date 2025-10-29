import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/camera_provider.dart';
// [FIXME] This import is likely causing a conflict, 
// but we will fix the file 'report_provider.dart' in the next step.
import 'providers/report_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider setup with ProxyProviders to correctly handle dependencies
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
          // [FIXED] Added the required 'create' parameter.
          // This creates the initial provider instance.
          create: (context) => CameraProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
          // 'update' rebuilds the provider when ApiService changes (e.g., after login)
          update: (context, apiService, previousCameraProvider) {
            return CameraProvider(apiService);
          },
        ),

        // 4. ReportProvider (Depends on ApiService)
        ChangeNotifierProxyProvider<ApiService, ReportProvider>(
          // [FIXED] Added the required 'create' parameter.
          create: (context) => ReportProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (context, apiService, previousReportProvider) {
            return ReportProvider(apiService);
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Safety Playground App',
            theme: ThemeData(
              // ... (rest of your theme data)
              primaryColor: const Color(0xFF0D6EFD),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              // ... (rest of your theme data)
            ),
            debugShowCheckedModeBanner: false,
            // Automatically show LoginScreen or MainScreen based on auth state
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

