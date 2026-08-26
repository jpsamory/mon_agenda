import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../stores/trip_store.dart';

final _fmt = DateFormat('EEE d MMM, HH:mm', 'fr_FR');
const _moyens = ['Pied', 'Bus', 'Voiture', 'Taxi', 'Vélo', 'Moto', 'Autre'];

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Déplacements')),
      body: AnimatedBuilder(
        animation: TripStore.instance,
        builder: (context, _) {
          final trips = TripStore.instance.trips;
          if (trips.isEmpty) {
            return const Center(child: Text('Aucun déplacement enregistré.'));
          }
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, i) {
              final t = trips[i];
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => TripStore.instance.delete(t.id!),
                child: ListTile(
                  title: Text('${t.origine} → ${t.destination}'),
                  subtitle: Text('${_fmt.format(t.date)}${t.dureeMinutes > 0 ? ' • ${t.dureeMinutes} min' : ''}'),
                  trailing: Chip(label: Text(t.moyenTransport)),
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
          builder: (_) => const TripFormSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TripFormSheet extends StatefulWidget {
  const TripFormSheet({super.key});

  @override
  State<TripFormSheet> createState() => _TripFormSheetState();
}

class _TripFormSheetState extends State<TripFormSheet> {
  final origineCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime date = DateTime.now();
  String moyen = 'Pied';
  int duree = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nouveau trajet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: origineCtrl, decoration: const InputDecoration(labelText: 'Départ')),
            const SizedBox(height: 8),
            TextField(controller: destCtrl, decoration: const InputDecoration(labelText: 'Arrivée')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: moyen,
              decoration: const InputDecoration(labelText: 'Moyen de transport'),
              items: [for (final m in _moyens) DropdownMenuItem(value: m, child: Text(m))],
              onChanged: (v) => setState(() => moyen = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Durée: $duree min')),
                IconButton(onPressed: () => setState(() => duree = (duree - 5).clamp(0, 300)), icon: const Icon(Icons.remove)),
                IconButton(onPressed: () => setState(() => duree = (duree + 5).clamp(0, 300)), icon: const Icon(Icons.add)),
              ],
            ),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optionnel)')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: (origineCtrl.text.isEmpty || destCtrl.text.isEmpty) ? null : _save,
              child: const Text('Enregistrer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _save() {
    TripStore.instance.add(Trip(
      origine: origineCtrl.text,
      destination: destCtrl.text,
      date: date,
      moyenTransport: moyen,
      dureeMinutes: duree,
      notes: notesCtrl.text,
    ));
    Navigator.pop(context);
  }
}
