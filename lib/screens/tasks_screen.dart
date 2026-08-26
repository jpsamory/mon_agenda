import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../stores/task_store.dart';

final _fmt = DateFormat('EEE d MMM, HH:mm', 'fr_FR');

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tâches de la semaine')),
      body: AnimatedBuilder(
        animation: TaskStore.instance,
        builder: (context, _) {
          final tasks = TaskStore.instance.tasks;
          if (tasks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucune tâche. Tu seras averti 1h avant chaque échéance.', textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final t = tasks[i];
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => TaskStore.instance.delete(t),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(t.estFaite ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: t.estFaite ? Colors.green : null),
                    onPressed: () => TaskStore.instance.toggleFaite(t),
                  ),
                  title: Text(t.titre,
                      style: t.estFaite ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey) : null),
                  subtitle: Text(_fmt.format(t.echeance)),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TaskFormSheet(task: t),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const TaskFormSheet(task: null),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskFormSheet extends StatefulWidget {
  final TaskItem? task;
  const TaskFormSheet({super.key, required this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late TextEditingController titreCtrl;
  late TextEditingController detailsCtrl;
  late DateTime echeance;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    titreCtrl = TextEditingController(text: t?.titre ?? '');
    detailsCtrl = TextEditingController(text: t?.details ?? '');
    echeance = t?.echeance ?? DateTime.now().add(const Duration(hours: 2));
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
            Text(widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: titreCtrl, decoration: const InputDecoration(labelText: 'Titre')),
            const SizedBox(height: 8),
            TextField(controller: detailsCtrl, decoration: const InputDecoration(labelText: 'Détails (optionnel)'), maxLines: 2),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('À faire pour'),
              subtitle: Text(_fmt.format(echeance)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context, initialDate: echeance,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(echeance));
                if (time == null) return;
                setState(() => echeance = DateTime(date.year, date.month, date.day, time.hour, time.minute));
              },
            ),
            const Text('Un rappel sera envoyé 1h avant, même hors connexion.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: titreCtrl.text.isEmpty ? null : _save,
              child: const Text('Enregistrer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (widget.task != null) {
      final t = widget.task!;
      t.titre = titreCtrl.text;
      t.details = detailsCtrl.text;
      t.echeance = echeance;
      TaskStore.instance.update(t);
    } else {
      TaskStore.instance.add(TaskItem(titre: titreCtrl.text, details: detailsCtrl.text, echeance: echeance));
    }
    Navigator.pop(context);
  }
}
