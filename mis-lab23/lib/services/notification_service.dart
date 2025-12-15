import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _tzReady = false;
  bool _localReady = false;

  /// Call this after Firebase.initializeApp(...) in main()
  Future<void> init() async {
    await _initLocalNotifications();
    await _initTimezone();
    await _initFcm();

    await scheduleDailyReminder(hour: 01, minute: 16);
  }

  Future<void> _initLocalNotifications() async {
    if (_localReady) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
      },
    );

    // Android 13+ permission prompt (safe no-op on older versions)
    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _localReady = true;
  }

  Future<void> _initTimezone() async {
    if (_tzReady) return;

    tzdata.initializeTimeZones();

    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone(); // TimezoneInfo
      // You said your TimezoneInfo has `identifier`
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      // Fallback if device returns an unknown timezone name
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    _tzReady = true;
  }

  Future<void> _initFcm() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await messaging.subscribeToTopic('daily_recipe');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title;
      final body = message.notification?.body;

      if (title != null || body != null) {
        await showNow(
          title: title ?? 'Notification',
          body: body ?? '',
        );
      }
    });
  }

  Future<void> showNow({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_recipe',
      'Daily Recipe',
      channelDescription: 'Daily recipe reminder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(1000, title, body, details);
  }

  /// Schedule a notification every day at [hour]:[minute] in the device timezone.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _initLocalNotifications();
    await _initTimezone();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_recipe',
      'Daily Recipe',
      channelDescription: 'Daily recipe reminder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // Try exact first; if not permitted (Android 12+/13+), fall back to inexact.
    try {
      await _local.zonedSchedule(
        1001,
        'Рецепт на денот',
        'Отвори ја апликацијата за рандом рецепт.',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_recipe',
      );
    } on PlatformException catch (e) {
      // This is the one you got: exact_alarms_not_permitted
      if (e.code == 'exact_alarms_not_permitted') {
        await _local.zonedSchedule(
          1001,
          'Рецепт на денот',
          'Отвори ја апликацијата за рандом рецепт.',
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'daily_recipe',
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelDailyReminder() async {
    await _local.cancel(1001);
  }

  Future<void> cancelAll() async {
    await _local.cancelAll();
  }
}