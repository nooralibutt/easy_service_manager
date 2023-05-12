import 'dart:io';

import 'package:easy_service_manager/src/models/app_info.dart';
import 'package:easy_service_manager/src/models/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EasyNotificationManager {
  AppInfo? appInfo;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isAndroidNotificationsEnabled = false;

  Future<void> init({AppInfo? appInfo}) async {
    this.appInfo = appInfo;
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const androidSettings = AndroidInitializationSettings('app_icon');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
        android: androidSettings, iOS: initializationSettingsDarwin);

    _flutterLocalNotificationsPlugin.initialize(settings);

    tz.initializeTimeZones();

    _isAndroidNotificationsEnabled = await _isAndroidPermissionGranted();
    await _requestPermissions();
  }

  Future<bool> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      return granted;
    }
    return false;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid && !_isAndroidNotificationsEnabled) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      _isAndroidNotificationsEnabled = granted ?? false;
    }

    if (Platform.isAndroid && !_isAndroidNotificationsEnabled) return;
  }

  Future<void> scheduleAllNotifications(List<String> notificationsList) async {
    if (Platform.isAndroid && !_isAndroidNotificationsEnabled) return;

    await _cancelAllNotifications();

    for (int i = 0; i < 32; i++) {
      await scheduleNotification(
          NotificationModel(
              id: i,
              title: appInfo?.appName ?? '',
              body: notificationsList[i % notificationsList.length]),
          Duration(days: i + 1));
    }
  }

  Future<void> scheduleNotification(
      NotificationModel model, Duration duration) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        model.id,
        model.title,
        model.body,
        tz.TZDateTime.now(tz.local).add(duration),
        NotificationDetails(
          android: AndroidNotificationDetails(
            appInfo?.packageName ?? '',
            appInfo?.appName ?? '',
            channelDescription: 'Our notifications will be displayed here',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _cancelAllNotifications() =>
      _flutterLocalNotificationsPlugin.cancelAll();

  Future<void> cancelNotification(int id, {String? tag}) =>
      _flutterLocalNotificationsPlugin.cancel(id, tag: tag);
}
