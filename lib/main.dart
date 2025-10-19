import 'package:acil_durum_takip/localization/app_localizations.dart';
import 'package:acil_durum_takip/screens/ana_sayfa.dart';
import 'package:acil_durum_takip/providers/product_provider.dart';
import 'package:acil_durum_takip/providers/theme_provider.dart';
import 'package:acil_durum_takip/providers/locale_provider.dart';
import 'package:acil_durum_takip/providers/category_provider.dart';
import 'package:acil_durum_takip/services/notification_service.dart';
import 'package:acil_durum_takip/models/product.dart';
import 'package:acil_durum_takip/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive başlatılması
  await Hive.initFlutter();
  
  // Adaptörleri kaydet
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CategoryAdapter());
  
  // Timezone başlatılması
  tz.initializeTimeZones();
  
  // Notification service başlatılması
  await NotificationService().init();
  
  runApp(const AcilDurumTakipApp());
}

class AcilDurumTakipApp extends StatelessWidget {
  const AcilDurumTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..init()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..init()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'Acil Durum Takip',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: localeProvider.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AnaSayfa(),
          );
        },
      ),
    );
  }
}
