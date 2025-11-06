import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/auth_wrapper.dart';
import 'providers/theme_provider.dart';
import 'data/services/notification_service.dart';
import 'data/services/firebase_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase using the configuration service
    final firebaseInitialized = await FirebaseConfigService.initialize();

    if (firebaseInitialized) {
      print('Firebase initialized successfully');

      // Test Firebase connectivity
      final connectivityTest = await FirebaseConfigService.testConnectivity();
      print(
        'Firebase connectivity test: ${connectivityTest ? 'PASSED' : 'FAILED'}',
      );

      // Initialize notification service
      await NotificationService.initialize();
      print('Notification service initialized successfully');

      // Print Firebase configuration info
      final configInfo = FirebaseConfigService.getConfigInfo();
      print('Firebase Config: $configInfo');
    } else {
      print('Firebase initialization failed, continuing without Firebase');
    }
  } catch (e) {
    print('Error during initialization: $e');
    // Continue app initialization even if Firebase fails
  }

  runApp(const ProviderScope(child: AutoHubApp()));
}

class AutoHubApp extends ConsumerWidget {
  const AutoHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AutoHub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
