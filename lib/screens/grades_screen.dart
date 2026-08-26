import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grade_models.dart';
import '../stores/grade_store.dart';

final _fmt = DateFormat('d MMM yyyy', 'fr_FR');

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  Color _couleur(double moyenne) {
    if (moyenne >= 14) return Colors.green;
    if (moyenne >= 10) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: AnimatedBuilder(
        animation: GradeStore.instance,
        builder: (context, _) {
          final store = GradeStore.instance;
          final moyenneGen = store.moyenneGenerale;

          return ListView(
            children: [
              if (moyenneGen != null)
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Moyenne générale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${moyenneGen.toStringAsFixed(2)} / 20',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _couleur(moyenneGen))),
                      ],
                    ),
                  ),
                ),
              if (store.subjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucune matière. Ajoute tes matières, puis tes notes.', textAlign: TextAlign.center),
                ),
              for (final s in store.subjects)
                Dismissible(
                  key: ValueKey(s.id),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => store.deleteSubject(s.id!),
                  child: ListTile(
                    title: Text(s.nom),
                    subtitle: Text('Coefficient ${s.coefficient}'),
                    trailing: Builder(builder: (context) {
                      final moy = store.moyenneMatiere(s.id!);
                      return Text(moy != null ? moy.toStringAsFixed(2) : '—',
                          style: TextStyle(color: moy != null ? _couleur(moy) : Colors.grey, fontWeight: FontWeight.bold));
                    }),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: s))),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const SubjectFormSheet()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SubjectFormSheet extends StatefulWidget {
  const SubjectFormSheet({super.key});
  @override
  State<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends State<SubjectFormSheet> {
  final nomCtrl = TextEditingController();
  double coefficient = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nouvelle matière', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom de la matière')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Coefficient: $coefficient')),
              IconButton(onPressed: () => setState(() => coefficient = (coefficient - 0.5).clamp(0.5, 10)), icon: const Icon(Icons.remove)),
              IconButton(onPressed: () => setState(() => coefficient = (coefficient + 0.5).clamp(0.5, 10)), icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: nomCtrl.text.isEmpty ? null : () {
              GradeStore.instance.addSubject(Subject(nom: nomCtrl.text, coefficient: coefficient));
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class SubjectDetailScreen extends StatelessWidget {
  final Subject subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.nom)),
      body: AnimatedBuilder(
        animation: GradeStore.instance,
        builder: (context, _) {
          final grades = GradeStore.instance.gradesBySubject[subject.id] ?? [];
          return ListView(
            children: [
              for (final g in grades)
                Dismissible(
                  key: ValueKey(g.id),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => GradeStore.instance.deleteGrade(g),
                  child: ListTile(
                    title: Text(g.titre),
                    subtitle: Text('Coef. ${g.coefficientNote} • ${_fmt.format(g.date)}'),
                    trailing: Text('${g.valeurSur20.toStringAsFixed(1)} / 20', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              if (grades.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Text('Aucune note pour cette matière.')),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => GradeFormSheet(subjectId: subject.id!)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GradeFormSheet extends StatefulWidget {
  final int subjectId;
  const GradeFormSheet({super.key, required this.subjectId});
  @override
  State<GradeFormSheet> createState() => _GradeFormSheetState();
}

class _GradeFormSheetState extends State<GradeFormSheet> {
  final titreCtrl = TextEditingController();
  final valeurCtrl = TextEditingController(text: '10');
  final baremeCtrl = TextEditingController(text: '20');
  double coefficientNote = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nouvelle note', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: titreCtrl, decoration: const InputDecoration(labelText: 'Titre (ex: Devoir 1)')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: valeurCtrl, decoration: const InputDecoration(labelText: 'Note'), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: baremeCtrl, decoration: const InputDecoration(labelText: 'Sur'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('Coefficient: $coefficientNote')),
              IconButton(onPressed: () => setState(() => coefficientNote = (coefficientNote - 0.5).clamp(0.5, 10)), icon: const Icon(Icons.remove)),
              IconButton(onPressed: () => setState(() => coefficientNote = (coefficientNote + 0.5).clamp(0.5, 10)), icon: const Icon(Icons.add)),
            ]),
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
    final valeur = double.tryParse(valeurCtrl.text) ?? 0;
    final bareme = double.tryParse(baremeCtrl.text) ?? 20;
    final valeurSur20 = bareme > 0 ? (valeur / bareme) * 20 : valeur;
    GradeStore.instance.addGrade(Grade(
      subjectId: widget.subjectId,
      titre: titreCtrl.text,
      valeurSur20: valeurSur20,
      coefficientNote: coefficientNote,
      date: DateTime.now(),
    ));
    Navigator.pop(context);
  }
}
