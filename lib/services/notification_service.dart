import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Notification initialize failed: $error');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('Notification initialize unexpected error: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'acil_durum_channel',
            'Acil Durum Bildirimleri',
            channelDescription: 'Ürünlerin son kullanma tarihi hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            playSound: playSound,
            enableVibration: enableVibration,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: playSound,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Notification schedule failed: $error');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('Notification schedule unexpected error: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'acil_durum_channel',
          'Acil Durum Bildirimleri',
          channelDescription: 'Acil durum takip sistemi bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          playSound: playSound,
          enableVibration: enableVibration,
        );

    final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notificationsPlugin.show(id, title, body, platformDetails);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Notification show failed: $error');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('Notification show unexpected error: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Notification cancel failed: $error');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('Notification cancel unexpected error: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Notification cancelAll failed: $error');
      debugPrint('$stackTrace');
    } catch (error, stackTrace) {
      debugPrint('Notification cancelAll unexpected error: $error');
      debugPrint('$stackTrace');
    }
  }
}
