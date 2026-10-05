import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> seedEvent() async {
    final eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Evento',
            dateEpochMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    return eventId;
  }

  test('insert carimba rowVersion=1, updatedAtMs e updatedByDevice', () async {
    final eventId = await seedEvent();
    final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.rowVersion, 1);
    expect(ev.updatedAtMs, greaterThan(0));
    expect(ev.updatedByDevice, 'local');
    expect(ev.deletedAtMs, isNull);
  });

  test('update incrementa rowVersion via trigger', () async {
    final eventId = await seedEvent();
    await (db.update(db.events)..where((e) => e.id.equals(eventId))).write(
      const EventsCompanion(title: Value('Novo título')),
    );
    var ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.rowVersion, 2);

    await (db.update(db.events)..where((e) => e.id.equals(eventId))).write(
      const EventsCompanion(notes: Value('obs')),
    );
    ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.rowVersion, 3);
  });

  test('runWithSyncBypass preserva rowVersion/updatedAt vindos de fora',
      () async {
    final eventId = await seedEvent();
    await db.runWithSyncBypass(() async {
      await (db.update(db.events)..where((e) => e.id.equals(eventId))).write(
        const EventsCompanion(title: Value('Vindo do host')),
      );
    });
    final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    // Sem carimbo: a escrita remota não conta como alteração local.
    expect(ev.rowVersion, 1);
    expect(ev.title, 'Vindo do host');

    // Depois do bypass, os triggers voltam a funcionar.
    await (db.update(db.events)..where((e) => e.id.equals(eventId))).write(
      const EventsCompanion(title: Value('Local de novo')),
    );
    final ev2 = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev2.rowVersion, 2);
  });

  test('insert em modo bypass preserva valores remotos', () async {
    final eventId = db.generateUuid();
    await db.runWithSyncBypass(() async {
      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: eventId,
              title: 'Remoto',
              dateEpochMs: 1,
            ).copyWith(
              rowVersion: const Value(7),
              updatedAtMs: const Value(123456),
              updatedByDevice: const Value('celular-do-diogo'),
            ),
          );
    });
    final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.rowVersion, 7);
    expect(ev.updatedAtMs, 123456);
    expect(ev.updatedByDevice, 'celular-do-diogo');
  });

  test('openCashSession grava openedBy (não mais closedBy)', () async {
    final eventId = await seedEvent();
    final sessionId = await db.openCashSession(
      eventId: eventId,
      title: 'Sessão',
      openedBy: 'Maria',
    );
    final session = await (db.select(db.cashSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingle();
    expect(session.openedBy, 'Maria');
    expect(session.closedBy, isNull);
  });
}
