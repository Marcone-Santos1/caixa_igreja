// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, ChurchEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateEpochMsMeta = const VerificationMeta(
    'dateEpochMs',
  );
  @override
  late final GeneratedColumn<int> dateEpochMs = GeneratedColumn<int>(
    'date_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, notes, dateEpochMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChurchEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('date_epoch_ms')) {
      context.handle(
        _dateEpochMsMeta,
        dateEpochMs.isAcceptableOrUnknown(
          data['date_epoch_ms']!,
          _dateEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChurchEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChurchEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      dateEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_epoch_ms'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class ChurchEvent extends DataClass implements Insertable<ChurchEvent> {
  final int id;
  final String title;
  final String notes;
  final int dateEpochMs;
  const ChurchEvent({
    required this.id,
    required this.title,
    required this.notes,
    required this.dateEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    map['date_epoch_ms'] = Variable<int>(dateEpochMs);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      notes: Value(notes),
      dateEpochMs: Value(dateEpochMs),
    );
  }

  factory ChurchEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChurchEvent(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      dateEpochMs: serializer.fromJson<int>(json['dateEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'dateEpochMs': serializer.toJson<int>(dateEpochMs),
    };
  }

  ChurchEvent copyWith({
    int? id,
    String? title,
    String? notes,
    int? dateEpochMs,
  }) => ChurchEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    dateEpochMs: dateEpochMs ?? this.dateEpochMs,
  );
  ChurchEvent copyWithCompanion(EventsCompanion data) {
    return ChurchEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dateEpochMs: data.dateEpochMs.present
          ? data.dateEpochMs.value
          : this.dateEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChurchEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dateEpochMs: $dateEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, notes, dateEpochMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChurchEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dateEpochMs == this.dateEpochMs);
}

class EventsCompanion extends UpdateCompanion<ChurchEvent> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> notes;
  final Value<int> dateEpochMs;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dateEpochMs = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    required int dateEpochMs,
  }) : title = Value(title),
       dateEpochMs = Value(dateEpochMs);
  static Insertable<ChurchEvent> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? dateEpochMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dateEpochMs != null) 'date_epoch_ms': dateEpochMs,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? notes,
    Value<int>? dateEpochMs,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dateEpochMs: dateEpochMs ?? this.dateEpochMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dateEpochMs.present) {
      map['date_epoch_ms'] = Variable<int>(dateEpochMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dateEpochMs: $dateEpochMs')
          ..write(')'))
        .toString();
  }
}

class $EventDotDenominationsTable extends EventDotDenominations
    with TableInfo<$EventDotDenominationsTable, EventDotDenom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventDotDenominationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueCentsMeta = const VerificationMeta(
    'valueCents',
  );
  @override
  late final GeneratedColumn<int> valueCents = GeneratedColumn<int>(
    'value_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<int> stockQty = GeneratedColumn<int>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    label,
    valueCents,
    stockQty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_dot_denominations';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventDotDenom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value_cents')) {
      context.handle(
        _valueCentsMeta,
        valueCents.isAcceptableOrUnknown(data['value_cents']!, _valueCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_valueCentsMeta);
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventDotDenom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventDotDenom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      valueCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_cents'],
      )!,
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_qty'],
      )!,
    );
  }

  @override
  $EventDotDenominationsTable createAlias(String alias) {
    return $EventDotDenominationsTable(attachedDatabase, alias);
  }
}

class EventDotDenom extends DataClass implements Insertable<EventDotDenom> {
  final int id;
  final int eventId;
  final String label;
  final int valueCents;
  final int stockQty;
  const EventDotDenom({
    required this.id,
    required this.eventId,
    required this.label,
    required this.valueCents,
    required this.stockQty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['label'] = Variable<String>(label);
    map['value_cents'] = Variable<int>(valueCents);
    map['stock_qty'] = Variable<int>(stockQty);
    return map;
  }

  EventDotDenominationsCompanion toCompanion(bool nullToAbsent) {
    return EventDotDenominationsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      label: Value(label),
      valueCents: Value(valueCents),
      stockQty: Value(stockQty),
    );
  }

  factory EventDotDenom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventDotDenom(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      label: serializer.fromJson<String>(json['label']),
      valueCents: serializer.fromJson<int>(json['valueCents']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'label': serializer.toJson<String>(label),
      'valueCents': serializer.toJson<int>(valueCents),
      'stockQty': serializer.toJson<int>(stockQty),
    };
  }

