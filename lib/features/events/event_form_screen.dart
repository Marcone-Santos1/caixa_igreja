import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/date_time_utils.dart';
import 'event_delete_flow.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId});

  final String? eventId;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _pixKey;
  late final TextEditingController _pixMerchantName;
  late final TextEditingController _pixMerchantCity;
  DateTime _day = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _notes = TextEditingController();
    _pixKey = TextEditingController();
    _pixMerchantName = TextEditingController();
    _pixMerchantCity = TextEditingController();
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
    _pixKey.text = e.pixKey ?? '';
    _pixMerchantName.text = e.pixMerchantName ?? '';
    _pixMerchantCity.text = e.pixMerchantCity ?? '';
    _day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _pixKey.dispose();
    _pixMerchantName.dispose();
    _pixMerchantCity.dispose();
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

    final id = widget.eventId;
    final idToUse = id ?? db.generateUuid();
    final companion = EventsCompanion(
      id: id == null ? Value(idToUse) : const Value.absent(),
      title: Value(_title.text.trim()),
      notes: Value(_notes.text.trim()),
      dateEpochMs: Value(dayMs),
      pixKey: Value(_pixKey.text.trim().isEmpty ? null : _pixKey.text.trim()),
      pixMerchantName: Value(_pixMerchantName.text.trim().isEmpty ? null : _pixMerchantName.text.trim()),
      pixMerchantCity: Value(_pixMerchantCity.text.trim().isEmpty ? null : _pixMerchantCity.text.trim()),
    );

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
    final db = ref.read(appDatabaseProvider);
    final event = await (db.select(db.events)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    if (event == null || !mounted) return;
    final done = await confirmAndDeleteEvent(context, ref, event);
    if (!done || !mounted) return;
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
            const SizedBox(height: 16),

            // Card de Configurações do PIX para este Evento
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: CaixaAppTheme.marianBlue.withValues(alpha: 0.2)),
              ),
              color: CaixaAppTheme.marianBlue.withValues(alpha: 0.03),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CaixaAppTheme.marianBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, color: CaixaAppTheme.marianBlue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chave PIX do Evento',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: CaixaAppTheme.marianBlue,
                                ),
                              ),
                              Text(
                                'Gera QR Code com valor dinâmico no caixa',
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pixKey,
                      decoration: const InputDecoration(
                        labelText: 'Chave PIX (Opcional)',
                        hintText: 'CNPJ, CPF, Celular, E-mail ou Aleatória',
                        prefixIcon: Icon(Icons.key_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pixMerchantName,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Recebedor / Paróquia',
                        hintText: 'Ex: Paroquia Sao Jose (padrão: nome do evento)',
                        prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pixMerchantCity,
                      decoration: const InputDecoration(
                        labelText: 'Cidade do Recebedor',
                        hintText: 'Ex: Sao Paulo',
                        prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
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
