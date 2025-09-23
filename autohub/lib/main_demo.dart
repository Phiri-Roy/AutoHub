import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/demo/demo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AutoHubApp()));
}

class AutoHubApp extends StatelessWidget {
  const AutoHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoHub - Demo',
      theme: AppTheme.lightTheme,
      home: const DemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}



