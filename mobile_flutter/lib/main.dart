import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_strings.dart';
import 'core/network/api_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStrings()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: const ThiranMobileApp(),
    ),
  );
}

class ThiranMobileApp extends StatelessWidget {
  const ThiranMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thiran AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

// Backwards compatibility alias
typedef JeevikaMobileApp = ThiranMobileApp;
