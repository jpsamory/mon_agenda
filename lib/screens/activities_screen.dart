import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity_item.dart';
import '../stores/activity_store.dart';

final _fmt = DateFormat('EEE d MMM, HH:mm', 'fr_FR');

/// Point 6 : une seule structure d'écran, réutilisée pour "Salle de sport" et "Matchs du Barça"
/// via un TabBar, exactement comme le point 1 réutilise le même widget pour l'emploi du temps.
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activités'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.fitness_center), text: 'Sport'),
            Tab(icon: Icon(Icons.sports_soccer), text: 'Barça'),
          ]),
        ),
        body: const TabBarView(children: [
          _ActivityListView(categorie: ActivityCategory.sport),
          _ActivityListView(categorie: ActivityCategory.barca),
        ]),
      ),
    );
  }
}

class _ActivityListView extends StatelessWidget {
  final ActivityCategory categorie;
  const _ActivityListView({required this.categorie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: ActivityStore.instance,
        builder: (context, _) {
          final items = ActivityStore.instance.byCategory(categorie);
          if (items.isEmpty) {
            return Center(child: Text('Aucun élément dans "${categorie.label}".'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => ActivityStore.instance.delete(item.id!),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(item.estFait ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: item.estFait ? Colors.green : null),
                    onPressed: () => ActivityStore.instance.toggleFait(item),
                  ),
                  title: Text(item.titre),
                  subtitle: Text(_fmt.format(item.date)),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ActivityFormSheet(categorie: categorie, item: item),
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
          builder: (_) => ActivityFormSheet(categorie: categorie, item: null),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActivityFormSheet extends StatefulWidget {
  final ActivityCategory categorie;
  final ActivityItem? item;
  const ActivityFormSheet({super.key, required this.categorie, required this.item});

  @override
  State<ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<ActivityFormSheet> {
  late TextEditingController titreCtrl;
  late TextEditingController detailsCtrl;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    titreCtrl = TextEditingController(text: it?.titre ?? '');
    detailsCtrl = TextEditingController(text: it?.details ?? '');
    date = it?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.categorie == ActivityCategory.sport ? 'Exercice (ex: Séance jambes)' : 'Match (ex: Barça - Real)';
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.item == null ? 'Ajouter' : 'Modifier', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: titreCtrl, decoration: InputDecoration(labelText: label)),
            const SizedBox(height: 8),
            TextField(controller: detailsCtrl, decoration: const InputDecoration(labelText: 'Détails (optionnel)'), maxLines: 2),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(_fmt.format(date)),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (d == null || !context.mounted) return;
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(date));
                if (t == null) return;
                setState(() => date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
              },
            ),
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
    if (widget.item != null) {
      final it = widget.item!;
      it.titre = titreCtrl.text;
      it.details = detailsCtrl.text;
      it.date = date;
      ActivityStore.instance.update(it);
    } else {
      ActivityStore.instance.add(ActivityItem(
        categorie: widget.categorie,
        titre: titreCtrl.text,
        details: detailsCtrl.text,
        date: date,
      ));
    }
    Navigator.pop(context);
  }
}