  EventDotDenom copyWith({
    int? id,
    int? eventId,
    String? label,
    int? valueCents,
    int? stockQty,
  }) => EventDotDenom(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    label: label ?? this.label,
    valueCents: valueCents ?? this.valueCents,
    stockQty: stockQty ?? this.stockQty,
  );
  EventDotDenom copyWithCompanion(EventDotDenominationsCompanion data) {
    return EventDotDenom(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      label: data.label.present ? data.label.value : this.label,
      valueCents: data.valueCents.present
          ? data.valueCents.value
          : this.valueCents,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventDotDenom(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('label: $label, ')
          ..write('valueCents: $valueCents, ')
          ..write('stockQty: $stockQty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, label, valueCents, stockQty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventDotDenom &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.label == this.label &&
          other.valueCents == this.valueCents &&
          other.stockQty == this.stockQty);
}

class EventDotDenominationsCompanion extends UpdateCompanion<EventDotDenom> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<String> label;
  final Value<int> valueCents;
  final Value<int> stockQty;
  const EventDotDenominationsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.label = const Value.absent(),
    this.valueCents = const Value.absent(),
    this.stockQty = const Value.absent(),
  });
  EventDotDenominationsCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required String label,
    required int valueCents,
    this.stockQty = const Value.absent(),
  }) : eventId = Value(eventId),
       label = Value(label),
       valueCents = Value(valueCents);
  static Insertable<EventDotDenom> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<String>? label,
    Expression<int>? valueCents,
    Expression<int>? stockQty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (label != null) 'label': label,
      if (valueCents != null) 'value_cents': valueCents,
      if (stockQty != null) 'stock_qty': stockQty,
    });
  }

  EventDotDenominationsCompanion copyWith({
    Value<int>? id,
    Value<int>? eventId,
    Value<String>? label,
    Value<int>? valueCents,
    Value<int>? stockQty,
  }) {
    return EventDotDenominationsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      label: label ?? this.label,
      valueCents: valueCents ?? this.valueCents,
      stockQty: stockQty ?? this.stockQty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (valueCents.present) {
      map['value_cents'] = Variable<int>(valueCents.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<int>(stockQty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventDotDenominationsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('label: $label, ')
          ..write('valueCents: $valueCents, ')
          ..write('stockQty: $stockQty')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ChurchProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceCentsMeta = const VerificationMeta(
    'priceCents',
  );
  @override
  late final GeneratedColumn<int> priceCents = GeneratedColumn<int>(
    'price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackStockMeta = const VerificationMeta(
    'trackStock',
  );
  @override
  late final GeneratedColumn<bool> trackStock = GeneratedColumn<bool>(
    'track_stock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_stock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<int> stockQty = GeneratedColumn<int>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    name,
    description,
    priceCents,
    trackStock,
    stockQty,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChurchProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price_cents')) {
      context.handle(
        _priceCentsMeta,
        priceCents.isAcceptableOrUnknown(data['price_cents']!, _priceCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_priceCentsMeta);
    }
    if (data.containsKey('track_stock')) {
      context.handle(
        _trackStockMeta,
        trackStock.isAcceptableOrUnknown(data['track_stock']!, _trackStockMeta),
      );
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChurchProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChurchProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      priceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_cents'],
      )!,
      trackStock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_stock'],
      )!,
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_qty'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ChurchProduct extends DataClass implements Insertable<ChurchProduct> {
  final int id;
  final int eventId;
  final String name;
  final String description;
  final int priceCents;
  final bool trackStock;
  final int stockQty;
  final bool active;
  const ChurchProduct({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.trackStock,
    required this.stockQty,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['price_cents'] = Variable<int>(priceCents);
    map['track_stock'] = Variable<bool>(trackStock);
    map['stock_qty'] = Variable<int>(stockQty);
    map['active'] = Variable<bool>(active);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      name: Value(name),
      description: Value(description),
      priceCents: Value(priceCents),
      trackStock: Value(trackStock),
      stockQty: Value(stockQty),
      active: Value(active),
    );
  }

  factory ChurchProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChurchProduct(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      trackStock: serializer.fromJson<bool>(json['trackStock']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'priceCents': serializer.toJson<int>(priceCents),
      'trackStock': serializer.toJson<bool>(trackStock),
      'stockQty': serializer.toJson<int>(stockQty),
      'active': serializer.toJson<bool>(active),
    };
  }

  ChurchProduct copyWith({
    int? id,
    int? eventId,
    String? name,
    String? description,
    int? priceCents,
    bool? trackStock,
    int? stockQty,
    bool? active,
  }) => ChurchProduct(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    name: name ?? this.name,
    description: description ?? this.description,
    priceCents: priceCents ?? this.priceCents,
    trackStock: trackStock ?? this.trackStock,
    stockQty: stockQty ?? this.stockQty,
    active: active ?? this.active,
  );
  ChurchProduct copyWithCompanion(ProductsCompanion data) {
    return ChurchProduct(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      priceCents: data.priceCents.present
          ? data.priceCents.value
          : this.priceCents,
      trackStock: data.trackStock.present
          ? data.trackStock.value
          : this.trackStock,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChurchProduct(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('priceCents: $priceCents, ')
          ..write('trackStock: $trackStock, ')
          ..write('stockQty: $stockQty, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    name,
    description,
    priceCents,
    trackStock,
    stockQty,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChurchProduct &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.name == this.name &&
          other.description == this.description &&
          other.priceCents == this.priceCents &&
          other.trackStock == this.trackStock &&
          other.stockQty == this.stockQty &&
          other.active == this.active);
}

class ProductsCompanion extends UpdateCompanion<ChurchProduct> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<String> name;
  final Value<String> description;
  final Value<int> priceCents;
  final Value<bool> trackStock;
  final Value<int> stockQty;
  final Value<bool> active;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.active = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required String name,
    this.description = const Value.absent(),
    required int priceCents,
    this.trackStock = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.active = const Value.absent(),
  }) : eventId = Value(eventId),
       name = Value(name),
       priceCents = Value(priceCents);
  static Insertable<ChurchProduct> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? priceCents,
    Expression<bool>? trackStock,
    Expression<int>? stockQty,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (priceCents != null) 'price_cents': priceCents,
      if (trackStock != null) 'track_stock': trackStock,
      if (stockQty != null) 'stock_qty': stockQty,
      if (active != null) 'active': active,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<int>? eventId,
    Value<String>? name,
    Value<String>? description,
    Value<int>? priceCents,
    Value<bool>? trackStock,
    Value<int>? stockQty,
    Value<bool>? active,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      trackStock: trackStock ?? this.trackStock,
      stockQty: stockQty ?? this.stockQty,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priceCents.present) {
      map['price_cents'] = Variable<int>(priceCents.value);
    }
    if (trackStock.present) {
      map['track_stock'] = Variable<bool>(trackStock.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<int>(stockQty.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('priceCents: $priceCents, ')
          ..write('trackStock: $trackStock, ')
          ..write('stockQty: $stockQty, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, PosSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
    ),
  );
  static const VerificationMeta _soldAtMsMeta = const VerificationMeta(
    'soldAtMs',
  );
  @override
  late final GeneratedColumn<int> soldAtMs = GeneratedColumn<int>(
    'sold_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountReceivedCentsMeta =
      const VerificationMeta('amountReceivedCents');
  @override
  late final GeneratedColumn<int> amountReceivedCents = GeneratedColumn<int>(
    'amount_received_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(PaymentMethod.dinheiro),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    soldAtMs,
    totalCents,
    amountReceivedCents,
    paymentMethod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<PosSale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('sold_at_ms')) {
      context.handle(
        _soldAtMsMeta,
        soldAtMs.isAcceptableOrUnknown(data['sold_at_ms']!, _soldAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_soldAtMsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('amount_received_cents')) {
      context.handle(
        _amountReceivedCentsMeta,
        amountReceivedCents.isAcceptableOrUnknown(
          data['amount_received_cents']!,
          _amountReceivedCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountReceivedCentsMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PosSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PosSale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_id'],
      )!,
      soldAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sold_at_ms'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      amountReceivedCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_received_cents'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class PosSale extends DataClass implements Insertable<PosSale> {
  final int id;
  final int eventId;
  final int soldAtMs;
  final int totalCents;
  final int amountReceivedCents;
  final String paymentMethod;
  const PosSale({
    required this.id,
    required this.eventId,
    required this.soldAtMs,
    required this.totalCents,
    required this.amountReceivedCents,
    required this.paymentMethod,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['sold_at_ms'] = Variable<int>(soldAtMs);
    map['total_cents'] = Variable<int>(totalCents);
    map['amount_received_cents'] = Variable<int>(amountReceivedCents);
    map['payment_method'] = Variable<String>(paymentMethod);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      eventId: Value(eventId),
      soldAtMs: Value(soldAtMs),
      totalCents: Value(totalCents),
      amountReceivedCents: Value(amountReceivedCents),
      paymentMethod: Value(paymentMethod),
    );
  }

  factory PosSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PosSale(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      soldAtMs: serializer.fromJson<int>(json['soldAtMs']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      amountReceivedCents: serializer.fromJson<int>(
        json['amountReceivedCents'],
      ),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'soldAtMs': serializer.toJson<int>(soldAtMs),
      'totalCents': serializer.toJson<int>(totalCents),
      'amountReceivedCents': serializer.toJson<int>(amountReceivedCents),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
    };
  }

  PosSale copyWith({
    int? id,
    int? eventId,
    int? soldAtMs,
    int? totalCents,
    int? amountReceivedCents,
    String? paymentMethod,
  }) => PosSale(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    soldAtMs: soldAtMs ?? this.soldAtMs,
    totalCents: totalCents ?? this.totalCents,
    amountReceivedCents: amountReceivedCents ?? this.amountReceivedCents,
    paymentMethod: paymentMethod ?? this.paymentMethod,
  );
  PosSale copyWithCompanion(SalesCompanion data) {
    return PosSale(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      soldAtMs: data.soldAtMs.present ? data.soldAtMs.value : this.soldAtMs,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      amountReceivedCents: data.amountReceivedCents.present
          ? data.amountReceivedCents.value
          : this.amountReceivedCents,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PosSale(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('soldAtMs: $soldAtMs, ')
          ..write('totalCents: $totalCents, ')
          ..write('amountReceivedCents: $amountReceivedCents, ')
          ..write('paymentMethod: $paymentMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    soldAtMs,
    totalCents,
    amountReceivedCents,
    paymentMethod,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PosSale &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.soldAtMs == this.soldAtMs &&
          other.totalCents == this.totalCents &&
          other.amountReceivedCents == this.amountReceivedCents &&
          other.paymentMethod == this.paymentMethod);
}

class SalesCompanion extends UpdateCompanion<PosSale> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<int> soldAtMs;
  final Value<int> totalCents;
  final Value<int> amountReceivedCents;
  final Value<String> paymentMethod;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.soldAtMs = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.amountReceivedCents = const Value.absent(),
    this.paymentMethod = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required int soldAtMs,
    required int totalCents,
    required int amountReceivedCents,
    this.paymentMethod = const Value.absent(),
  }) : eventId = Value(eventId),
       soldAtMs = Value(soldAtMs),
       totalCents = Value(totalCents),
       amountReceivedCents = Value(amountReceivedCents);
  static Insertable<PosSale> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<int>? soldAtMs,
    Expression<int>? totalCents,
    Expression<int>? amountReceivedCents,
    Expression<String>? paymentMethod,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (soldAtMs != null) 'sold_at_ms': soldAtMs,
      if (totalCents != null) 'total_cents': totalCents,
      if (amountReceivedCents != null)
        'amount_received_cents': amountReceivedCents,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    });
  }

  SalesCompanion copyWith({
    Value<int>? id,
    Value<int>? eventId,
    Value<int>? soldAtMs,
    Value<int>? totalCents,
    Value<int>? amountReceivedCents,
    Value<String>? paymentMethod,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      soldAtMs: soldAtMs ?? this.soldAtMs,
      totalCents: totalCents ?? this.totalCents,
      amountReceivedCents: amountReceivedCents ?? this.amountReceivedCents,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (soldAtMs.present) {
      map['sold_at_ms'] = Variable<int>(soldAtMs.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (amountReceivedCents.present) {
      map['amount_received_cents'] = Variable<int>(amountReceivedCents.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('soldAtMs: $soldAtMs, ')
          ..write('totalCents: $totalCents, ')
          ..write('amountReceivedCents: $amountReceivedCents, ')
          ..write('paymentMethod: $paymentMethod')
          ..write(')'))
        .toString();
  }
}

class $SaleLinesTable extends SaleLines
    with TableInfo<$SaleLinesTable, PosSaleLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _lineKindMeta = const VerificationMeta(
    'lineKind',
  );
  @override
  late final GeneratedColumn<int> lineKind = GeneratedColumn<int>(
    'line_kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _dotDenominationIdMeta = const VerificationMeta(
    'dotDenominationId',
  );
  @override
  late final GeneratedColumn<int> dotDenominationId = GeneratedColumn<int>(
    'dot_denomination_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES event_dot_denominations (id)',
    ),
  );
  static const VerificationMeta _freeLabelMeta = const VerificationMeta(
    'freeLabel',
  );
  @override
  late final GeneratedColumn<String> freeLabel = GeneratedColumn<String>(
    'free_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalCentsMeta = const VerificationMeta(
    'lineTotalCents',
  );
  @override
  late final GeneratedColumn<int> lineTotalCents = GeneratedColumn<int>(
    'line_total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    lineKind,
    productId,
    dotDenominationId,
    freeLabel,
    qty,
    unitPriceCents,
    lineTotalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PosSaleLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('line_kind')) {
      context.handle(
        _lineKindMeta,
        lineKind.isAcceptableOrUnknown(data['line_kind']!, _lineKindMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('dot_denomination_id')) {
      context.handle(
        _dotDenominationIdMeta,
        dotDenominationId.isAcceptableOrUnknown(
          data['dot_denomination_id']!,
          _dotDenominationIdMeta,
        ),
      );
    }
    if (data.containsKey('free_label')) {
      context.handle(
        _freeLabelMeta,
        freeLabel.isAcceptableOrUnknown(data['free_label']!, _freeLabelMeta),
      );
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('line_total_cents')) {
      context.handle(
        _lineTotalCentsMeta,
        lineTotalCents.isAcceptableOrUnknown(
          data['line_total_cents']!,
          _lineTotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PosSaleLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PosSaleLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      )!,
      lineKind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_kind'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      dotDenominationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dot_denomination_id'],
      ),
      freeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_label'],
      ),
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      lineTotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_cents'],
      )!,
    );
  }

  @override
  $SaleLinesTable createAlias(String alias) {
    return $SaleLinesTable(attachedDatabase, alias);
  }
}

class PosSaleLine extends DataClass implements Insertable<PosSaleLine> {
  final int id;
  final int saleId;
  final int lineKind;
  final int? productId;
  final int? dotDenominationId;
  final String? freeLabel;
  final int qty;
  final int unitPriceCents;
  final int lineTotalCents;
  const PosSaleLine({
    required this.id,
    required this.saleId,
    required this.lineKind,
    this.productId,
    this.dotDenominationId,
    this.freeLabel,
    required this.qty,
    required this.unitPriceCents,
    required this.lineTotalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['line_kind'] = Variable<int>(lineKind);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    if (!nullToAbsent || dotDenominationId != null) {
      map['dot_denomination_id'] = Variable<int>(dotDenominationId);
    }
    if (!nullToAbsent || freeLabel != null) {
      map['free_label'] = Variable<String>(freeLabel);
    }
    map['qty'] = Variable<int>(qty);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['line_total_cents'] = Variable<int>(lineTotalCents);
    return map;
  }

  SaleLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleLinesCompanion(
      id: Value(id),
      saleId: Value(saleId),
      lineKind: Value(lineKind),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      dotDenominationId: dotDenominationId == null && nullToAbsent
          ? const Value.absent()
          : Value(dotDenominationId),
      freeLabel: freeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(freeLabel),
      qty: Value(qty),
      unitPriceCents: Value(unitPriceCents),
      lineTotalCents: Value(lineTotalCents),
    );
  }

  factory PosSaleLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PosSaleLine(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      lineKind: serializer.fromJson<int>(json['lineKind']),
      productId: serializer.fromJson<int?>(json['productId']),
      dotDenominationId: serializer.fromJson<int?>(json['dotDenominationId']),
      freeLabel: serializer.fromJson<String?>(json['freeLabel']),
      qty: serializer.fromJson<int>(json['qty']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      lineTotalCents: serializer.fromJson<int>(json['lineTotalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'lineKind': serializer.toJson<int>(lineKind),
      'productId': serializer.toJson<int?>(productId),
      'dotDenominationId': serializer.toJson<int?>(dotDenominationId),
      'freeLabel': serializer.toJson<String?>(freeLabel),
      'qty': serializer.toJson<int>(qty),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'lineTotalCents': serializer.toJson<int>(lineTotalCents),
    };
  }

  PosSaleLine copyWith({
    int? id,
    int? saleId,
    int? lineKind,
    Value<int?> productId = const Value.absent(),
    Value<int?> dotDenominationId = const Value.absent(),
    Value<String?> freeLabel = const Value.absent(),
    int? qty,
    int? unitPriceCents,
    int? lineTotalCents,
  }) => PosSaleLine(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    lineKind: lineKind ?? this.lineKind,
    productId: productId.present ? productId.value : this.productId,
    dotDenominationId: dotDenominationId.present
        ? dotDenominationId.value
        : this.dotDenominationId,
    freeLabel: freeLabel.present ? freeLabel.value : this.freeLabel,
    qty: qty ?? this.qty,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    lineTotalCents: lineTotalCents ?? this.lineTotalCents,
  );
  PosSaleLine copyWithCompanion(SaleLinesCompanion data) {
    return PosSaleLine(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      lineKind: data.lineKind.present ? data.lineKind.value : this.lineKind,
      productId: data.productId.present ? data.productId.value : this.productId,
      dotDenominationId: data.dotDenominationId.present
          ? data.dotDenominationId.value
          : this.dotDenominationId,
      freeLabel: data.freeLabel.present ? data.freeLabel.value : this.freeLabel,
      qty: data.qty.present ? data.qty.value : this.qty,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      lineTotalCents: data.lineTotalCents.present
          ? data.lineTotalCents.value
          : this.lineTotalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PosSaleLine(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('lineKind: $lineKind, ')
          ..write('productId: $productId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('freeLabel: $freeLabel, ')
          ..write('qty: $qty, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('lineTotalCents: $lineTotalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    lineKind,
    productId,
    dotDenominationId,
    freeLabel,
    qty,
    unitPriceCents,
    lineTotalCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PosSaleLine &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.lineKind == this.lineKind &&
          other.productId == this.productId &&
          other.dotDenominationId == this.dotDenominationId &&
          other.freeLabel == this.freeLabel &&
          other.qty == this.qty &&
          other.unitPriceCents == this.unitPriceCents &&
          other.lineTotalCents == this.lineTotalCents);
}

class SaleLinesCompanion extends UpdateCompanion<PosSaleLine> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> lineKind;
  final Value<int?> productId;
  final Value<int?> dotDenominationId;
  final Value<String?> freeLabel;
  final Value<int> qty;
  final Value<int> unitPriceCents;
  final Value<int> lineTotalCents;
  const SaleLinesCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.lineKind = const Value.absent(),
    this.productId = const Value.absent(),
    this.dotDenominationId = const Value.absent(),
    this.freeLabel = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.lineTotalCents = const Value.absent(),
  });
  SaleLinesCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    this.lineKind = const Value.absent(),
    this.productId = const Value.absent(),
    this.dotDenominationId = const Value.absent(),
    this.freeLabel = const Value.absent(),
    required int qty,
    required int unitPriceCents,
    required int lineTotalCents,
  }) : saleId = Value(saleId),
       qty = Value(qty),
       unitPriceCents = Value(unitPriceCents),
       lineTotalCents = Value(lineTotalCents);
  static Insertable<PosSaleLine> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? lineKind,
    Expression<int>? productId,
    Expression<int>? dotDenominationId,
    Expression<String>? freeLabel,
    Expression<int>? qty,
    Expression<int>? unitPriceCents,
    Expression<int>? lineTotalCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (lineKind != null) 'line_kind': lineKind,
      if (productId != null) 'product_id': productId,
      if (dotDenominationId != null) 'dot_denomination_id': dotDenominationId,
      if (freeLabel != null) 'free_label': freeLabel,
      if (qty != null) 'qty': qty,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (lineTotalCents != null) 'line_total_cents': lineTotalCents,
    });
  }

  SaleLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? saleId,
    Value<int>? lineKind,
    Value<int?>? productId,
    Value<int?>? dotDenominationId,
    Value<String?>? freeLabel,
    Value<int>? qty,
    Value<int>? unitPriceCents,
    Value<int>? lineTotalCents,
  }) {
    return SaleLinesCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      lineKind: lineKind ?? this.lineKind,
      productId: productId ?? this.productId,
      dotDenominationId: dotDenominationId ?? this.dotDenominationId,
      freeLabel: freeLabel ?? this.freeLabel,
      qty: qty ?? this.qty,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      lineTotalCents: lineTotalCents ?? this.lineTotalCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (lineKind.present) {
      map['line_kind'] = Variable<int>(lineKind.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (dotDenominationId.present) {
      map['dot_denomination_id'] = Variable<int>(dotDenominationId.value);
    }
    if (freeLabel.present) {
      map['free_label'] = Variable<String>(freeLabel.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (lineTotalCents.present) {
      map['line_total_cents'] = Variable<int>(lineTotalCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('lineKind: $lineKind, ')
          ..write('productId: $productId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('freeLabel: $freeLabel, ')
          ..write('qty: $qty, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('lineTotalCents: $lineTotalCents')
          ..write(')'))
        .toString();
  }
}

class $SaleChangeDotAllocationsTable extends SaleChangeDotAllocations
    with TableInfo<$SaleChangeDotAllocationsTable, ChangeDotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleChangeDotAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _dotDenominationIdMeta = const VerificationMeta(
    'dotDenominationId',
  );
  @override
  late final GeneratedColumn<int> dotDenominationId = GeneratedColumn<int>(
    'dot_denomination_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES event_dot_denominations (id)',
    ),
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, saleId, dotDenominationId, qty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_change_dot_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeDotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('dot_denomination_id')) {
      context.handle(
        _dotDenominationIdMeta,
        dotDenominationId.isAcceptableOrUnknown(
          data['dot_denomination_id']!,
          _dotDenominationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dotDenominationIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeDotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeDotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      )!,
      dotDenominationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dot_denomination_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
    );
  }

  @override
  $SaleChangeDotAllocationsTable createAlias(String alias) {
    return $SaleChangeDotAllocationsTable(attachedDatabase, alias);
  }
}

class ChangeDotRow extends DataClass implements Insertable<ChangeDotRow> {
  final int id;
  final int saleId;
  final int dotDenominationId;
  final int qty;
  const ChangeDotRow({
    required this.id,
    required this.saleId,
    required this.dotDenominationId,
    required this.qty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['dot_denomination_id'] = Variable<int>(dotDenominationId);
    map['qty'] = Variable<int>(qty);
    return map;
  }

  SaleChangeDotAllocationsCompanion toCompanion(bool nullToAbsent) {
    return SaleChangeDotAllocationsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      dotDenominationId: Value(dotDenominationId),
      qty: Value(qty),
    );
  }

  factory ChangeDotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeDotRow(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      dotDenominationId: serializer.fromJson<int>(json['dotDenominationId']),
      qty: serializer.fromJson<int>(json['qty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'dotDenominationId': serializer.toJson<int>(dotDenominationId),
      'qty': serializer.toJson<int>(qty),
    };
  }

  ChangeDotRow copyWith({
    int? id,
    int? saleId,
    int? dotDenominationId,
    int? qty,
  }) => ChangeDotRow(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    dotDenominationId: dotDenominationId ?? this.dotDenominationId,
    qty: qty ?? this.qty,
  );
  ChangeDotRow copyWithCompanion(SaleChangeDotAllocationsCompanion data) {
    return ChangeDotRow(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      dotDenominationId: data.dotDenominationId.present
          ? data.dotDenominationId.value
          : this.dotDenominationId,
      qty: data.qty.present ? data.qty.value : this.qty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeDotRow(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, saleId, dotDenominationId, qty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeDotRow &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.dotDenominationId == this.dotDenominationId &&
          other.qty == this.qty);
}

class SaleChangeDotAllocationsCompanion extends UpdateCompanion<ChangeDotRow> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> dotDenominationId;
  final Value<int> qty;
  const SaleChangeDotAllocationsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.dotDenominationId = const Value.absent(),
    this.qty = const Value.absent(),
  });
  SaleChangeDotAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    required int dotDenominationId,
    required int qty,
  }) : saleId = Value(saleId),
       dotDenominationId = Value(dotDenominationId),
       qty = Value(qty);
  static Insertable<ChangeDotRow> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? dotDenominationId,
    Expression<int>? qty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (dotDenominationId != null) 'dot_denomination_id': dotDenominationId,
      if (qty != null) 'qty': qty,
    });
  }

  SaleChangeDotAllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? saleId,
    Value<int>? dotDenominationId,
    Value<int>? qty,
  }) {
    return SaleChangeDotAllocationsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      dotDenominationId: dotDenominationId ?? this.dotDenominationId,
      qty: qty ?? this.qty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (dotDenominationId.present) {
      map['dot_denomination_id'] = Variable<int>(dotDenominationId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleChangeDotAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $EventDotDenominationsTable eventDotDenominations =
      $EventDotDenominationsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleLinesTable saleLines = $SaleLinesTable(this);
  late final $SaleChangeDotAllocationsTable saleChangeDotAllocations =
      $SaleChangeDotAllocationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    events,
    eventDotDenominations,
    products,
    sales,
    saleLines,
    saleChangeDotAllocations,
  ];
}

typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> notes,
      required int dateEpochMs,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> notes,
      Value<int> dateEpochMs,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, ChurchEvent> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EventDotDenominationsTable, List<EventDotDenom>>
  _eventDotDenominationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.eventDotDenominations,
        aliasName: $_aliasNameGenerator(
          db.events.id,
          db.eventDotDenominations.eventId,
        ),
      );

  $$EventDotDenominationsTableProcessedTableManager
  get eventDotDenominationsRefs {
    final manager = $$EventDotDenominationsTableTableManager(
      $_db,
      $_db.eventDotDenominations,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _eventDotDenominationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductsTable, List<ChurchProduct>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: $_aliasNameGenerator(db.events.id, db.products.eventId),
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesTable, List<PosSale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: $_aliasNameGenerator(db.events.id, db.sales.eventId),
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateEpochMs => $composableBuilder(
    column: $table.dateEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eventDotDenominationsRefs(
    Expression<bool> Function($$EventDotDenominationsTableFilterComposer f) f,
  ) {
    final $$EventDotDenominationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableFilterComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateEpochMs => $composableBuilder(
    column: $table.dateEpochMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get dateEpochMs => $composableBuilder(
    column: $table.dateEpochMs,
    builder: (column) => column,
  );

  Expression<T> eventDotDenominationsRefs<T extends Object>(
    Expression<T> Function($$EventDotDenominationsTableAnnotationComposer a) f,
  ) {
    final $$EventDotDenominationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableAnnotationComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          ChurchEvent,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (ChurchEvent, $$EventsTableReferences),
          ChurchEvent,
          PrefetchHooks Function({
            bool eventDotDenominationsRefs,
            bool productsRefs,
            bool salesRefs,
          })
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> dateEpochMs = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                title: title,
                notes: notes,
                dateEpochMs: dateEpochMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> notes = const Value.absent(),
                required int dateEpochMs,
              }) => EventsCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                dateEpochMs: dateEpochMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventDotDenominationsRefs = false,
                productsRefs = false,
                salesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (eventDotDenominationsRefs) db.eventDotDenominations,
                    if (productsRefs) db.products,
                    if (salesRefs) db.sales,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (eventDotDenominationsRefs)
                        await $_getPrefetchedData<
                          ChurchEvent,
                          $EventsTable,
                          EventDotDenom
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._eventDotDenominationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).eventDotDenominationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productsRefs)
                        await $_getPrefetchedData<
                          ChurchEvent,
                          $EventsTable,
                          ChurchProduct
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._productsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(
                                db,
                                table,
                                p0,
                              ).productsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (salesRefs)
                        await $_getPrefetchedData<
                          ChurchEvent,
                          $EventsTable,
                          PosSale
                        >(
                          currentTable: table,
                          referencedTable: $$EventsTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventsTableReferences(db, table, p0).salesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      ChurchEvent,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (ChurchEvent, $$EventsTableReferences),
      ChurchEvent,
      PrefetchHooks Function({
        bool eventDotDenominationsRefs,
        bool productsRefs,
        bool salesRefs,
      })
    >;
typedef $$EventDotDenominationsTableCreateCompanionBuilder =
    EventDotDenominationsCompanion Function({
      Value<int> id,
      required int eventId,
      required String label,
      required int valueCents,
      Value<int> stockQty,
    });
typedef $$EventDotDenominationsTableUpdateCompanionBuilder =
    EventDotDenominationsCompanion Function({
      Value<int> id,
      Value<int> eventId,
      Value<String> label,
      Value<int> valueCents,
      Value<int> stockQty,
    });

final class $$EventDotDenominationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EventDotDenominationsTable,
          EventDotDenom
        > {
  $$EventDotDenominationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.eventDotDenominations.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleLinesTable, List<PosSaleLine>>
  _saleLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleLines,
    aliasName: $_aliasNameGenerator(
      db.eventDotDenominations.id,
      db.saleLines.dotDenominationId,
    ),
  );

  $$SaleLinesTableProcessedTableManager get saleLinesRefs {
    final manager = $$SaleLinesTableTableManager(
      $_db,
      $_db.saleLines,
    ).filter((f) => f.dotDenominationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleChangeDotAllocationsTable, List<ChangeDotRow>>
  _saleChangeDotAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.saleChangeDotAllocations,
        aliasName: $_aliasNameGenerator(
          db.eventDotDenominations.id,
          db.saleChangeDotAllocations.dotDenominationId,
        ),
      );

  $$SaleChangeDotAllocationsTableProcessedTableManager
  get saleChangeDotAllocationsRefs {
    final manager = $$SaleChangeDotAllocationsTableTableManager(
      $_db,
      $_db.saleChangeDotAllocations,
    ).filter((f) => f.dotDenominationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleChangeDotAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventDotDenominationsTableFilterComposer
    extends Composer<_$AppDatabase, $EventDotDenominationsTable> {
  $$EventDotDenominationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleLinesRefs(
    Expression<bool> Function($$SaleLinesTableFilterComposer f) f,
  ) {
    final $$SaleLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.dotDenominationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableFilterComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleChangeDotAllocationsRefs(
    Expression<bool> Function($$SaleChangeDotAllocationsTableFilterComposer f)
    f,
  ) {
    final $$SaleChangeDotAllocationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.saleChangeDotAllocations,
          getReferencedColumn: (t) => t.dotDenominationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SaleChangeDotAllocationsTableFilterComposer(
                $db: $db,
                $table: $db.saleChangeDotAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EventDotDenominationsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventDotDenominationsTable> {
  $$EventDotDenominationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventDotDenominationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventDotDenominationsTable> {
  $$EventDotDenominationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleLinesRefs<T extends Object>(
    Expression<T> Function($$SaleLinesTableAnnotationComposer a) f,
  ) {
    final $$SaleLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.dotDenominationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleChangeDotAllocationsRefs<T extends Object>(
    Expression<T> Function($$SaleChangeDotAllocationsTableAnnotationComposer a)
    f,
  ) {
    final $$SaleChangeDotAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.saleChangeDotAllocations,
          getReferencedColumn: (t) => t.dotDenominationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SaleChangeDotAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.saleChangeDotAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EventDotDenominationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventDotDenominationsTable,
          EventDotDenom,
          $$EventDotDenominationsTableFilterComposer,
          $$EventDotDenominationsTableOrderingComposer,
          $$EventDotDenominationsTableAnnotationComposer,
          $$EventDotDenominationsTableCreateCompanionBuilder,
          $$EventDotDenominationsTableUpdateCompanionBuilder,
          (EventDotDenom, $$EventDotDenominationsTableReferences),
          EventDotDenom,
          PrefetchHooks Function({
            bool eventId,
            bool saleLinesRefs,
            bool saleChangeDotAllocationsRefs,
          })
        > {
  $$EventDotDenominationsTableTableManager(
    _$AppDatabase db,
    $EventDotDenominationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventDotDenominationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EventDotDenominationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EventDotDenominationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> valueCents = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
              }) => EventDotDenominationsCompanion(
                id: id,
                eventId: eventId,
                label: label,
                valueCents: valueCents,
                stockQty: stockQty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eventId,
                required String label,
                required int valueCents,
                Value<int> stockQty = const Value.absent(),
              }) => EventDotDenominationsCompanion.insert(
                id: id,
                eventId: eventId,
                label: label,
                valueCents: valueCents,
                stockQty: stockQty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventDotDenominationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventId = false,
                saleLinesRefs = false,
                saleChangeDotAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleLinesRefs) db.saleLines,
                    if (saleChangeDotAllocationsRefs)
                      db.saleChangeDotAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable:
                                        $$EventDotDenominationsTableReferences
                                            ._eventIdTable(db),
                                    referencedColumn:
                                        $$EventDotDenominationsTableReferences
                                            ._eventIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleLinesRefs)
                        await $_getPrefetchedData<
                          EventDotDenom,
                          $EventDotDenominationsTable,
                          PosSaleLine
                        >(
                          currentTable: table,
                          referencedTable:
                              $$EventDotDenominationsTableReferences
                                  ._saleLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventDotDenominationsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dotDenominationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleChangeDotAllocationsRefs)
                        await $_getPrefetchedData<
                          EventDotDenom,
                          $EventDotDenominationsTable,
                          ChangeDotRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$EventDotDenominationsTableReferences
                                  ._saleChangeDotAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EventDotDenominationsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleChangeDotAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.dotDenominationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EventDotDenominationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventDotDenominationsTable,
      EventDotDenom,
      $$EventDotDenominationsTableFilterComposer,
      $$EventDotDenominationsTableOrderingComposer,
      $$EventDotDenominationsTableAnnotationComposer,
      $$EventDotDenominationsTableCreateCompanionBuilder,
      $$EventDotDenominationsTableUpdateCompanionBuilder,
      (EventDotDenom, $$EventDotDenominationsTableReferences),
      EventDotDenom,
      PrefetchHooks Function({
        bool eventId,
        bool saleLinesRefs,
        bool saleChangeDotAllocationsRefs,
      })
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required int eventId,
      required String name,
      Value<String> description,
      required int priceCents,
      Value<bool> trackStock,
      Value<int> stockQty,
      Value<bool> active,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<int> eventId,
      Value<String> name,
      Value<String> description,
      Value<int> priceCents,
      Value<bool> trackStock,
      Value<int> stockQty,
      Value<bool> active,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ChurchProduct> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.products.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleLinesTable, List<PosSaleLine>>
  _saleLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleLines,
    aliasName: $_aliasNameGenerator(db.products.id, db.saleLines.productId),
  );

  $$SaleLinesTableProcessedTableManager get saleLinesRefs {
    final manager = $$SaleLinesTableTableManager(
      $_db,
      $_db.saleLines,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleLinesRefs(
    Expression<bool> Function($$SaleLinesTableFilterComposer f) f,
  ) {
    final $$SaleLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableFilterComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceCents => $composableBuilder(
    column: $table.priceCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trackStock => $composableBuilder(
    column: $table.trackStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleLinesRefs<T extends Object>(
    Expression<T> Function($$SaleLinesTableAnnotationComposer a) f,
  ) {
    final $$SaleLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ChurchProduct,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ChurchProduct, $$ProductsTableReferences),
          ChurchProduct,
          PrefetchHooks Function({bool eventId, bool saleLinesRefs})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> priceCents = const Value.absent(),
                Value<bool> trackStock = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                eventId: eventId,
                name: name,
                description: description,
                priceCents: priceCents,
                trackStock: trackStock,
                stockQty: stockQty,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eventId,
                required String name,
                Value<String> description = const Value.absent(),
                required int priceCents,
                Value<bool> trackStock = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                eventId: eventId,
                name: name,
                description: description,
                priceCents: priceCents,
                trackStock: trackStock,
                stockQty: stockQty,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, saleLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleLinesRefs) db.saleLines],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$ProductsTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$ProductsTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleLinesRefs)
                    await $_getPrefetchedData<
                      ChurchProduct,
                      $ProductsTable,
                      PosSaleLine
                    >(
                      currentTable: table,
                      referencedTable: $$ProductsTableReferences
                          ._saleLinesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProductsTableReferences(
                        db,
                        table,
                        p0,
                      ).saleLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.productId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ChurchProduct,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ChurchProduct, $$ProductsTableReferences),
      ChurchProduct,
      PrefetchHooks Function({bool eventId, bool saleLinesRefs})
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      Value<int> id,
      required int eventId,
      required int soldAtMs,
      required int totalCents,
      required int amountReceivedCents,
      Value<String> paymentMethod,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<int> id,
      Value<int> eventId,
      Value<int> soldAtMs,
      Value<int> totalCents,
      Value<int> amountReceivedCents,
      Value<String> paymentMethod,
    });

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, PosSale> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
    $_aliasNameGenerator(db.sales.eventId, db.events.id),
  );

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<int>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleLinesTable, List<PosSaleLine>>
  _saleLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleLines,
    aliasName: $_aliasNameGenerator(db.sales.id, db.saleLines.saleId),
  );

  $$SaleLinesTableProcessedTableManager get saleLinesRefs {
    final manager = $$SaleLinesTableTableManager(
      $_db,
      $_db.saleLines,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleChangeDotAllocationsTable, List<ChangeDotRow>>
  _saleChangeDotAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.saleChangeDotAllocations,
        aliasName: $_aliasNameGenerator(
          db.sales.id,
          db.saleChangeDotAllocations.saleId,
        ),
      );

  $$SaleChangeDotAllocationsTableProcessedTableManager
  get saleChangeDotAllocationsRefs {
    final manager = $$SaleChangeDotAllocationsTableTableManager(
      $_db,
      $_db.saleChangeDotAllocations,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleChangeDotAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soldAtMs => $composableBuilder(
    column: $table.soldAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountReceivedCents => $composableBuilder(
    column: $table.amountReceivedCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleLinesRefs(
    Expression<bool> Function($$SaleLinesTableFilterComposer f) f,
  ) {
    final $$SaleLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableFilterComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleChangeDotAllocationsRefs(
    Expression<bool> Function($$SaleChangeDotAllocationsTableFilterComposer f)
    f,
  ) {
    final $$SaleChangeDotAllocationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.saleChangeDotAllocations,
          getReferencedColumn: (t) => t.saleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SaleChangeDotAllocationsTableFilterComposer(
                $db: $db,
                $table: $db.saleChangeDotAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soldAtMs => $composableBuilder(
    column: $table.soldAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountReceivedCents => $composableBuilder(
    column: $table.amountReceivedCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get soldAtMs =>
      $composableBuilder(column: $table.soldAtMs, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountReceivedCents => $composableBuilder(
    column: $table.amountReceivedCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleLinesRefs<T extends Object>(
    Expression<T> Function($$SaleLinesTableAnnotationComposer a) f,
  ) {
    final $$SaleLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleLines,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.saleLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleChangeDotAllocationsRefs<T extends Object>(
    Expression<T> Function($$SaleChangeDotAllocationsTableAnnotationComposer a)
    f,
  ) {
    final $$SaleChangeDotAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.saleChangeDotAllocations,
          getReferencedColumn: (t) => t.saleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SaleChangeDotAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.saleChangeDotAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          PosSale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (PosSale, $$SalesTableReferences),
          PosSale,
          PrefetchHooks Function({
            bool eventId,
            bool saleLinesRefs,
            bool saleChangeDotAllocationsRefs,
          })
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> eventId = const Value.absent(),
                Value<int> soldAtMs = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> amountReceivedCents = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                eventId: eventId,
                soldAtMs: soldAtMs,
                totalCents: totalCents,
                amountReceivedCents: amountReceivedCents,
                paymentMethod: paymentMethod,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int eventId,
                required int soldAtMs,
                required int totalCents,
                required int amountReceivedCents,
                Value<String> paymentMethod = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                eventId: eventId,
                soldAtMs: soldAtMs,
                totalCents: totalCents,
                amountReceivedCents: amountReceivedCents,
                paymentMethod: paymentMethod,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SalesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                eventId = false,
                saleLinesRefs = false,
                saleChangeDotAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleLinesRefs) db.saleLines,
                    if (saleChangeDotAllocationsRefs)
                      db.saleChangeDotAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable: $$SalesTableReferences
                                        ._eventIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._eventIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleLinesRefs)
                        await $_getPrefetchedData<
                          PosSale,
                          $SalesTable,
                          PosSaleLine
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._saleLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleChangeDotAllocationsRefs)
                        await $_getPrefetchedData<
                          PosSale,
                          $SalesTable,
                          ChangeDotRow
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._saleChangeDotAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleChangeDotAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      PosSale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (PosSale, $$SalesTableReferences),
      PosSale,
      PrefetchHooks Function({
        bool eventId,
        bool saleLinesRefs,
        bool saleChangeDotAllocationsRefs,
      })
    >;
typedef $$SaleLinesTableCreateCompanionBuilder =
    SaleLinesCompanion Function({
      Value<int> id,
      required int saleId,
      Value<int> lineKind,
      Value<int?> productId,
      Value<int?> dotDenominationId,
      Value<String?> freeLabel,
      required int qty,
      required int unitPriceCents,
      required int lineTotalCents,
    });
typedef $$SaleLinesTableUpdateCompanionBuilder =
    SaleLinesCompanion Function({
      Value<int> id,
      Value<int> saleId,
      Value<int> lineKind,
      Value<int?> productId,
      Value<int?> dotDenominationId,
      Value<String?> freeLabel,
      Value<int> qty,
      Value<int> unitPriceCents,
      Value<int> lineTotalCents,
    });

final class $$SaleLinesTableReferences
    extends BaseReferences<_$AppDatabase, $SaleLinesTable, PosSaleLine> {
  $$SaleLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales.createAlias(
    $_aliasNameGenerator(db.saleLines.saleId, db.sales.id),
  );

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<int>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.saleLines.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager? get productId {
    final $_column = $_itemColumn<int>('product_id');
    if ($_column == null) return null;
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventDotDenominationsTable _dotDenominationIdTable(
    _$AppDatabase db,
  ) => db.eventDotDenominations.createAlias(
    $_aliasNameGenerator(
      db.saleLines.dotDenominationId,
      db.eventDotDenominations.id,
    ),
  );

  $$EventDotDenominationsTableProcessedTableManager? get dotDenominationId {
    final $_column = $_itemColumn<int>('dot_denomination_id');
    if ($_column == null) return null;
    final manager = $$EventDotDenominationsTableTableManager(
      $_db,
      $_db.eventDotDenominations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dotDenominationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineKind => $composableBuilder(
    column: $table.lineKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeLabel => $composableBuilder(
    column: $table.freeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventDotDenominationsTableFilterComposer get dotDenominationId {
    final $$EventDotDenominationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dotDenominationId,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableFilterComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineKind => $composableBuilder(
    column: $table.lineKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeLabel => $composableBuilder(
    column: $table.freeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventDotDenominationsTableOrderingComposer get dotDenominationId {
    final $$EventDotDenominationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dotDenominationId,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableOrderingComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineKind =>
      $composableBuilder(column: $table.lineKind, builder: (column) => column);

  GeneratedColumn<String> get freeLabel =>
      $composableBuilder(column: $table.freeLabel, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalCents => $composableBuilder(
    column: $table.lineTotalCents,
    builder: (column) => column,
  );

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventDotDenominationsTableAnnotationComposer get dotDenominationId {
    final $$EventDotDenominationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dotDenominationId,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableAnnotationComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleLinesTable,
          PosSaleLine,
          $$SaleLinesTableFilterComposer,
          $$SaleLinesTableOrderingComposer,
          $$SaleLinesTableAnnotationComposer,
          $$SaleLinesTableCreateCompanionBuilder,
          $$SaleLinesTableUpdateCompanionBuilder,
          (PosSaleLine, $$SaleLinesTableReferences),
          PosSaleLine,
          PrefetchHooks Function({
            bool saleId,
            bool productId,
            bool dotDenominationId,
          })
        > {
  $$SaleLinesTableTableManager(_$AppDatabase db, $SaleLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<int> lineKind = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<int?> dotDenominationId = const Value.absent(),
                Value<String?> freeLabel = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> lineTotalCents = const Value.absent(),
              }) => SaleLinesCompanion(
                id: id,
                saleId: saleId,
                lineKind: lineKind,
                productId: productId,
                dotDenominationId: dotDenominationId,
                freeLabel: freeLabel,
                qty: qty,
                unitPriceCents: unitPriceCents,
                lineTotalCents: lineTotalCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int saleId,
                Value<int> lineKind = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<int?> dotDenominationId = const Value.absent(),
                Value<String?> freeLabel = const Value.absent(),
                required int qty,
                required int unitPriceCents,
                required int lineTotalCents,
              }) => SaleLinesCompanion.insert(
                id: id,
                saleId: saleId,
                lineKind: lineKind,
                productId: productId,
                dotDenominationId: dotDenominationId,
                freeLabel: freeLabel,
                qty: qty,
                unitPriceCents: unitPriceCents,
                lineTotalCents: lineTotalCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SaleLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({saleId = false, productId = false, dotDenominationId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (saleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.saleId,
                                    referencedTable: $$SaleLinesTableReferences
                                        ._saleIdTable(db),
                                    referencedColumn: $$SaleLinesTableReferences
                                        ._saleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable: $$SaleLinesTableReferences
                                        ._productIdTable(db),
                                    referencedColumn: $$SaleLinesTableReferences
                                        ._productIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (dotDenominationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dotDenominationId,
                                    referencedTable: $$SaleLinesTableReferences
                                        ._dotDenominationIdTable(db),
                                    referencedColumn: $$SaleLinesTableReferences
                                        ._dotDenominationIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$SaleLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleLinesTable,
      PosSaleLine,
      $$SaleLinesTableFilterComposer,
      $$SaleLinesTableOrderingComposer,
      $$SaleLinesTableAnnotationComposer,
      $$SaleLinesTableCreateCompanionBuilder,
      $$SaleLinesTableUpdateCompanionBuilder,
      (PosSaleLine, $$SaleLinesTableReferences),
      PosSaleLine,
      PrefetchHooks Function({
        bool saleId,
        bool productId,
        bool dotDenominationId,
      })
    >;
typedef $$SaleChangeDotAllocationsTableCreateCompanionBuilder =
    SaleChangeDotAllocationsCompanion Function({
      Value<int> id,
      required int saleId,
      required int dotDenominationId,
      required int qty,
    });
typedef $$SaleChangeDotAllocationsTableUpdateCompanionBuilder =
    SaleChangeDotAllocationsCompanion Function({
      Value<int> id,
      Value<int> saleId,
      Value<int> dotDenominationId,
      Value<int> qty,
    });

final class $$SaleChangeDotAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SaleChangeDotAllocationsTable,
          ChangeDotRow
        > {
  $$SaleChangeDotAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales.createAlias(
    $_aliasNameGenerator(db.saleChangeDotAllocations.saleId, db.sales.id),
  );

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<int>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EventDotDenominationsTable _dotDenominationIdTable(
    _$AppDatabase db,
  ) => db.eventDotDenominations.createAlias(
    $_aliasNameGenerator(
      db.saleChangeDotAllocations.dotDenominationId,
      db.eventDotDenominations.id,
    ),
  );

  $$EventDotDenominationsTableProcessedTableManager get dotDenominationId {
    final $_column = $_itemColumn<int>('dot_denomination_id')!;

    final manager = $$EventDotDenominationsTableTableManager(
      $_db,
      $_db.eventDotDenominations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dotDenominationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleChangeDotAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleChangeDotAllocationsTable> {
  $$SaleChangeDotAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventDotDenominationsTableFilterComposer get dotDenominationId {
    final $$EventDotDenominationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dotDenominationId,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableFilterComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleChangeDotAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleChangeDotAllocationsTable> {
  $$SaleChangeDotAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventDotDenominationsTableOrderingComposer get dotDenominationId {
    final $$EventDotDenominationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dotDenominationId,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableOrderingComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleChangeDotAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleChangeDotAllocationsTable> {
  $$SaleChangeDotAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EventDotDenominationsTableAnnotationComposer get dotDenominationId {
    final $$EventDotDenominationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.dotDenominationId,
          referencedTable: $db.eventDotDenominations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EventDotDenominationsTableAnnotationComposer(
                $db: $db,
                $table: $db.eventDotDenominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SaleChangeDotAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleChangeDotAllocationsTable,
          ChangeDotRow,
          $$SaleChangeDotAllocationsTableFilterComposer,
          $$SaleChangeDotAllocationsTableOrderingComposer,
          $$SaleChangeDotAllocationsTableAnnotationComposer,
          $$SaleChangeDotAllocationsTableCreateCompanionBuilder,
          $$SaleChangeDotAllocationsTableUpdateCompanionBuilder,
          (ChangeDotRow, $$SaleChangeDotAllocationsTableReferences),
          ChangeDotRow,
          PrefetchHooks Function({bool saleId, bool dotDenominationId})
        > {
  $$SaleChangeDotAllocationsTableTableManager(
    _$AppDatabase db,
    $SaleChangeDotAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleChangeDotAllocationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SaleChangeDotAllocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SaleChangeDotAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<int> dotDenominationId = const Value.absent(),
                Value<int> qty = const Value.absent(),
              }) => SaleChangeDotAllocationsCompanion(
                id: id,
                saleId: saleId,
                dotDenominationId: dotDenominationId,
                qty: qty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int saleId,
                required int dotDenominationId,
                required int qty,
              }) => SaleChangeDotAllocationsCompanion.insert(
                id: id,
                saleId: saleId,
                dotDenominationId: dotDenominationId,
                qty: qty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SaleChangeDotAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, dotDenominationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable:
                                    $$SaleChangeDotAllocationsTableReferences
                                        ._saleIdTable(db),
                                referencedColumn:
                                    $$SaleChangeDotAllocationsTableReferences
                                        ._saleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (dotDenominationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dotDenominationId,
                                referencedTable:
                                    $$SaleChangeDotAllocationsTableReferences
                                        ._dotDenominationIdTable(db),
                                referencedColumn:
                                    $$SaleChangeDotAllocationsTableReferences
                                        ._dotDenominationIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaleChangeDotAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleChangeDotAllocationsTable,
      ChangeDotRow,
      $$SaleChangeDotAllocationsTableFilterComposer,
      $$SaleChangeDotAllocationsTableOrderingComposer,
      $$SaleChangeDotAllocationsTableAnnotationComposer,
      $$SaleChangeDotAllocationsTableCreateCompanionBuilder,
      $$SaleChangeDotAllocationsTableUpdateCompanionBuilder,
      (ChangeDotRow, $$SaleChangeDotAllocationsTableReferences),
      ChangeDotRow,
      PrefetchHooks Function({bool saleId, bool dotDenominationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$EventDotDenominationsTableTableManager get eventDotDenominations =>
      $$EventDotDenominationsTableTableManager(_db, _db.eventDotDenominations);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleLinesTableTableManager get saleLines =>
      $$SaleLinesTableTableManager(_db, _db.saleLines);
  $$SaleChangeDotAllocationsTableTableManager get saleChangeDotAllocations =>
      $$SaleChangeDotAllocationsTableTableManager(
        _db,
        _db.saleChangeDotAllocations,
      );
}
