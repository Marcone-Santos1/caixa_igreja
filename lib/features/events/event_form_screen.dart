import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/date_time_utils.dart';
import 'event_delete_dialog.dart';

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

  Future<void> _confirmDeleteEvent() async {
    final id = widget.eventId;
    if (id == null) return;
    final title = _title.text.trim().isEmpty ? 'este evento' : _title.text.trim();
    final sure = await confirmDeleteEventDialog(context, eventTitle: title);
    if (!sure || !mounted) return;
    final db = ref.read(appDatabaseProvider);
    await db.deleteEventCascade(id);
    if (!mounted) return;
    context.go('/events');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isEdit = widget.eventId != null;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar evento' : 'Novo evento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: kCaixaScreenPadding.copyWith(bottom: 32),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Observações',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Data do evento'),
                subtitle: Text(
                  MaterialLocalizations.of(context).formatFullDate(_day),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _pickDay,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Salvar'),
            ),
            if (isEdit) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _confirmDeleteEvent,
                icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                label: Text(
                  'Excluir evento',
                  style: TextStyle(color: scheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.65)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
