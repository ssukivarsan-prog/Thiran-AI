import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeevika_mobile/core/localization/app_strings.dart';
import 'package:jeevika_mobile/core/network/api_service.dart';
import 'package:jeevika_mobile/features/home/home_screen.dart';
import 'package:jeevika_mobile/features/onboarding/voice_onboarding_screen.dart';
import 'package:jeevika_mobile/features/profile/profile_screen.dart';
import 'package:jeevika_mobile/main.dart';

void main() {
  testWidgets('Thiran Mobile App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStrings()),
          ChangeNotifierProvider(create: (_) => ApiService()),
        ],
        child: const ThiranMobileApp(),
      ),
    );

    // Initial frame check
    expect(find.text('THIRAN AI'), findsOneWidget);

    // Settle splash timer
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  test('AppStrings localization purity across 6 languages', () {
    final strings = AppStrings();
    final languages = ['ta', 'en', 'hi', 'te', 'kn', 'ml'];

    for (final lang in languages) {
      strings.setLanguage(lang);
      expect(strings.currentLanguage, lang);

      // Verify appName
      final appName = strings.tr('appName');
      expect(appName.isNotEmpty, true);
      expect(appName.contains('Jeevika'), false);
      expect(appName.contains('Jivika'), false);

      // Verify no bilingual slash in activePathway
      final pathwayTitle = strings.tr('activePathway');
      expect(pathwayTitle.isNotEmpty, true);
      expect(pathwayTitle.contains('/'), false);

      // Verify questions
      final q1 = strings.tr('q1_text');
      final q2 = strings.tr('q2_text');
      final q3 = strings.tr('q3_text');
      expect(q1.isNotEmpty, true);
      expect(q2.isNotEmpty, true);
      expect(q3.isNotEmpty, true);

      // Verify question suggestions
      final s1 = strings.getSuggestionsForQuestion(0);
      final s2 = strings.getSuggestionsForQuestion(1);
      final s3 = strings.getSuggestionsForQuestion(2);
      expect(s1.isNotEmpty, true);
      expect(s2.isNotEmpty, true);
      expect(s3.isNotEmpty, true);

      // Verify bottom nav labels
      expect(strings.tr('home').isNotEmpty, true);
      expect(strings.tr('opportunities').isNotEmpty, true);
      expect(strings.tr('pathway').isNotEmpty, true);
      expect(strings.tr('mentors').isNotEmpty, true);
      expect(strings.tr('profile').isNotEmpty, true);

      // Verify verification badges
      expect(strings.tr('badge_VERIFIED').isNotEmpty, true);
      expect(strings.tr('badge_AI_INFERRED').isNotEmpty, true);
      expect(strings.tr('badge_SELF_DECLARED').isNotEmpty, true);
    }
  });

  testWidgets('HomeScreen renders in Tamil without overflow', (WidgetTester tester) async {
    final strings = AppStrings();
    strings.setLanguage('ta');
    final apiService = ApiService();
    await apiService.loginAsRole(role: 'BENEFICIARY');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: strings),
          ChangeNotifierProvider.value(value: apiService),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tamil app name
    expect(find.text('திறன் AI'), findsOneWidget);
    // Verify Tamil greeting
    expect(find.textContaining('வணக்கம்'), findsOneWidget);
    // Verify Tamil pathway title
    expect(find.text('உங்கள் இலக்குப் பாதை'), findsOneWidget);
    // Verify Tamil recommended opportunities
    expect(find.text('பரிந்துரைக்கப்பட்ட வேலைகள்'), findsOneWidget);
  });

  testWidgets('ProfileScreen displays editable options and saves changes', (WidgetTester tester) async {
    final strings = AppStrings();
    strings.setLanguage('en');
    final apiService = ApiService();
    await apiService.loginAsRole(role: 'BENEFICIARY');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: strings),
          ChangeNotifierProvider.value(value: apiService),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial profile data
    expect(find.text('My Livelihood Profile'), findsOneWidget);
    expect(find.text('Arun Kumar'), findsOneWidget);

    // Update profile
    final updated = apiService.currentProfile!.copyWith(
      fullName: 'Arun Kumar Verified',
      educationLevel: 'Diploma in Electrical Engineering',
    );
    apiService.updateCurrentProfile(updated);
    await tester.pumpAndSettle();

    expect(find.text('Arun Kumar Verified'), findsOneWidget);
    expect(find.text('Diploma in Electrical Engineering'), findsOneWidget);
  });

  testWidgets('VoiceOnboardingScreen displays 3 questions and editable summary', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final strings = AppStrings();
    strings.setLanguage('ta');
    final apiService = ApiService();
    await apiService.loginAsRole(role: 'BENEFICIARY');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: strings),
          ChangeNotifierProvider.value(value: apiService),
        ],
        child: const MaterialApp(
          home: VoiceOnboardingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Step 1 Question (Education)
    expect(find.text('குரல் வழியான அறிமுகம்'), findsOneWidget);
    expect(find.text('உங்கள் கல்வித் தகுதி என்ன?'), findsOneWidget);

    // Skip Question 1
    await tester.ensureVisible(find.text('தவிர்க்கவும்'));
    await tester.tap(find.text('தவிர்க்கவும்'));
    await tester.pumpAndSettle();

    // Verify Step 2 Question (Current Work)
    expect(find.text('தற்போது நீங்கள் என்ன வேலை அல்லது வாழ்வாதாரப் பணி செய்கிறீர்கள்?'), findsOneWidget);

    // Skip Question 2
    await tester.ensureVisible(find.text('தவிர்க்கவும்'));
    await tester.tap(find.text('தவிர்க்கவும்'));
    await tester.pumpAndSettle();

    // Verify Step 3 Question (Experience)
    expect(find.text('இந்தத் துறையில் உங்களுக்கு எத்தனை வருட நடைமுறை அனுபவம் உள்ளது?'), findsOneWidget);

    // Skip Question 3 -> Navigates to summary review
    await tester.ensureVisible(find.text('தவிர்க்கவும்'));
    await tester.tap(find.text('தவிர்க்கவும்'));
    await tester.pumpAndSettle();

    // Verify Confirmation review screen in Tamil
    expect(find.text('சுயவிவர உறுதிப்படுத்தல்'), findsOneWidget);
    expect(find.text('திறன் AI புரிந்து கொண்ட உங்கள் விவரங்கள்'), findsOneWidget);
    expect(find.text('உறுதி செய்து முகப்பிற்கு செல்க'), findsOneWidget);
  });
}
