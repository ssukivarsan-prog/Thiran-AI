import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeevika_web/core/network/web_api_service.dart';
import 'package:jeevika_web/main.dart';

void main() {
  testWidgets('Thiran Web App displays Login Screen with RBAC role options', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final webApi = WebApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: webApi),
        ],
        child: const ThiranWebApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify brand
    expect(find.text('THIRAN AI'), findsOneWidget);
    expect(find.text('Operations Console'), findsOneWidget);
    expect(find.text('Portal Sign In'), findsOneWidget);
    expect(find.text('Sign In to Workspace'), findsOneWidget);

    // Verify all 5 RBAC roles are available
    expect(find.text('Operations Administrator'), findsWidgets);
    expect(find.text('Vocational Training Partner'), findsOneWidget);
    expect(find.text('Hiring Enterprise Partner'), findsOneWidget);
    expect(find.text('Field Counselor & Support Lead'), findsOneWidget);
    expect(find.text('Livelihood & Technical Mentor'), findsOneWidget);

    // Verify zero Gemini third-party branding
    expect(find.textContaining('Gemini'), findsNothing);
  });

  testWidgets('Role-based login restricts workspace access to authorized tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final webApi = WebApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: webApi),
        ],
        child: const ThiranWebApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Select Employer Role
    await tester.tap(find.text('Hiring Enterprise Partner'));
    await tester.pumpAndSettle();

    // Click Sign In to Workspace
    await tester.tap(find.text('Sign In to Workspace'));
    await tester.pumpAndSettle();

    // Verify user is now authenticated as Employer
    expect(webApi.isAuthenticated, true);
    expect(webApi.activeRole, 'EMPLOYER');

    // Employer should see Livelihood Opportunities & Beneficiary Directory
    expect(find.text('Livelihood Opportunities'), findsOneWidget);
    expect(find.text('Beneficiary Directory'), findsOneWidget);

    // Employer should NOT see Admin Operations Dashboard or Training Programs in the navigation
    expect(find.text('Operations Dashboard'), findsNothing);
    expect(find.text('Training Programs'), findsNothing);
    expect(find.text('Escalation Tickets'), findsNothing);

    // Verify System Status Card mentions Thiran AI Engine, NOT Gemini
    expect(find.text('Thiran AI Engine Online'), findsOneWidget);
    expect(find.text('Thiran AI Intelligence Core Connected'), findsOneWidget);
    expect(find.textContaining('Gemini'), findsNothing);

    // Now test Log out
    await tester.tap(find.byTooltip('Sign Out').first);
    await tester.pumpAndSettle();

    // Verify user is back at Login screen
    expect(webApi.isAuthenticated, false);
    expect(find.text('Portal Sign In'), findsOneWidget);
  });
}
