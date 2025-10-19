import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/product.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleProductReminder(Product product) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'product_reminders',
        'Ürün Hatırlatmaları',
        channelDescription: 'Son kullanma tarihi yaklaşan ürünler için hatırlatmalar',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Hatırlatma tarihi geçmişte mi kontrol et
      if (product.hatirlatmaTarihi.isBefore(DateTime.now())) {
        return; // Geçmiş tarihler için bildirim zamanlanmaz
      }

      await _notifications.zonedSchedule(
        product.id.hashCode,
        'Ürün Hatırlatması',
        '${product.ad} son kullanma tarihi yaklaşıyor!',
        tz.TZDateTime.from(product.hatirlatmaTarihi, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Exact alarm izni yoksa veya başka bir hata varsa sessizce devam et
      print('Bildirim zamanlanamadı: $e');
    }
  }

  Future<void> cancelProductReminder(String productId) async {
    await _notifications.cancel(productId.hashCode);
  }

  Future<void> showImmediateNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'immediate_notifications',
      'Anında Bildirimler',
      channelDescription: 'Önemli anında bildirimler',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }
}
