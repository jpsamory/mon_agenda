import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'stores/schedule_store.dart';
import 'stores/task_store.dart';
import 'stores/trip_store.dart';
import 'stores/grade_store.dart';
import 'stores/activity_store.dart';
import 'screens/main_tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  // Notifications locales : aucun appel réseau, fonctionne hors connexion.
  await NotificationService.instance.init();

  // Chargement initial de toutes les données locales (SQLite) avant d'afficher l'UI.
  await Future.wait([
    ScheduleStore.instance.load(),
    TaskStore.instance.load(),
    TripStore.instance.load(),
    GradeStore.instance.load(),
    ActivityStore.instance.load(),
  ]);

  runApp(const MonAgendaApp());
}

class MonAgendaApp extends StatelessWidget {
  const MonAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3478F6),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3478F6),
        brightness: Brightness.dark,
      ),
      home: const MainTabScreen(),
    );
  }
}
