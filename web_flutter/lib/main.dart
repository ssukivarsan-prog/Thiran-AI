import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/web_api_service.dart';
import 'core/theme/app_theme.dart';
import 'views/auth/web_login_view.dart';
import 'views/beneficiaries/beneficiaries_view.dart';
import 'views/communications/communications_view.dart';
import 'views/dashboard/admin_dashboard_view.dart';
import 'views/mentors/web_mentors_view.dart';
import 'views/opportunities/web_opportunities_view.dart';
import 'views/tickets/tickets_view.dart';
import 'views/training/web_training_view.dart';
import 'widgets/web_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebApiService()),
      ],
      child: const ThiranWebApp(),
    ),
  );
}

class ThiranWebApp extends StatefulWidget {
  const ThiranWebApp({super.key});

  @override
  State<ThiranWebApp> createState() => _ThiranWebAppState();
}

class _ThiranWebAppState extends State<ThiranWebApp> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    AdminDashboardView(),
    BeneficiariesView(),
    WebTrainingView(),
    WebOpportunitiesView(),
    WebMentorsView(),
    CommunicationsView(),
    TicketsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final webApi = Provider.of<WebApiService>(context);

    // Enforce role-based access control to views
    final permitted = webApi.getPermittedTabs();
    final safeIndex = permitted.contains(_selectedIndex)
        ? _selectedIndex
        : (permitted.isNotEmpty ? permitted.first : 0);

    return MaterialApp(
      title: 'Thiran AI — Operations & Administration Console',
      debugShowCheckedModeBanner: false,
      theme: WebTheme.themeData,
      home: !webApi.isAuthenticated
          ? WebLoginView(
              onLoginSuccess: () {
                final allowed = webApi.getPermittedTabs();
                setState(() {
                  _selectedIndex = allowed.isNotEmpty ? allowed.first : 0;
                });
              },
            )
          : WebLayoutShell(
              selectedIndex: safeIndex,
              onIndexChanged: (index) {
                if (permitted.contains(index)) {
                  setState(() => _selectedIndex = index);
                }
              },
              child: _views[safeIndex],
            ),
    );
  }
}

// Backwards compatibility alias
typedef JeevikaWebApp = ThiranWebApp;
