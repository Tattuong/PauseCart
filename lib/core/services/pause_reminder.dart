import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../pause/pause_book.dart';

class PauseReminder {
  PauseReminder._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static var _ready = false;

  static Future<void> sync(PauseBook book, {required bool enabled}) async {
    try {
      await _ensure();
      await _plugin.cancelAll();
      if (!enabled) return;
      final now = tz.TZDateTime.now(tz.local);
      for (final item in book.items) {
        if (!item.remind || item.status != PauseStatus.waiting) continue;
        final when = tz.TZDateTime.from(item.dueAt, tz.local);
        if (!when.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          item.id.hashCode & 0x7fffffff,
          'Time to look at ${item.name}',
          'The wait is over. Still want it, later, or let it go?',
          when,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'pausecart_due',
              'Wait ended',
              channelDescription: 'Reminds you when an item on the shelf is due',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (_) {}
  }

  static Future<void> _ensure() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    _ready = true;
  }
}
