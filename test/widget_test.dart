import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acil_durum_takip/main.dart';
import 'package:acil_durum_takip/widgets/app_bottom_navigation.dart';
import 'package:acil_durum_takip/services/localization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      if (message == null) return null;
      final MethodCall call =
          const StandardMethodCodec().decodeMethodCall(message);
      final String assetKey = call.arguments as String;
      final File assetFile = File('assets/$assetKey');
      if (!await assetFile.exists()) {
        return null;
      }
      final Uint8List bytes = await assetFile.readAsBytes();
      return bytes.buffer.asByteData();
    });

    await LocalizationService.instance.loadLanguage('tr');
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('Ana Sayfa bottom navigation renders correctly',
      (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
    // Wait until the BottomNavigationBar appears or timeout after ~4s.
    // Some async initialization (providers, localization) can delay the
    // full build; polling is more robust than a single pumpAndSettle here.
    const int maxTries = 20;
    bool found = false;
    for (int i = 0; i < maxTries; i++) {
      if (find.byType(AppBottomNavigation).evaluate().isNotEmpty) {
        found = true;
        break;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(found, isTrue, reason: 'AppBottomNavigation not found after waiting');

    // AppBottomNavigation is a custom widget (not BottomNavigationBar)
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    final String homeLabel = LocalizationService.instance.t('nav.home');
    // label should be present in the nav
    expect(find.text(homeLabel), findsWidgets);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
