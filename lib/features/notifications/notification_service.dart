import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';

/// Serwis powiadomień lokalnych (przypomnienia o celu + gratulacje).
/// Wstrzykiwany w [main] przez override [notificationServiceProvider].
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider must be overridden'),
);

class NotificationService {
  NotificationService(this._prefs);

  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const String _channelId = 'movequest_reminders';
  static const int _reminderId = 1001;

  /// Tłumaczenia dla zapisanego języka (powiadomienia są poza kontekstem UI).
  Future<AppLocalizations> _l10n() {
    final code = _prefs.getString('app_locale') ?? 'en';
    return AppLocalizations.delegate.load(Locale(code));
  }

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Zostaw domyślną strefę (UTC), jeśli nie uda się wykryć.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _ready = true;
  }

  /// Prosi o zgodę na powiadomienia (Android 13+ / iOS).
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<NotificationDetails> _details(AppLocalizations l10n) async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Codzienne przypomnienie o dziennym celu (o zadanej godzinie).
  Future<void> scheduleDailyReminder({int hour = 18, int minute = 0}) async {
    if (!_ready) return;
    final l10n = await _l10n();
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: l10n.notifReminderTitle,
      body: l10n.notifReminderBody,
      scheduledDate: when,
      notificationDetails: await _details(l10n),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Gratulacje po osiągnięciu dziennego celu kroków.
  Future<void> showGoalReached() async {
    if (!_ready) return;
    final l10n = await _l10n();
    await _plugin.show(
      id: 1002,
      title: l10n.notifGoalReachedTitle,
      body: l10n.notifGoalReachedBody,
      notificationDetails: await _details(l10n),
    );
  }

  /// Powiadomienie po ukończeniu questa.
  Future<void> showQuestCompleted(int points) async {
    if (!_ready) return;
    final l10n = await _l10n();
    await _plugin.show(
      id: 1003,
      title: l10n.notifQuestTitle,
      body: l10n.notifQuestBody(points),
      notificationDetails: await _details(l10n),
    );
  }
}
