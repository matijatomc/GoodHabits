import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize timezone data
    tz.initializeTimeZones();
  }

  Future<void> scheduleDailyNotification(
      int id, String title, String body, TimeOfDay time) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'daily_channel_id', 'daily_channel_name',
        channelDescription: 'Daily Reminders',
        importance: Importance.max,
        priority: Priority.high);

    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Convert TimeOfDay to tz.TZDateTime
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate.isBefore(now)
          ? scheduledDate.add(Duration(days: 1))
          : scheduledDate, // Schedule for the next day if time is already passed
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily at the same time
    );
  }
}
