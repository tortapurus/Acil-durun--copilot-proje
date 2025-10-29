import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'screens/ana_sayfa.dart';
import 'screens/acil_durum_paneli.dart';
import 'screens/urun_listesi.dart';
import 'screens/yeni_urun_ekle.dart';
import 'screens/urun_detay.dart';
import 'screens/bilgi_merkezi.dart';
import 'screens/depo_paneli.dart';
import 'screens/depo_detay.dart';
import 'screens/canta_detay.dart';
import 'screens/barkod_tara.dart';
import 'screens/yeni_canta_olustur.dart';
import 'screens/ayarlar_ekrani.dart';
import 'screens/language_selection_screen.dart';
import 'screens/acil_durum_numaralari.dart';
import 'screens/yonetim_paneli.dart';
import 'screens/uygulama_bilgileri_ekrani.dart';
import 'theme/theme_colors.dart';
import 'services/localization_service.dart';
import 'services/data_service.dart';
import 'services/settings_service.dart';
import 'models/product.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Tüm debug çizgilerini ve overflow indicatorlarını kapat
  debugPaintSizeEnabled = false;
  debugDisableClipLayers = false;
  debugDisablePhysicalShapeLayers = false;
  debugDisableOpacityLayers = false;

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Localization servisini başlat
  await LocalizationService.instance.loadSavedLanguage();
  await NotificationService().initialize();
  await SettingsService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalizationService>.value(
          value: LocalizationService.instance,
        ),
        ChangeNotifierProvider<DataService>.value(value: DataService.instance),
        ChangeNotifierProvider<SettingsService>.value(
          value: SettingsService.instance,
        ),
      ],
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          final settings = context.watch<SettingsService>();
          return MaterialApp(
            title: 'Acil Durum Takip',
            debugShowCheckedModeBanner: false,
            debugShowMaterialGrid: false,
            showPerformanceOverlay: false,
            checkerboardRasterCacheImages: false,
            checkerboardOffscreenLayers: false,
            showSemanticsDebugger: false,
            theme: settings.themeData.copyWith(
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: settings.palette.bgCard,
                selectedItemColor: ThemeColors.pastelGreen,
                unselectedItemColor: ThemeColors.textGrey,
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', ''),
              Locale('en', ''),
              Locale('ar', ''),
              Locale('de', ''),
              Locale('es', ''),
              Locale('fr', ''),
              Locale('it', ''),
              Locale('pt', ''),
              Locale('ru', ''),
              Locale('zh', ''),
              Locale('ja', ''),
              Locale('ko', ''),
              Locale('hi', ''),
              Locale('bn', ''),
              Locale('ur', ''),
              Locale('fa', ''),
              Locale('am', ''),
              Locale('so', ''),
              Locale('my', ''),
              Locale('uk', ''),
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const AnaSayfa(),
              '/acil-durum': (context) => const AcilDurumPaneli(),
              '/depo': (context) => const DepoPaneli(),
              '/depo-detay': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                String? depotId;
                if (args is String) {
                  depotId = args;
                } else if (args is Map<String, dynamic>) {
                  depotId = args['depotId'] as String?;
                }
                return DepoDetay(depotId: depotId);
              },
              '/canta-detay': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                String? bagId;
                if (args is String) {
                  bagId = args;
                } else if (args is Map<String, dynamic>) {
                  bagId = args['bagId'] as String?;
                }
                return CantaDetay(bagId: bagId);
              },
              '/barkod-tara': (context) => const BarkodTaraEkrani(),
              '/urunler': (context) => const UrunListesi(),
              '/yeni-urun': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;

                String? imagePath;
                Uint8List? imageBytes;
                Product? initialProduct;

                if (args is String) {
                  initialProduct = DataService.instance.getProductById(args);
                } else if (args is Product) {
                  initialProduct = args;
                } else if (args is Map<String, dynamic>) {
                  imagePath = args['imagePath'] as String?;
                  final dynamic bytes = args['imageBytes'];
                  if (bytes is Uint8List) {
                    imageBytes = bytes;
                  } else if (bytes is List<int>) {
                    imageBytes = Uint8List.fromList(bytes);
                  }

                  final dynamic productArg = args['product'];
                  if (productArg is Product) {
                    initialProduct = productArg;
                  } else {
                    final String? productId = args['productId'] as String?;
                    if (productId != null) {
                      initialProduct = DataService.instance.getProductById(
                        productId,
                      );
                    }
                  }
                }

                return YeniUrunEkle(
                  initialImagePath: imagePath,
                  initialImageBytes: imageBytes,
                  initialProduct: initialProduct,
                );
              },
              '/urun-detay': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                String? productId;

                if (args is String) {
                  productId = args;
                } else if (args is Map<String, dynamic>) {
                  productId = args['productId'] as String?;
                }

                return UrunDetay(productId: productId);
              },
              '/bilgi': (context) => const BilgiMerkezi(),
              '/yeni-canta': (context) => const YeniCantaOlustur(),
              '/ayarlar': (context) => const AyarlarEkrani(),
              '/yonetim-paneli': (context) => const YonetimPaneli(),
              '/app-info': (context) => const UygulamaBilgileriEkrani(),
              '/language-selection': (context) =>
                  const LanguageSelectionScreen(),
              '/acil-numaralar': (context) => const AcilDurumNumaralari(),
            },
          );
        },
      ),
    );
  }
}
