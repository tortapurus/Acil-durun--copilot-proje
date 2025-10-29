import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:acil_durum_takip/services/localization_service.dart';
import 'package:acil_durum_takip/services/data_service.dart';
import 'package:acil_durum_takip/services/settings_service.dart';
import 'package:acil_durum_takip/models/depot.dart';
import 'package:acil_durum_takip/models/product.dart';
import 'package:acil_durum_takip/screens/depo_paneli.dart';
import 'package:acil_durum_takip/screens/depo_detay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Load localization (uses assets/lang/tr.json)
    await LocalizationService.instance.loadLanguage('tr');
    // Reset data service state via importSnapshot with empty data
    await DataService.instance.importSnapshot({
      'version': 1,
      'generatedAt': DateTime.now().toIso8601String(),
      'products': [],
      'bags': [],
      'depots': [],
      'customCategories': [],
    });
  });

  testWidgets('Tap depot card opens depot detail and shows products', (WidgetTester tester) async {
    final data = DataService.instance;

    final depot = Depot(id: 'd1', name: 'Test Depo');
    data.addDepot(depot);

    final product = Product(
      id: 'p1',
      name: 'Test Ürün',
      categoryId: 'cat1',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      reminderDate: DateTime.now().add(const Duration(days: 5)),
      storageId: depot.id,
      storageType: StorageLocationType.depot,
      createdAt: DateTime.now(),
    );

    data.addProduct(product);

    // Build widget tree with providers and routes
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LocalizationService>.value(value: LocalizationService.instance),
          ChangeNotifierProvider<DataService>.value(value: DataService.instance),
          ChangeNotifierProvider<SettingsService>.value(value: SettingsService.instance),
        ],
        child: MaterialApp(
          home: const DepoPaneli(),
          routes: {
            '/depo-detay': (context) => DepoDetay(depotId: ModalRoute.of(context)!.settings.arguments is Map ? (ModalRoute.of(context)!.settings.arguments as Map)['depotId'] as String? : null),
            '/urun-detay': (context) => const SizedBox(),
          },
        ),
      ),
    );

  await tester.pumpAndSettle();

  // Ensure the depot card is visible (scroll if needed) before tapping
  await tester.ensureVisible(find.text('Test Depo'));
  await tester.pumpAndSettle();

    // Depot card should be visible
    expect(find.text('Test Depo'), findsOneWidget);

  // Tap depot card
  await tester.tap(find.text('Test Depo'));
    await tester.pumpAndSettle();

    // Now we should see product in depot detail
    expect(find.text('Test Ürün'), findsOneWidget);
  });
}
