import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/date_time_utils.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId});

  final int? eventId;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  DateTime _day = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _notes = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final id = widget.eventId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final db = ref.read(appDatabaseProvider);
    final e = await (db.select(db.events)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (!mounted) return;
    if (e == null) {
      setState(() => _loading = false);
      return;
    }
    _title.text = e.title;
    _notes.text = e.notes;
    _day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dayMs = startOfLocalDayMs(_day);
    final db = ref.read(appDatabaseProvider);

    final companion = EventsCompanion(
      title: Value(_title.text.trim()),
      notes: Value(_notes.text.trim()),
      dateEpochMs: Value(dayMs),
    );

    final id = widget.eventId;
    if (id == null) {
      await db.into(db.events).insert(companion);
    } else {
      await (db.update(db.events)..where((t) => t.id.equals(id))).write(companion);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isEdit = widget.eventId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar evento' : 'Novo evento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data do evento'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatFullDate(_day),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDay,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
