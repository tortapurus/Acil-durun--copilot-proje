import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acil_durum_takip/main.dart';
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
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final BottomNavigationBar bottomNav = tester.widget(
      find.byType(BottomNavigationBar),
    );

    expect(bottomNav.items.length, 6);
    expect(bottomNav.currentIndex, 0);

    final String homeLabel = LocalizationService.instance.t('nav.home');
    expect(bottomNav.items.first.label, homeLabel);
    expect(find.text(homeLabel), findsWidgets);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
