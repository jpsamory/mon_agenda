import 'package:flutter/material.dart';
import '../models/course.dart';
import '../stores/schedule_store.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emploi du temps')),
      body: AnimatedBuilder(
        animation: ScheduleStore.instance,
        builder: (context, _) {
          final store = ScheduleStore.instance;
          final parJour = store.courseParJour;

          if (store.courses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun cours. Ajoute ton premier cours : il reviendra chaque semaine automatiquement.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            children: [
              for (int jour = 0; jour < 7; jour++)
                if (parJour[jour] != null && parJour[jour]!.isNotEmpty)
                  _JourSection(jour: jour, cours: parJour[jour]!..sort((a, b) => a.heureDebut - b.heureDebut)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openForm(BuildContext context, Course? course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CourseFormSheet(course: course),
    );
  }
}

class _JourSection extends StatelessWidget {
  final int jour;
  final List<Course> cours;
  const _JourSection({required this.jour, required this.cours});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(Course.joursNoms[jour],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        for (final c in cours)
          Dismissible(
            key: ValueKey(c.id),
            direction: DismissDirection.endToStart,
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => ScheduleStore.instance.delete(c.id!),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: _colorFromHex(c.couleurHex), radius: 6),
              title: Text(c.matiere),
              subtitle: Text('Salle ${c.salle}'),
              trailing: Text(c.horaireTexte),
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => CourseFormSheet(course: c),
              ),
            ),
          ),
      ],
    );
  }

  Color _colorFromHex(String hex) => Color(int.parse('FF$hex', radix: 16));
}

class CourseFormSheet extends StatefulWidget {
  final Course? course;
  const CourseFormSheet({super.key, this.course});

  @override
  State<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<CourseFormSheet> {
  late TextEditingController matiereCtrl;
  late TextEditingController salleCtrl;
  late int jour;
  late TimeOfDay debut;
  late TimeOfDay fin;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    matiereCtrl = TextEditingController(text: c?.matiere ?? '');
    salleCtrl = TextEditingController(text: c?.salle ?? '');
    jour = c?.jour ?? 0;
    debut = TimeOfDay(hour: c?.heureDebut ?? 8, minute: c?.minuteDebut ?? 0);
    fin = TimeOfDay(hour: c?.heureFin ?? 9, minute: c?.minuteFin ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.course == null ? 'Nouveau cours' : 'Modifier le cours',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: matiereCtrl, decoration: const InputDecoration(labelText: 'Matière')),
            const SizedBox(height: 8),
            TextField(controller: salleCtrl, decoration: const InputDecoration(labelText: 'Salle')),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: jour,
              decoration: const InputDecoration(labelText: 'Jour'),
              items: [for (int i = 0; i < 7; i++) DropdownMenuItem(value: i, child: Text(Course.joursNoms[i]))],
              onChanged: (v) => setState(() => jour = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Début'),
                    subtitle: Text(debut.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: debut);
                      if (t != null) setState(() => debut = t);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Fin'),
                    subtitle: Text(fin.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: fin);
                      if (t != null) setState(() => fin = t);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: matiereCtrl.text.isEmpty ? null : _save,
              child: const Text('Enregistrer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (widget.course != null) {
      final c = widget.course!;
      c.matiere = matiereCtrl.text;
      c.salle = salleCtrl.text;
      c.jour = jour;
      c.heureDebut = debut.hour;
      c.minuteDebut = debut.minute;
      c.heureFin = fin.hour;
      c.minuteFin = fin.minute;
      ScheduleStore.instance.update(c);
    } else {
      ScheduleStore.instance.add(Course(
        matiere: matiereCtrl.text,
        salle: salleCtrl.text,
        jour: jour,
        heureDebut: debut.hour,
        minuteDebut: debut.minute,
        heureFin: fin.hour,
        minuteFin: fin.minute,
      ));
    }
    Navigator.pop(context);
  }
}
