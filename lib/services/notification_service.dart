import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static const String _routineChannelId = 'glicera_routine_channel_v4';
  static const String _routineChannelName = 'Pengingat Rutinitas';
  static const String _routineChannelDescription =
      'Pengingat jadwal rutinitas harian Glicera';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() => _instance;
  NotificationService._internal();

  static int buildNotifId(int routineIndex, int timeIndex) =>
      routineIndex * 100 + timeIndex;

  Future<void> initialize() async {
    tzdata.initializeTimeZones();

    // FIX: Timezone Asia/Jakarta dengan fallback
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint('Timezone error, using UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await _createAndroidNotificationChannel(android);
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _onNotificationResponse(
      NotificationResponse response) async {}

  Future<void> _createAndroidNotificationChannel(
    AndroidFlutterLocalNotificationsPlugin? android,
  ) async {
    if (android == null) return;

    const channel = AndroidNotificationChannel(
      _routineChannelId,
      _routineChannelName,
      description: _routineChannelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    try {
      await android.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('createNotificationChannel error: $e');
    }
  }

  Future<NotificationDetails> _buildDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final playSound = prefs.getBool('notifikasi_sound_enabled') ?? true;

    final androidDetails = AndroidNotificationDetails(
      _routineChannelId,
      _routineChannelName,
      channelDescription: _routineChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: true,
      // FIX: Tambah channel untuk Samsung One UI agar tidak diblokir
      channelShowBadge: true,
      autoCancel: true,
      styleInformation: const DefaultStyleInformation(true, true),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final canScheduleExact =
          await android?.canScheduleExactNotifications() ?? true;

      return canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (e) {
      debugPrint('Exact alarm permission check error: $e');
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    } catch (e) {
      debugPrint('areNotificationsEnabled error: $e');
      return true;
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final details = await _buildDetails();
      await _plugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('showNotification error: $e');
      rethrow;
    }
  }

  Future<void> scheduleOnceNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      final details = await _buildDetails();
      final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);
      debugPrint('Scheduling once notif id=$id at $tzScheduled (local: $scheduledTime)');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: await _androidScheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('Scheduled once notif id=$id SUCCESS');
    } catch (e) {
      debugPrint('scheduleOnceNotification error (id=$id): $e');
      rethrow;
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      final details = await _buildDetails();
      final scheduledTime = _nextInstanceOfTime(hour, minute);
      debugPrint('Scheduling daily notif id=$id at $scheduledTime');
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: await _androidScheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint('Scheduled daily notif id=$id SUCCESS');
    } catch (e) {
      debugPrint('scheduleDailyNotification error (id=$id): $e');
      rethrow;
    }
  }

  Future<void> scheduleWeeklyNotifications({
    required int baseId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> weekdays,
  }) async {
    final details = await _buildDetails();
    final now = tz.TZDateTime.now(tz.local);
    int counter = 0;

    for (int week = 0; week < 4; week++) {
      for (final weekday in weekdays) {
        int daysUntil = (weekday - now.weekday + 7) % 7;
        if (daysUntil == 0 && week == 0) {
          final todayScheduled = tz.TZDateTime(
              tz.local, now.year, now.month, now.day, hour, minute);
          if (todayScheduled.isBefore(now)) {
            daysUntil = 7;
          }
        }

        final target = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + daysUntil + (week * 7),
          hour,
          minute,
        );

        try {
          await _plugin.zonedSchedule(
            baseId + counter,
            title,
            body,
            target,
            details,
            androidScheduleMode: await _androidScheduleMode(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (e) {
          debugPrint('Error schedule weekly notif id ${baseId + counter}: $e');
        }
        counter++;
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('cancelNotification error (id=$id): $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('cancelAllNotifications error: $e');
    }
  }

  Future<void> cancelRoutineNotifications({
    required int routineIndex,
    int maxTimeSlots = 100,
    int maxWeeklySlots = 28,
  }) async {
    try {
      for (int i = 0; i < maxTimeSlots; i++) {
        await _plugin.cancel(buildNotifId(routineIndex, i));
      }
      final baseId = buildNotifId(routineIndex, 0);
      for (int i = 0; i < maxWeeklySlots; i++) {
        await _plugin.cancel(baseId + i);
      }
    } catch (e) {
      debugPrint('cancelRoutineNotifications error (index=$routineIndex): $e');
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime([DateTime? date]) {
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
