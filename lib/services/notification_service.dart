import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Notifications 100% locales : aucun serveur, aucun push distant.
/// Ça fonctionne même en mode avion.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(iOS: iosSettings, android: androidSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Planifie un rappel 1h avant l'échéance de la tâche.
  Future<void> planifierRappel({
    required int notificationId,
    required String titre,
    required DateTime echeance,
  }) async {
    final dateRappel = echeance.subtract(const Duration(hours: 1));
    if (dateRappel.isBefore(DateTime.now())) return; // trop tard, on ne planifie pas

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'taches_channel',
        'Rappels de tâches',
        channelDescription: 'Rappel 1h avant une tâche prévue',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      notificationId,
      'À faire dans 1h',
      titre,
      tz.TZDateTime.from(dateRappel, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> annulerRappel(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  Future<void> replanifierRappel({
    required int notificationId,
    required String titre,
    required DateTime echeance,
  }) async {
    await annulerRappel(notificationId);
    await planifierRappel(notificationId: notificationId, titre: titre, echeance: echeance);
  }
}
