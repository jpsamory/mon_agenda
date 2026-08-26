import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'tasks_screen.dart';
import 'grades_screen.dart';
import 'trips_screen.dart';
import 'activities_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _index = 0;

  final _screens = const [
    ScheduleScreen(),
    TasksScreen(),
    GradesScreen(),
    TripsScreen(),
    ActivitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Emploi du temps'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tâches'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.directions_walk), label: 'Trajets'),
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Activités'),
        ],
      ),
    );
  }
}
