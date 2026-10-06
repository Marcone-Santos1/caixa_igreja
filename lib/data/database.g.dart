// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, ChurchEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _pixKeyMeta = const VerificationMeta('pixKey');
  @override
  late final GeneratedColumn<String> pixKey = GeneratedColumn<String>(
    'pix_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pixMerchantNameMeta = const VerificationMeta(
    'pixMerchantName',
  );
  @override
  late final GeneratedColumn<String> pixMerchantName = GeneratedColumn<String>(
    'pix_merchant_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pixMerchantCityMeta = const VerificationMeta(
    'pixMerchantCity',
  );
  @override
  late final GeneratedColumn<String> pixMerchantCity = GeneratedColumn<String>(
    'pix_merchant_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    title,
    notes,
    dateEpochMs,
    pixKey,
    pixMerchantName,
    pixMerchantCity,
  ];
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('pix_key')) {
      context.handle(
        _pixKeyMeta,
        pixKey.isAcceptableOrUnknown(data['pix_key']!, _pixKeyMeta),
      );
    }
    if (data.containsKey('pix_merchant_name')) {
      context.handle(
        _pixMerchantNameMeta,
        pixMerchantName.isAcceptableOrUnknown(
          data['pix_merchant_name']!,
          _pixMerchantNameMeta,
        ),
      );
    }
    if (data.containsKey('pix_merchant_city')) {
      context.handle(
        _pixMerchantCityMeta,
        pixMerchantCity.isAcceptableOrUnknown(
          data['pix_merchant_city']!,
          _pixMerchantCityMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChurchEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChurchEvent(
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
      pixKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pix_key'],
      ),
      pixMerchantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pix_merchant_name'],
      ),
      pixMerchantCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pix_merchant_city'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class ChurchEvent extends DataClass implements Insertable<ChurchEvent> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String title;
  final String notes;
  final int dateEpochMs;
  final String? pixKey;
  final String? pixMerchantName;
  final String? pixMerchantCity;
  const ChurchEvent({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.title,
    required this.notes,
    required this.dateEpochMs,
    this.pixKey,
    this.pixMerchantName,
    this.pixMerchantCity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    map['date_epoch_ms'] = Variable<int>(dateEpochMs);
    if (!nullToAbsent || pixKey != null) {
      map['pix_key'] = Variable<String>(pixKey);
    }
    if (!nullToAbsent || pixMerchantName != null) {
      map['pix_merchant_name'] = Variable<String>(pixMerchantName);
    }
    if (!nullToAbsent || pixMerchantCity != null) {
      map['pix_merchant_city'] = Variable<String>(pixMerchantCity);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      title: Value(title),
      notes: Value(notes),
      dateEpochMs: Value(dateEpochMs),
      pixKey: pixKey == null && nullToAbsent
          ? const Value.absent()
          : Value(pixKey),
      pixMerchantName: pixMerchantName == null && nullToAbsent
          ? const Value.absent()
          : Value(pixMerchantName),
      pixMerchantCity: pixMerchantCity == null && nullToAbsent
          ? const Value.absent()
          : Value(pixMerchantCity),
    );
  }

  factory ChurchEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChurchEvent(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      dateEpochMs: serializer.fromJson<int>(json['dateEpochMs']),
      pixKey: serializer.fromJson<String?>(json['pixKey']),
      pixMerchantName: serializer.fromJson<String?>(json['pixMerchantName']),
      pixMerchantCity: serializer.fromJson<String?>(json['pixMerchantCity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'dateEpochMs': serializer.toJson<int>(dateEpochMs),
      'pixKey': serializer.toJson<String?>(pixKey),
      'pixMerchantName': serializer.toJson<String?>(pixMerchantName),
      'pixMerchantCity': serializer.toJson<String?>(pixMerchantCity),
    };
  }

  ChurchEvent copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? title,
    String? notes,
    int? dateEpochMs,
    Value<String?> pixKey = const Value.absent(),
    Value<String?> pixMerchantName = const Value.absent(),
    Value<String?> pixMerchantCity = const Value.absent(),
  }) => ChurchEvent(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    dateEpochMs: dateEpochMs ?? this.dateEpochMs,
    pixKey: pixKey.present ? pixKey.value : this.pixKey,
    pixMerchantName: pixMerchantName.present
        ? pixMerchantName.value
        : this.pixMerchantName,
    pixMerchantCity: pixMerchantCity.present
        ? pixMerchantCity.value
        : this.pixMerchantCity,
  );
  ChurchEvent copyWithCompanion(EventsCompanion data) {
    return ChurchEvent(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dateEpochMs: data.dateEpochMs.present
          ? data.dateEpochMs.value
          : this.dateEpochMs,
      pixKey: data.pixKey.present ? data.pixKey.value : this.pixKey,
      pixMerchantName: data.pixMerchantName.present
          ? data.pixMerchantName.value
          : this.pixMerchantName,
      pixMerchantCity: data.pixMerchantCity.present
          ? data.pixMerchantCity.value
          : this.pixMerchantCity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChurchEvent(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dateEpochMs: $dateEpochMs, ')
          ..write('pixKey: $pixKey, ')
          ..write('pixMerchantName: $pixMerchantName, ')
          ..write('pixMerchantCity: $pixMerchantCity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    title,
    notes,
    dateEpochMs,
    pixKey,
    pixMerchantName,
    pixMerchantCity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChurchEvent &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dateEpochMs == this.dateEpochMs &&
          other.pixKey == this.pixKey &&
          other.pixMerchantName == this.pixMerchantName &&
          other.pixMerchantCity == this.pixMerchantCity);
}

class EventsCompanion extends UpdateCompanion<ChurchEvent> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> title;
  final Value<String> notes;
  final Value<int> dateEpochMs;
  final Value<String?> pixKey;
  final Value<String?> pixMerchantName;
  final Value<String?> pixMerchantCity;
  final Value<int> rowid;
  const EventsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dateEpochMs = const Value.absent(),
    this.pixKey = const Value.absent(),
    this.pixMerchantName = const Value.absent(),
    this.pixMerchantCity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required int dateEpochMs,
    this.pixKey = const Value.absent(),
    this.pixMerchantName = const Value.absent(),
    this.pixMerchantCity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       dateEpochMs = Value(dateEpochMs);
  static Insertable<ChurchEvent> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? dateEpochMs,
    Expression<String>? pixKey,
    Expression<String>? pixMerchantName,
    Expression<String>? pixMerchantCity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dateEpochMs != null) 'date_epoch_ms': dateEpochMs,
      if (pixKey != null) 'pix_key': pixKey,
      if (pixMerchantName != null) 'pix_merchant_name': pixMerchantName,
      if (pixMerchantCity != null) 'pix_merchant_city': pixMerchantCity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? title,
    Value<String>? notes,
    Value<int>? dateEpochMs,
    Value<String?>? pixKey,
    Value<String?>? pixMerchantName,
    Value<String?>? pixMerchantCity,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dateEpochMs: dateEpochMs ?? this.dateEpochMs,
      pixKey: pixKey ?? this.pixKey,
      pixMerchantName: pixMerchantName ?? this.pixMerchantName,
      pixMerchantCity: pixMerchantCity ?? this.pixMerchantCity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
    if (pixKey.present) {
      map['pix_key'] = Variable<String>(pixKey.value);
    }
    if (pixMerchantName.present) {
      map['pix_merchant_name'] = Variable<String>(pixMerchantName.value);
    }
    if (pixMerchantCity.present) {
      map['pix_merchant_city'] = Variable<String>(pixMerchantCity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dateEpochMs: $dateEpochMs, ')
          ..write('pixKey: $pixKey, ')
          ..write('pixMerchantName: $pixMerchantName, ')
          ..write('pixMerchantCity: $pixMerchantCity, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String eventId;
  final String label;
  final int valueCents;
  final int stockQty;
  const EventDotDenom({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.eventId,
    required this.label,
    required this.valueCents,
    required this.stockQty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['label'] = Variable<String>(label);
    map['value_cents'] = Variable<int>(valueCents);
    map['stock_qty'] = Variable<int>(stockQty);
    return map;
  }

  EventDotDenominationsCompanion toCompanion(bool nullToAbsent) {
    return EventDotDenominationsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
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
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      label: serializer.fromJson<String>(json['label']),
      valueCents: serializer.fromJson<int>(json['valueCents']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'label': serializer.toJson<String>(label),
      'valueCents': serializer.toJson<int>(valueCents),
      'stockQty': serializer.toJson<int>(stockQty),
    };
  }

  EventDotDenom copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? eventId,
    String? label,
    int? valueCents,
    int? stockQty,
  }) => EventDotDenom(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    label: label ?? this.label,
    valueCents: valueCents ?? this.valueCents,
    stockQty: stockQty ?? this.stockQty,
  );
  EventDotDenom copyWithCompanion(EventDotDenominationsCompanion data) {
    return EventDotDenom(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
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
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('label: $label, ')
          ..write('valueCents: $valueCents, ')
          ..write('stockQty: $stockQty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    label,
    valueCents,
    stockQty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventDotDenom &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.label == this.label &&
          other.valueCents == this.valueCents &&
          other.stockQty == this.stockQty);
}

class EventDotDenominationsCompanion extends UpdateCompanion<EventDotDenom> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> label;
  final Value<int> valueCents;
  final Value<int> stockQty;
  final Value<int> rowid;
  const EventDotDenominationsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.label = const Value.absent(),
    this.valueCents = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventDotDenominationsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String eventId,
    required String label,
    required int valueCents,
    this.stockQty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       label = Value(label),
       valueCents = Value(valueCents);
  static Insertable<EventDotDenom> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? label,
    Expression<int>? valueCents,
    Expression<int>? stockQty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (label != null) 'label': label,
      if (valueCents != null) 'value_cents': valueCents,
      if (stockQty != null) 'stock_qty': stockQty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventDotDenominationsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? label,
    Value<int>? valueCents,
    Value<int>? stockQty,
    Value<int>? rowid,
  }) {
    return EventDotDenominationsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      label: label ?? this.label,
      valueCents: valueCents ?? this.valueCents,
      stockQty: stockQty ?? this.stockQty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventDotDenominationsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('label: $label, ')
          ..write('valueCents: $valueCents, ')
          ..write('stockQty: $stockQty, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isComboMeta = const VerificationMeta(
    'isCombo',
  );
  @override
  late final GeneratedColumn<bool> isCombo = GeneratedColumn<bool>(
    'is_combo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_combo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    name,
    description,
    priceCents,
    trackStock,
    stockQty,
    active,
    isCombo,
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('is_combo')) {
      context.handle(
        _isComboMeta,
        isCombo.isAcceptableOrUnknown(data['is_combo']!, _isComboMeta),
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
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
      isCombo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_combo'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ChurchProduct extends DataClass implements Insertable<ChurchProduct> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String eventId;
  final String name;
  final String description;
  final int priceCents;
  final bool trackStock;
  final int stockQty;
  final bool active;
  final bool isCombo;
  const ChurchProduct({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.trackStock,
    required this.stockQty,
    required this.active,
    required this.isCombo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['price_cents'] = Variable<int>(priceCents);
    map['track_stock'] = Variable<bool>(trackStock);
    map['stock_qty'] = Variable<int>(stockQty);
    map['active'] = Variable<bool>(active);
    map['is_combo'] = Variable<bool>(isCombo);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      eventId: Value(eventId),
      name: Value(name),
      description: Value(description),
      priceCents: Value(priceCents),
      trackStock: Value(trackStock),
      stockQty: Value(stockQty),
      active: Value(active),
      isCombo: Value(isCombo),
    );
  }

  factory ChurchProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChurchProduct(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      priceCents: serializer.fromJson<int>(json['priceCents']),
      trackStock: serializer.fromJson<bool>(json['trackStock']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
      active: serializer.fromJson<bool>(json['active']),
      isCombo: serializer.fromJson<bool>(json['isCombo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'priceCents': serializer.toJson<int>(priceCents),
      'trackStock': serializer.toJson<bool>(trackStock),
      'stockQty': serializer.toJson<int>(stockQty),
      'active': serializer.toJson<bool>(active),
      'isCombo': serializer.toJson<bool>(isCombo),
    };
  }

  ChurchProduct copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? eventId,
    String? name,
    String? description,
    int? priceCents,
    bool? trackStock,
    int? stockQty,
    bool? active,
    bool? isCombo,
  }) => ChurchProduct(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    name: name ?? this.name,
    description: description ?? this.description,
    priceCents: priceCents ?? this.priceCents,
    trackStock: trackStock ?? this.trackStock,
    stockQty: stockQty ?? this.stockQty,
    active: active ?? this.active,
    isCombo: isCombo ?? this.isCombo,
  );
  ChurchProduct copyWithCompanion(ProductsCompanion data) {
    return ChurchProduct(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
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
      isCombo: data.isCombo.present ? data.isCombo.value : this.isCombo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChurchProduct(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('priceCents: $priceCents, ')
          ..write('trackStock: $trackStock, ')
          ..write('stockQty: $stockQty, ')
          ..write('active: $active, ')
          ..write('isCombo: $isCombo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    name,
    description,
    priceCents,
    trackStock,
    stockQty,
    active,
    isCombo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChurchProduct &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.name == this.name &&
          other.description == this.description &&
          other.priceCents == this.priceCents &&
          other.trackStock == this.trackStock &&
          other.stockQty == this.stockQty &&
          other.active == this.active &&
          other.isCombo == this.isCombo);
}

class ProductsCompanion extends UpdateCompanion<ChurchProduct> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> name;
  final Value<String> description;
  final Value<int> priceCents;
  final Value<bool> trackStock;
  final Value<int> stockQty;
  final Value<bool> active;
  final Value<bool> isCombo;
  final Value<int> rowid;
  const ProductsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.priceCents = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.active = const Value.absent(),
    this.isCombo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String eventId,
    required String name,
    this.description = const Value.absent(),
    required int priceCents,
    this.trackStock = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.active = const Value.absent(),
    this.isCombo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       name = Value(name),
       priceCents = Value(priceCents);
  static Insertable<ChurchProduct> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? priceCents,
    Expression<bool>? trackStock,
    Expression<int>? stockQty,
    Expression<bool>? active,
    Expression<bool>? isCombo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (priceCents != null) 'price_cents': priceCents,
      if (trackStock != null) 'track_stock': trackStock,
      if (stockQty != null) 'stock_qty': stockQty,
      if (active != null) 'active': active,
      if (isCombo != null) 'is_combo': isCombo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? name,
    Value<String>? description,
    Value<int>? priceCents,
    Value<bool>? trackStock,
    Value<int>? stockQty,
    Value<bool>? active,
    Value<bool>? isCombo,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      trackStock: trackStock ?? this.trackStock,
      stockQty: stockQty ?? this.stockQty,
      active: active ?? this.active,
      isCombo: isCombo ?? this.isCombo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
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
    if (isCombo.present) {
      map['is_combo'] = Variable<bool>(isCombo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('priceCents: $priceCents, ')
          ..write('trackStock: $trackStock, ')
          ..write('stockQty: $stockQty, ')
          ..write('active: $active, ')
          ..write('isCombo: $isCombo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductComboItemsTable extends ProductComboItems
    with TableInfo<$ProductComboItemsTable, ProductComboItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductComboItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _comboProductIdMeta = const VerificationMeta(
    'comboProductId',
  );
  @override
  late final GeneratedColumn<String> comboProductId = GeneratedColumn<String>(
    'combo_product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childProductIdMeta = const VerificationMeta(
    'childProductId',
  );
  @override
  late final GeneratedColumn<String> childProductId = GeneratedColumn<String>(
    'child_product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    comboProductId,
    childProductId,
    qty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_combo_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductComboItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('combo_product_id')) {
      context.handle(
        _comboProductIdMeta,
        comboProductId.isAcceptableOrUnknown(
          data['combo_product_id']!,
          _comboProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_comboProductIdMeta);
    }
    if (data.containsKey('child_product_id')) {
      context.handle(
        _childProductIdMeta,
        childProductId.isAcceptableOrUnknown(
          data['child_product_id']!,
          _childProductIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_childProductIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {comboProductId, childProductId};
  @override
  ProductComboItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductComboItem(
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      comboProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}combo_product_id'],
      )!,
      childProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_product_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
    );
  }

  @override
  $ProductComboItemsTable createAlias(String alias) {
    return $ProductComboItemsTable(attachedDatabase, alias);
  }
}

class ProductComboItem extends DataClass
    implements Insertable<ProductComboItem> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String comboProductId;
  final String childProductId;
  final int qty;
  const ProductComboItem({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.comboProductId,
    required this.childProductId,
    required this.qty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['combo_product_id'] = Variable<String>(comboProductId);
    map['child_product_id'] = Variable<String>(childProductId);
    map['qty'] = Variable<int>(qty);
    return map;
  }

  ProductComboItemsCompanion toCompanion(bool nullToAbsent) {
    return ProductComboItemsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      comboProductId: Value(comboProductId),
      childProductId: Value(childProductId),
      qty: Value(qty),
    );
  }

  factory ProductComboItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductComboItem(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      comboProductId: serializer.fromJson<String>(json['comboProductId']),
      childProductId: serializer.fromJson<String>(json['childProductId']),
      qty: serializer.fromJson<int>(json['qty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'comboProductId': serializer.toJson<String>(comboProductId),
      'childProductId': serializer.toJson<String>(childProductId),
      'qty': serializer.toJson<int>(qty),
    };
  }

  ProductComboItem copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? comboProductId,
    String? childProductId,
    int? qty,
  }) => ProductComboItem(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    comboProductId: comboProductId ?? this.comboProductId,
    childProductId: childProductId ?? this.childProductId,
    qty: qty ?? this.qty,
  );
  ProductComboItem copyWithCompanion(ProductComboItemsCompanion data) {
    return ProductComboItem(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      comboProductId: data.comboProductId.present
          ? data.comboProductId.value
          : this.comboProductId,
      childProductId: data.childProductId.present
          ? data.childProductId.value
          : this.childProductId,
      qty: data.qty.present ? data.qty.value : this.qty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductComboItem(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('comboProductId: $comboProductId, ')
          ..write('childProductId: $childProductId, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    comboProductId,
    childProductId,
    qty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductComboItem &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.comboProductId == this.comboProductId &&
          other.childProductId == this.childProductId &&
          other.qty == this.qty);
}

class ProductComboItemsCompanion extends UpdateCompanion<ProductComboItem> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> comboProductId;
  final Value<String> childProductId;
  final Value<int> qty;
  final Value<int> rowid;
  const ProductComboItemsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.comboProductId = const Value.absent(),
    this.childProductId = const Value.absent(),
    this.qty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductComboItemsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String comboProductId,
    required String childProductId,
    required int qty,
    this.rowid = const Value.absent(),
  }) : comboProductId = Value(comboProductId),
       childProductId = Value(childProductId),
       qty = Value(qty);
  static Insertable<ProductComboItem> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? comboProductId,
    Expression<String>? childProductId,
    Expression<int>? qty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (comboProductId != null) 'combo_product_id': comboProductId,
      if (childProductId != null) 'child_product_id': childProductId,
      if (qty != null) 'qty': qty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductComboItemsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? comboProductId,
    Value<String>? childProductId,
    Value<int>? qty,
    Value<int>? rowid,
  }) {
    return ProductComboItemsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      comboProductId: comboProductId ?? this.comboProductId,
      childProductId: childProductId ?? this.childProductId,
      qty: qty ?? this.qty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (comboProductId.present) {
      map['combo_product_id'] = Variable<String>(comboProductId.value);
    }
    if (childProductId.present) {
      map['child_product_id'] = Variable<String>(childProductId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductComboItemsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('comboProductId: $comboProductId, ')
          ..write('childProductId: $childProductId, ')
          ..write('qty: $qty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashSessionsTable extends CashSessions
    with TableInfo<$CashSessionsTable, CashSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _openedAtMsMeta = const VerificationMeta(
    'openedAtMs',
  );
  @override
  late final GeneratedColumn<int> openedAtMs = GeneratedColumn<int>(
    'opened_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedByMeta = const VerificationMeta(
    'openedBy',
  );
  @override
  late final GeneratedColumn<String> openedBy = GeneratedColumn<String>(
    'opened_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMsMeta = const VerificationMeta(
    'closedAtMs',
  );
  @override
  late final GeneratedColumn<int> closedAtMs = GeneratedColumn<int>(
    'closed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialCashFloatCentsMeta =
      const VerificationMeta('initialCashFloatCents');
  @override
  late final GeneratedColumn<int> initialCashFloatCents = GeneratedColumn<int>(
    'initial_cash_float_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _closedCashDrawerCentsMeta =
      const VerificationMeta('closedCashDrawerCents');
  @override
  late final GeneratedColumn<int> closedCashDrawerCents = GeneratedColumn<int>(
    'closed_cash_drawer_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedNotesMeta = const VerificationMeta(
    'closedNotes',
  );
  @override
  late final GeneratedColumn<String> closedNotes = GeneratedColumn<String>(
    'closed_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByMeta = const VerificationMeta(
    'closedBy',
  );
  @override
  late final GeneratedColumn<String> closedBy = GeneratedColumn<String>(
    'closed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    title,
    openedAtMs,
    openedBy,
    closedAtMs,
    initialCashFloatCents,
    closedCashDrawerCents,
    closedNotes,
    closedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('opened_at_ms')) {
      context.handle(
        _openedAtMsMeta,
        openedAtMs.isAcceptableOrUnknown(
          data['opened_at_ms']!,
          _openedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openedAtMsMeta);
    }
    if (data.containsKey('opened_by')) {
      context.handle(
        _openedByMeta,
        openedBy.isAcceptableOrUnknown(data['opened_by']!, _openedByMeta),
      );
    }
    if (data.containsKey('closed_at_ms')) {
      context.handle(
        _closedAtMsMeta,
        closedAtMs.isAcceptableOrUnknown(
          data['closed_at_ms']!,
          _closedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('initial_cash_float_cents')) {
      context.handle(
        _initialCashFloatCentsMeta,
        initialCashFloatCents.isAcceptableOrUnknown(
          data['initial_cash_float_cents']!,
          _initialCashFloatCentsMeta,
        ),
      );
    }
    if (data.containsKey('closed_cash_drawer_cents')) {
      context.handle(
        _closedCashDrawerCentsMeta,
        closedCashDrawerCents.isAcceptableOrUnknown(
          data['closed_cash_drawer_cents']!,
          _closedCashDrawerCentsMeta,
        ),
      );
    }
    if (data.containsKey('closed_notes')) {
      context.handle(
        _closedNotesMeta,
        closedNotes.isAcceptableOrUnknown(
          data['closed_notes']!,
          _closedNotesMeta,
        ),
      );
    }
    if (data.containsKey('closed_by')) {
      context.handle(
        _closedByMeta,
        closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashSession(
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      openedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opened_at_ms'],
      )!,
      openedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opened_by'],
      ),
      closedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_at_ms'],
      ),
      initialCashFloatCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_cash_float_cents'],
      )!,
      closedCashDrawerCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_cash_drawer_cents'],
      ),
      closedNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_notes'],
      ),
      closedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by'],
      ),
    );
  }

  @override
  $CashSessionsTable createAlias(String alias) {
    return $CashSessionsTable(attachedDatabase, alias);
  }
}

class CashSession extends DataClass implements Insertable<CashSession> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String eventId;
  final String title;
  final int openedAtMs;
  final String? openedBy;
  final int? closedAtMs;
  final int initialCashFloatCents;
  final int? closedCashDrawerCents;
  final String? closedNotes;
  final String? closedBy;
  const CashSession({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.eventId,
    required this.title,
    required this.openedAtMs,
    this.openedBy,
    this.closedAtMs,
    required this.initialCashFloatCents,
    this.closedCashDrawerCents,
    this.closedNotes,
    this.closedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['title'] = Variable<String>(title);
    map['opened_at_ms'] = Variable<int>(openedAtMs);
    if (!nullToAbsent || openedBy != null) {
      map['opened_by'] = Variable<String>(openedBy);
    }
    if (!nullToAbsent || closedAtMs != null) {
      map['closed_at_ms'] = Variable<int>(closedAtMs);
    }
    map['initial_cash_float_cents'] = Variable<int>(initialCashFloatCents);
    if (!nullToAbsent || closedCashDrawerCents != null) {
      map['closed_cash_drawer_cents'] = Variable<int>(closedCashDrawerCents);
    }
    if (!nullToAbsent || closedNotes != null) {
      map['closed_notes'] = Variable<String>(closedNotes);
    }
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<String>(closedBy);
    }
    return map;
  }

  CashSessionsCompanion toCompanion(bool nullToAbsent) {
    return CashSessionsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      eventId: Value(eventId),
      title: Value(title),
      openedAtMs: Value(openedAtMs),
      openedBy: openedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(openedBy),
      closedAtMs: closedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAtMs),
      initialCashFloatCents: Value(initialCashFloatCents),
      closedCashDrawerCents: closedCashDrawerCents == null && nullToAbsent
          ? const Value.absent()
          : Value(closedCashDrawerCents),
      closedNotes: closedNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(closedNotes),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
    );
  }

  factory CashSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashSession(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      title: serializer.fromJson<String>(json['title']),
      openedAtMs: serializer.fromJson<int>(json['openedAtMs']),
      openedBy: serializer.fromJson<String?>(json['openedBy']),
      closedAtMs: serializer.fromJson<int?>(json['closedAtMs']),
      initialCashFloatCents: serializer.fromJson<int>(
        json['initialCashFloatCents'],
      ),
      closedCashDrawerCents: serializer.fromJson<int?>(
        json['closedCashDrawerCents'],
      ),
      closedNotes: serializer.fromJson<String?>(json['closedNotes']),
      closedBy: serializer.fromJson<String?>(json['closedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'title': serializer.toJson<String>(title),
      'openedAtMs': serializer.toJson<int>(openedAtMs),
      'openedBy': serializer.toJson<String?>(openedBy),
      'closedAtMs': serializer.toJson<int?>(closedAtMs),
      'initialCashFloatCents': serializer.toJson<int>(initialCashFloatCents),
      'closedCashDrawerCents': serializer.toJson<int?>(closedCashDrawerCents),
      'closedNotes': serializer.toJson<String?>(closedNotes),
      'closedBy': serializer.toJson<String?>(closedBy),
    };
  }

  CashSession copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? eventId,
    String? title,
    int? openedAtMs,
    Value<String?> openedBy = const Value.absent(),
    Value<int?> closedAtMs = const Value.absent(),
    int? initialCashFloatCents,
    Value<int?> closedCashDrawerCents = const Value.absent(),
    Value<String?> closedNotes = const Value.absent(),
    Value<String?> closedBy = const Value.absent(),
  }) => CashSession(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    title: title ?? this.title,
    openedAtMs: openedAtMs ?? this.openedAtMs,
    openedBy: openedBy.present ? openedBy.value : this.openedBy,
    closedAtMs: closedAtMs.present ? closedAtMs.value : this.closedAtMs,
    initialCashFloatCents: initialCashFloatCents ?? this.initialCashFloatCents,
    closedCashDrawerCents: closedCashDrawerCents.present
        ? closedCashDrawerCents.value
        : this.closedCashDrawerCents,
    closedNotes: closedNotes.present ? closedNotes.value : this.closedNotes,
    closedBy: closedBy.present ? closedBy.value : this.closedBy,
  );
  CashSession copyWithCompanion(CashSessionsCompanion data) {
    return CashSession(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      title: data.title.present ? data.title.value : this.title,
      openedAtMs: data.openedAtMs.present
          ? data.openedAtMs.value
          : this.openedAtMs,
      openedBy: data.openedBy.present ? data.openedBy.value : this.openedBy,
      closedAtMs: data.closedAtMs.present
          ? data.closedAtMs.value
          : this.closedAtMs,
      initialCashFloatCents: data.initialCashFloatCents.present
          ? data.initialCashFloatCents.value
          : this.initialCashFloatCents,
      closedCashDrawerCents: data.closedCashDrawerCents.present
          ? data.closedCashDrawerCents.value
          : this.closedCashDrawerCents,
      closedNotes: data.closedNotes.present
          ? data.closedNotes.value
          : this.closedNotes,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashSession(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('openedAtMs: $openedAtMs, ')
          ..write('openedBy: $openedBy, ')
          ..write('closedAtMs: $closedAtMs, ')
          ..write('initialCashFloatCents: $initialCashFloatCents, ')
          ..write('closedCashDrawerCents: $closedCashDrawerCents, ')
          ..write('closedNotes: $closedNotes, ')
          ..write('closedBy: $closedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    title,
    openedAtMs,
    openedBy,
    closedAtMs,
    initialCashFloatCents,
    closedCashDrawerCents,
    closedNotes,
    closedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashSession &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.title == this.title &&
          other.openedAtMs == this.openedAtMs &&
          other.openedBy == this.openedBy &&
          other.closedAtMs == this.closedAtMs &&
          other.initialCashFloatCents == this.initialCashFloatCents &&
          other.closedCashDrawerCents == this.closedCashDrawerCents &&
          other.closedNotes == this.closedNotes &&
          other.closedBy == this.closedBy);
}

class CashSessionsCompanion extends UpdateCompanion<CashSession> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> title;
  final Value<int> openedAtMs;
  final Value<String?> openedBy;
  final Value<int?> closedAtMs;
  final Value<int> initialCashFloatCents;
  final Value<int?> closedCashDrawerCents;
  final Value<String?> closedNotes;
  final Value<String?> closedBy;
  final Value<int> rowid;
  const CashSessionsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.title = const Value.absent(),
    this.openedAtMs = const Value.absent(),
    this.openedBy = const Value.absent(),
    this.closedAtMs = const Value.absent(),
    this.initialCashFloatCents = const Value.absent(),
    this.closedCashDrawerCents = const Value.absent(),
    this.closedNotes = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashSessionsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String eventId,
    required String title,
    required int openedAtMs,
    this.openedBy = const Value.absent(),
    this.closedAtMs = const Value.absent(),
    this.initialCashFloatCents = const Value.absent(),
    this.closedCashDrawerCents = const Value.absent(),
    this.closedNotes = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       title = Value(title),
       openedAtMs = Value(openedAtMs);
  static Insertable<CashSession> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? title,
    Expression<int>? openedAtMs,
    Expression<String>? openedBy,
    Expression<int>? closedAtMs,
    Expression<int>? initialCashFloatCents,
    Expression<int>? closedCashDrawerCents,
    Expression<String>? closedNotes,
    Expression<String>? closedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (title != null) 'title': title,
      if (openedAtMs != null) 'opened_at_ms': openedAtMs,
      if (openedBy != null) 'opened_by': openedBy,
      if (closedAtMs != null) 'closed_at_ms': closedAtMs,
      if (initialCashFloatCents != null)
        'initial_cash_float_cents': initialCashFloatCents,
      if (closedCashDrawerCents != null)
        'closed_cash_drawer_cents': closedCashDrawerCents,
      if (closedNotes != null) 'closed_notes': closedNotes,
      if (closedBy != null) 'closed_by': closedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashSessionsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? title,
    Value<int>? openedAtMs,
    Value<String?>? openedBy,
    Value<int?>? closedAtMs,
    Value<int>? initialCashFloatCents,
    Value<int?>? closedCashDrawerCents,
    Value<String?>? closedNotes,
    Value<String?>? closedBy,
    Value<int>? rowid,
  }) {
    return CashSessionsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      openedAtMs: openedAtMs ?? this.openedAtMs,
      openedBy: openedBy ?? this.openedBy,
      closedAtMs: closedAtMs ?? this.closedAtMs,
      initialCashFloatCents:
          initialCashFloatCents ?? this.initialCashFloatCents,
      closedCashDrawerCents:
          closedCashDrawerCents ?? this.closedCashDrawerCents,
      closedNotes: closedNotes ?? this.closedNotes,
      closedBy: closedBy ?? this.closedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (openedAtMs.present) {
      map['opened_at_ms'] = Variable<int>(openedAtMs.value);
    }
    if (openedBy.present) {
      map['opened_by'] = Variable<String>(openedBy.value);
    }
    if (closedAtMs.present) {
      map['closed_at_ms'] = Variable<int>(closedAtMs.value);
    }
    if (initialCashFloatCents.present) {
      map['initial_cash_float_cents'] = Variable<int>(
        initialCashFloatCents.value,
      );
    }
    if (closedCashDrawerCents.present) {
      map['closed_cash_drawer_cents'] = Variable<int>(
        closedCashDrawerCents.value,
      );
    }
    if (closedNotes.present) {
      map['closed_notes'] = Variable<String>(closedNotes.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<String>(closedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashSessionsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('openedAtMs: $openedAtMs, ')
          ..write('openedBy: $openedBy, ')
          ..write('closedAtMs: $closedAtMs, ')
          ..write('initialCashFloatCents: $initialCashFloatCents, ')
          ..write('closedCashDrawerCents: $closedCashDrawerCents, ')
          ..write('closedNotes: $closedNotes, ')
          ..write('closedBy: $closedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, PosSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changePendingMeta = const VerificationMeta(
    'changePending',
  );
  @override
  late final GeneratedColumn<bool> changePending = GeneratedColumn<bool>(
    'change_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("change_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountCentsMeta = const VerificationMeta(
    'discountCents',
  );
  @override
  late final GeneratedColumn<int> discountCents = GeneratedColumn<int>(
    'discount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountReasonMeta = const VerificationMeta(
    'discountReason',
  );
  @override
  late final GeneratedColumn<String> discountReason = GeneratedColumn<String>(
    'discount_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    sessionId,
    soldAtMs,
    totalCents,
    amountReceivedCents,
    paymentMethod,
    notes,
    changePending,
    customerName,
    discountCents,
    discountReason,
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('change_pending')) {
      context.handle(
        _changePendingMeta,
        changePending.isAcceptableOrUnknown(
          data['change_pending']!,
          _changePendingMeta,
        ),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('discount_cents')) {
      context.handle(
        _discountCentsMeta,
        discountCents.isAcceptableOrUnknown(
          data['discount_cents']!,
          _discountCentsMeta,
        ),
      );
    }
    if (data.containsKey('discount_reason')) {
      context.handle(
        _discountReasonMeta,
        discountReason.isAcceptableOrUnknown(
          data['discount_reason']!,
          _discountReasonMeta,
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
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
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
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      changePending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}change_pending'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      discountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_cents'],
      )!,
      discountReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_reason'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class PosSale extends DataClass implements Insertable<PosSale> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String eventId;
  final String? sessionId;
  final int soldAtMs;
  final int totalCents;
  final int amountReceivedCents;
  final String paymentMethod;
  final String? notes;
  final bool changePending;
  final String? customerName;

  /// Desconto aplicado no total (v11). `totalCents` já é o valor FINAL
  /// (soma das linhas − desconto); o desconto fica separado para auditoria
  /// e relatórios. Cortesia = desconto igual à soma das linhas (total 0).
  final int discountCents;
  final String? discountReason;
  const PosSale({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.eventId,
    this.sessionId,
    required this.soldAtMs,
    required this.totalCents,
    required this.amountReceivedCents,
    required this.paymentMethod,
    this.notes,
    required this.changePending,
    this.customerName,
    required this.discountCents,
    this.discountReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['sold_at_ms'] = Variable<int>(soldAtMs);
    map['total_cents'] = Variable<int>(totalCents);
    map['amount_received_cents'] = Variable<int>(amountReceivedCents);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['change_pending'] = Variable<bool>(changePending);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['discount_cents'] = Variable<int>(discountCents);
    if (!nullToAbsent || discountReason != null) {
      map['discount_reason'] = Variable<String>(discountReason);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      eventId: Value(eventId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      soldAtMs: Value(soldAtMs),
      totalCents: Value(totalCents),
      amountReceivedCents: Value(amountReceivedCents),
      paymentMethod: Value(paymentMethod),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      changePending: Value(changePending),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      discountCents: Value(discountCents),
      discountReason: discountReason == null && nullToAbsent
          ? const Value.absent()
          : Value(discountReason),
    );
  }

  factory PosSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PosSale(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      soldAtMs: serializer.fromJson<int>(json['soldAtMs']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      amountReceivedCents: serializer.fromJson<int>(
        json['amountReceivedCents'],
      ),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      notes: serializer.fromJson<String?>(json['notes']),
      changePending: serializer.fromJson<bool>(json['changePending']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      discountCents: serializer.fromJson<int>(json['discountCents']),
      discountReason: serializer.fromJson<String?>(json['discountReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'soldAtMs': serializer.toJson<int>(soldAtMs),
      'totalCents': serializer.toJson<int>(totalCents),
      'amountReceivedCents': serializer.toJson<int>(amountReceivedCents),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'notes': serializer.toJson<String?>(notes),
      'changePending': serializer.toJson<bool>(changePending),
      'customerName': serializer.toJson<String?>(customerName),
      'discountCents': serializer.toJson<int>(discountCents),
      'discountReason': serializer.toJson<String?>(discountReason),
    };
  }

  PosSale copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? eventId,
    Value<String?> sessionId = const Value.absent(),
    int? soldAtMs,
    int? totalCents,
    int? amountReceivedCents,
    String? paymentMethod,
    Value<String?> notes = const Value.absent(),
    bool? changePending,
    Value<String?> customerName = const Value.absent(),
    int? discountCents,
    Value<String?> discountReason = const Value.absent(),
  }) => PosSale(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    soldAtMs: soldAtMs ?? this.soldAtMs,
    totalCents: totalCents ?? this.totalCents,
    amountReceivedCents: amountReceivedCents ?? this.amountReceivedCents,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes.present ? notes.value : this.notes,
    changePending: changePending ?? this.changePending,
    customerName: customerName.present ? customerName.value : this.customerName,
    discountCents: discountCents ?? this.discountCents,
    discountReason: discountReason.present
        ? discountReason.value
        : this.discountReason,
  );
  PosSale copyWithCompanion(SalesCompanion data) {
    return PosSale(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
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
      notes: data.notes.present ? data.notes.value : this.notes,
      changePending: data.changePending.present
          ? data.changePending.value
          : this.changePending,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      discountCents: data.discountCents.present
          ? data.discountCents.value
          : this.discountCents,
      discountReason: data.discountReason.present
          ? data.discountReason.value
          : this.discountReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PosSale(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('sessionId: $sessionId, ')
          ..write('soldAtMs: $soldAtMs, ')
          ..write('totalCents: $totalCents, ')
          ..write('amountReceivedCents: $amountReceivedCents, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('changePending: $changePending, ')
          ..write('customerName: $customerName, ')
          ..write('discountCents: $discountCents, ')
          ..write('discountReason: $discountReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    sessionId,
    soldAtMs,
    totalCents,
    amountReceivedCents,
    paymentMethod,
    notes,
    changePending,
    customerName,
    discountCents,
    discountReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PosSale &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.sessionId == this.sessionId &&
          other.soldAtMs == this.soldAtMs &&
          other.totalCents == this.totalCents &&
          other.amountReceivedCents == this.amountReceivedCents &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes &&
          other.changePending == this.changePending &&
          other.customerName == this.customerName &&
          other.discountCents == this.discountCents &&
          other.discountReason == this.discountReason);
}

class SalesCompanion extends UpdateCompanion<PosSale> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> eventId;
  final Value<String?> sessionId;
  final Value<int> soldAtMs;
  final Value<int> totalCents;
  final Value<int> amountReceivedCents;
  final Value<String> paymentMethod;
  final Value<String?> notes;
  final Value<bool> changePending;
  final Value<String?> customerName;
  final Value<int> discountCents;
  final Value<String?> discountReason;
  final Value<int> rowid;
  const SalesCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.soldAtMs = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.amountReceivedCents = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.changePending = const Value.absent(),
    this.customerName = const Value.absent(),
    this.discountCents = const Value.absent(),
    this.discountReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String eventId,
    this.sessionId = const Value.absent(),
    required int soldAtMs,
    required int totalCents,
    required int amountReceivedCents,
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.changePending = const Value.absent(),
    this.customerName = const Value.absent(),
    this.discountCents = const Value.absent(),
    this.discountReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       soldAtMs = Value(soldAtMs),
       totalCents = Value(totalCents),
       amountReceivedCents = Value(amountReceivedCents);
  static Insertable<PosSale> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? sessionId,
    Expression<int>? soldAtMs,
    Expression<int>? totalCents,
    Expression<int>? amountReceivedCents,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<bool>? changePending,
    Expression<String>? customerName,
    Expression<int>? discountCents,
    Expression<String>? discountReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (sessionId != null) 'session_id': sessionId,
      if (soldAtMs != null) 'sold_at_ms': soldAtMs,
      if (totalCents != null) 'total_cents': totalCents,
      if (amountReceivedCents != null)
        'amount_received_cents': amountReceivedCents,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (changePending != null) 'change_pending': changePending,
      if (customerName != null) 'customer_name': customerName,
      if (discountCents != null) 'discount_cents': discountCents,
      if (discountReason != null) 'discount_reason': discountReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? eventId,
    Value<String?>? sessionId,
    Value<int>? soldAtMs,
    Value<int>? totalCents,
    Value<int>? amountReceivedCents,
    Value<String>? paymentMethod,
    Value<String?>? notes,
    Value<bool>? changePending,
    Value<String?>? customerName,
    Value<int>? discountCents,
    Value<String?>? discountReason,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      sessionId: sessionId ?? this.sessionId,
      soldAtMs: soldAtMs ?? this.soldAtMs,
      totalCents: totalCents ?? this.totalCents,
      amountReceivedCents: amountReceivedCents ?? this.amountReceivedCents,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      changePending: changePending ?? this.changePending,
      customerName: customerName ?? this.customerName,
      discountCents: discountCents ?? this.discountCents,
      discountReason: discountReason ?? this.discountReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (changePending.present) {
      map['change_pending'] = Variable<bool>(changePending.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (discountCents.present) {
      map['discount_cents'] = Variable<int>(discountCents.value);
    }
    if (discountReason.present) {
      map['discount_reason'] = Variable<String>(discountReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('sessionId: $sessionId, ')
          ..write('soldAtMs: $soldAtMs, ')
          ..write('totalCents: $totalCents, ')
          ..write('amountReceivedCents: $amountReceivedCents, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('changePending: $changePending, ')
          ..write('customerName: $customerName, ')
          ..write('discountCents: $discountCents, ')
          ..write('discountReason: $discountReason, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dotDenominationIdMeta = const VerificationMeta(
    'dotDenominationId',
  );
  @override
  late final GeneratedColumn<String> dotDenominationId =
      GeneratedColumn<String>(
        'dot_denomination_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      lineKind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_kind'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      dotDenominationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String saleId;
  final int lineKind;
  final String? productId;
  final String? dotDenominationId;
  final String? freeLabel;
  final int qty;
  final int unitPriceCents;
  final int lineTotalCents;
  const PosSaleLine({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
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
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['line_kind'] = Variable<int>(lineKind);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || dotDenominationId != null) {
      map['dot_denomination_id'] = Variable<String>(dotDenominationId);
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
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
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
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      lineKind: serializer.fromJson<int>(json['lineKind']),
      productId: serializer.fromJson<String?>(json['productId']),
      dotDenominationId: serializer.fromJson<String?>(
        json['dotDenominationId'],
      ),
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
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'lineKind': serializer.toJson<int>(lineKind),
      'productId': serializer.toJson<String?>(productId),
      'dotDenominationId': serializer.toJson<String?>(dotDenominationId),
      'freeLabel': serializer.toJson<String?>(freeLabel),
      'qty': serializer.toJson<int>(qty),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'lineTotalCents': serializer.toJson<int>(lineTotalCents),
    };
  }

  PosSaleLine copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? saleId,
    int? lineKind,
    Value<String?> productId = const Value.absent(),
    Value<String?> dotDenominationId = const Value.absent(),
    Value<String?> freeLabel = const Value.absent(),
    int? qty,
    int? unitPriceCents,
    int? lineTotalCents,
  }) => PosSaleLine(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
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
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
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
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
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
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
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
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
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
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> saleId;
  final Value<int> lineKind;
  final Value<String?> productId;
  final Value<String?> dotDenominationId;
  final Value<String?> freeLabel;
  final Value<int> qty;
  final Value<int> unitPriceCents;
  final Value<int> lineTotalCents;
  final Value<int> rowid;
  const SaleLinesCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.lineKind = const Value.absent(),
    this.productId = const Value.absent(),
    this.dotDenominationId = const Value.absent(),
    this.freeLabel = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.lineTotalCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleLinesCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String saleId,
    this.lineKind = const Value.absent(),
    this.productId = const Value.absent(),
    this.dotDenominationId = const Value.absent(),
    this.freeLabel = const Value.absent(),
    required int qty,
    required int unitPriceCents,
    required int lineTotalCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       qty = Value(qty),
       unitPriceCents = Value(unitPriceCents),
       lineTotalCents = Value(lineTotalCents);
  static Insertable<PosSaleLine> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<int>? lineKind,
    Expression<String>? productId,
    Expression<String>? dotDenominationId,
    Expression<String>? freeLabel,
    Expression<int>? qty,
    Expression<int>? unitPriceCents,
    Expression<int>? lineTotalCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (lineKind != null) 'line_kind': lineKind,
      if (productId != null) 'product_id': productId,
      if (dotDenominationId != null) 'dot_denomination_id': dotDenominationId,
      if (freeLabel != null) 'free_label': freeLabel,
      if (qty != null) 'qty': qty,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (lineTotalCents != null) 'line_total_cents': lineTotalCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleLinesCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? saleId,
    Value<int>? lineKind,
    Value<String?>? productId,
    Value<String?>? dotDenominationId,
    Value<String?>? freeLabel,
    Value<int>? qty,
    Value<int>? unitPriceCents,
    Value<int>? lineTotalCents,
    Value<int>? rowid,
  }) {
    return SaleLinesCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      lineKind: lineKind ?? this.lineKind,
      productId: productId ?? this.productId,
      dotDenominationId: dotDenominationId ?? this.dotDenominationId,
      freeLabel: freeLabel ?? this.freeLabel,
      qty: qty ?? this.qty,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      lineTotalCents: lineTotalCents ?? this.lineTotalCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (lineKind.present) {
      map['line_kind'] = Variable<int>(lineKind.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (dotDenominationId.present) {
      map['dot_denomination_id'] = Variable<String>(dotDenominationId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('lineKind: $lineKind, ')
          ..write('productId: $productId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('freeLabel: $freeLabel, ')
          ..write('qty: $qty, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('lineTotalCents: $lineTotalCents, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dotDenominationIdMeta = const VerificationMeta(
    'dotDenominationId',
  );
  @override
  late final GeneratedColumn<String> dotDenominationId =
      GeneratedColumn<String>(
        'dot_denomination_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    saleId,
    dotDenominationId,
    qty,
  ];
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
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      dotDenominationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String saleId;
  final String dotDenominationId;
  final int qty;
  const ChangeDotRow({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.saleId,
    required this.dotDenominationId,
    required this.qty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['dot_denomination_id'] = Variable<String>(dotDenominationId);
    map['qty'] = Variable<int>(qty);
    return map;
  }

  SaleChangeDotAllocationsCompanion toCompanion(bool nullToAbsent) {
    return SaleChangeDotAllocationsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
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
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      dotDenominationId: serializer.fromJson<String>(json['dotDenominationId']),
      qty: serializer.fromJson<int>(json['qty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'dotDenominationId': serializer.toJson<String>(dotDenominationId),
      'qty': serializer.toJson<int>(qty),
    };
  }

  ChangeDotRow copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? saleId,
    String? dotDenominationId,
    int? qty,
  }) => ChangeDotRow(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    dotDenominationId: dotDenominationId ?? this.dotDenominationId,
    qty: qty ?? this.qty,
  );
  ChangeDotRow copyWithCompanion(SaleChangeDotAllocationsCompanion data) {
    return ChangeDotRow(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
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
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    saleId,
    dotDenominationId,
    qty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeDotRow &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.dotDenominationId == this.dotDenominationId &&
          other.qty == this.qty);
}

class SaleChangeDotAllocationsCompanion extends UpdateCompanion<ChangeDotRow> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> dotDenominationId;
  final Value<int> qty;
  final Value<int> rowid;
  const SaleChangeDotAllocationsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.dotDenominationId = const Value.absent(),
    this.qty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleChangeDotAllocationsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String saleId,
    required String dotDenominationId,
    required int qty,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       dotDenominationId = Value(dotDenominationId),
       qty = Value(qty);
  static Insertable<ChangeDotRow> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? dotDenominationId,
    Expression<int>? qty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (dotDenominationId != null) 'dot_denomination_id': dotDenominationId,
      if (qty != null) 'qty': qty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleChangeDotAllocationsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? dotDenominationId,
    Value<int>? qty,
    Value<int>? rowid,
  }) {
    return SaleChangeDotAllocationsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      dotDenominationId: dotDenominationId ?? this.dotDenominationId,
      qty: qty ?? this.qty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (dotDenominationId.present) {
      map['dot_denomination_id'] = Variable<String>(dotDenominationId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleChangeDotAllocationsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('dotDenominationId: $dotDenominationId, ')
          ..write('qty: $qty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FiadoPaymentsTable extends FiadoPayments
    with TableInfo<$FiadoPaymentsTable, FiadoPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FiadoPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMsMeta = const VerificationMeta(
    'paidAtMs',
  );
  @override
  late final GeneratedColumn<int> paidAtMs = GeneratedColumn<int>(
    'paid_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    saleId,
    amountCents,
    method,
    paidAtMs,
    sessionId,
    notes,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fiado_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<FiadoPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('paid_at_ms')) {
      context.handle(
        _paidAtMsMeta,
        paidAtMs.isAcceptableOrUnknown(data['paid_at_ms']!, _paidAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMsMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FiadoPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FiadoPayment(
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      paidAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at_ms'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $FiadoPaymentsTable createAlias(String alias) {
    return $FiadoPaymentsTable(attachedDatabase, alias);
  }
}

class FiadoPayment extends DataClass implements Insertable<FiadoPayment> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String saleId;
  final int amountCents;

  /// [PaymentMethod.settlementMethods] (nunca 'fiado').
  final String method;
  final int paidAtMs;

  /// Sessão de caixa em que o dinheiro entrou (a da venda NÃO vale: fiado
  /// pode ser recebido semanas depois). Nulo = recebido fora de caixa.
  final String? sessionId;
  final String? notes;
  final String deviceId;
  const FiadoPayment({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.saleId,
    required this.amountCents,
    required this.method,
    required this.paidAtMs,
    this.sessionId,
    this.notes,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['method'] = Variable<String>(method);
    map['paid_at_ms'] = Variable<int>(paidAtMs);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  FiadoPaymentsCompanion toCompanion(bool nullToAbsent) {
    return FiadoPaymentsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      saleId: Value(saleId),
      amountCents: Value(amountCents),
      method: Value(method),
      paidAtMs: Value(paidAtMs),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deviceId: Value(deviceId),
    );
  }

  factory FiadoPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FiadoPayment(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      method: serializer.fromJson<String>(json['method']),
      paidAtMs: serializer.fromJson<int>(json['paidAtMs']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      notes: serializer.fromJson<String?>(json['notes']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'amountCents': serializer.toJson<int>(amountCents),
      'method': serializer.toJson<String>(method),
      'paidAtMs': serializer.toJson<int>(paidAtMs),
      'sessionId': serializer.toJson<String?>(sessionId),
      'notes': serializer.toJson<String?>(notes),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  FiadoPayment copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? saleId,
    int? amountCents,
    String? method,
    int? paidAtMs,
    Value<String?> sessionId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? deviceId,
  }) => FiadoPayment(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    amountCents: amountCents ?? this.amountCents,
    method: method ?? this.method,
    paidAtMs: paidAtMs ?? this.paidAtMs,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    notes: notes.present ? notes.value : this.notes,
    deviceId: deviceId ?? this.deviceId,
  );
  FiadoPayment copyWithCompanion(FiadoPaymentsCompanion data) {
    return FiadoPayment(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      method: data.method.present ? data.method.value : this.method,
      paidAtMs: data.paidAtMs.present ? data.paidAtMs.value : this.paidAtMs,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      notes: data.notes.present ? data.notes.value : this.notes,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FiadoPayment(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('amountCents: $amountCents, ')
          ..write('method: $method, ')
          ..write('paidAtMs: $paidAtMs, ')
          ..write('sessionId: $sessionId, ')
          ..write('notes: $notes, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    saleId,
    amountCents,
    method,
    paidAtMs,
    sessionId,
    notes,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FiadoPayment &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.amountCents == this.amountCents &&
          other.method == this.method &&
          other.paidAtMs == this.paidAtMs &&
          other.sessionId == this.sessionId &&
          other.notes == this.notes &&
          other.deviceId == this.deviceId);
}

class FiadoPaymentsCompanion extends UpdateCompanion<FiadoPayment> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> saleId;
  final Value<int> amountCents;
  final Value<String> method;
  final Value<int> paidAtMs;
  final Value<String?> sessionId;
  final Value<String?> notes;
  final Value<String> deviceId;
  final Value<int> rowid;
  const FiadoPaymentsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.method = const Value.absent(),
    this.paidAtMs = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FiadoPaymentsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String saleId,
    required int amountCents,
    required String method,
    required int paidAtMs,
    this.sessionId = const Value.absent(),
    this.notes = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       amountCents = Value(amountCents),
       method = Value(method),
       paidAtMs = Value(paidAtMs),
       deviceId = Value(deviceId);
  static Insertable<FiadoPayment> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<int>? amountCents,
    Expression<String>? method,
    Expression<int>? paidAtMs,
    Expression<String>? sessionId,
    Expression<String>? notes,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (method != null) 'method': method,
      if (paidAtMs != null) 'paid_at_ms': paidAtMs,
      if (sessionId != null) 'session_id': sessionId,
      if (notes != null) 'notes': notes,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FiadoPaymentsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? saleId,
    Value<int>? amountCents,
    Value<String>? method,
    Value<int>? paidAtMs,
    Value<String?>? sessionId,
    Value<String?>? notes,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return FiadoPaymentsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      amountCents: amountCents ?? this.amountCents,
      method: method ?? this.method,
      paidAtMs: paidAtMs ?? this.paidAtMs,
      sessionId: sessionId ?? this.sessionId,
      notes: notes ?? this.notes,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (paidAtMs.present) {
      map['paid_at_ms'] = Variable<int>(paidAtMs.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FiadoPaymentsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('amountCents: $amountCents, ')
          ..write('method: $method, ')
          ..write('paidAtMs: $paidAtMs, ')
          ..write('sessionId: $sessionId, ')
          ..write('notes: $notes, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventExpensesTable extends EventExpenses
    with TableInfo<$EventExpensesTable, EventExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Outros'),
  );
  static const VerificationMeta _paidAtMsMeta = const VerificationMeta(
    'paidAtMs',
  );
  @override
  late final GeneratedColumn<int> paidAtMs = GeneratedColumn<int>(
    'paid_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    description,
    amountCents,
    category,
    paidAtMs,
    notes,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('paid_at_ms')) {
      context.handle(
        _paidAtMsMeta,
        paidAtMs.isAcceptableOrUnknown(data['paid_at_ms']!, _paidAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventExpense(
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      paidAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at_ms'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $EventExpensesTable createAlias(String alias) {
    return $EventExpensesTable(attachedDatabase, alias);
  }
}

class EventExpense extends DataClass implements Insertable<EventExpense> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;
  final String eventId;
  final String description;
  final int amountCents;
  final String category;
  final int paidAtMs;
  final String? notes;
  final String deviceId;
  const EventExpense({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.eventId,
    required this.description,
    required this.amountCents,
    required this.category,
    required this.paidAtMs,
    this.notes,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['description'] = Variable<String>(description);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category'] = Variable<String>(category);
    map['paid_at_ms'] = Variable<int>(paidAtMs);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  EventExpensesCompanion toCompanion(bool nullToAbsent) {
    return EventExpensesCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      eventId: Value(eventId),
      description: Value(description),
      amountCents: Value(amountCents),
      category: Value(category),
      paidAtMs: Value(paidAtMs),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deviceId: Value(deviceId),
    );
  }

  factory EventExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventExpense(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      description: serializer.fromJson<String>(json['description']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      category: serializer.fromJson<String>(json['category']),
      paidAtMs: serializer.fromJson<int>(json['paidAtMs']),
      notes: serializer.fromJson<String?>(json['notes']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'description': serializer.toJson<String>(description),
      'amountCents': serializer.toJson<int>(amountCents),
      'category': serializer.toJson<String>(category),
      'paidAtMs': serializer.toJson<int>(paidAtMs),
      'notes': serializer.toJson<String?>(notes),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  EventExpense copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    String? eventId,
    String? description,
    int? amountCents,
    String? category,
    int? paidAtMs,
    Value<String?> notes = const Value.absent(),
    String? deviceId,
  }) => EventExpense(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    description: description ?? this.description,
    amountCents: amountCents ?? this.amountCents,
    category: category ?? this.category,
    paidAtMs: paidAtMs ?? this.paidAtMs,
    notes: notes.present ? notes.value : this.notes,
    deviceId: deviceId ?? this.deviceId,
  );
  EventExpense copyWithCompanion(EventExpensesCompanion data) {
    return EventExpense(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      description: data.description.present
          ? data.description.value
          : this.description,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      category: data.category.present ? data.category.value : this.category,
      paidAtMs: data.paidAtMs.present ? data.paidAtMs.value : this.paidAtMs,
      notes: data.notes.present ? data.notes.value : this.notes,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventExpense(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('category: $category, ')
          ..write('paidAtMs: $paidAtMs, ')
          ..write('notes: $notes, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    eventId,
    description,
    amountCents,
    category,
    paidAtMs,
    notes,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventExpense &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.description == this.description &&
          other.amountCents == this.amountCents &&
          other.category == this.category &&
          other.paidAtMs == this.paidAtMs &&
          other.notes == this.notes &&
          other.deviceId == this.deviceId);
}

class EventExpensesCompanion extends UpdateCompanion<EventExpense> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> description;
  final Value<int> amountCents;
  final Value<String> category;
  final Value<int> paidAtMs;
  final Value<String?> notes;
  final Value<String> deviceId;
  final Value<int> rowid;
  const EventExpensesCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.description = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.category = const Value.absent(),
    this.paidAtMs = const Value.absent(),
    this.notes = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventExpensesCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required String eventId,
    required String description,
    required int amountCents,
    this.category = const Value.absent(),
    required int paidAtMs,
    this.notes = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       description = Value(description),
       amountCents = Value(amountCents),
       paidAtMs = Value(paidAtMs),
       deviceId = Value(deviceId);
  static Insertable<EventExpense> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? description,
    Expression<int>? amountCents,
    Expression<String>? category,
    Expression<int>? paidAtMs,
    Expression<String>? notes,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (description != null) 'description': description,
      if (amountCents != null) 'amount_cents': amountCents,
      if (category != null) 'category': category,
      if (paidAtMs != null) 'paid_at_ms': paidAtMs,
      if (notes != null) 'notes': notes,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventExpensesCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? description,
    Value<int>? amountCents,
    Value<String>? category,
    Value<int>? paidAtMs,
    Value<String?>? notes,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return EventExpensesCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      category: category ?? this.category,
      paidAtMs: paidAtMs ?? this.paidAtMs,
      notes: notes ?? this.notes,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (paidAtMs.present) {
      map['paid_at_ms'] = Variable<int>(paidAtMs.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventExpensesCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('category: $category, ')
          ..write('paidAtMs: $paidAtMs, ')
          ..write('notes: $notes, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowVersionMeta = const VerificationMeta(
    'rowVersion',
  );
  @override
  late final GeneratedColumn<int> rowVersion = GeneratedColumn<int>(
    'row_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedByDeviceMeta = const VerificationMeta(
    'updatedByDevice',
  );
  @override
  late final GeneratedColumn<String> updatedByDevice = GeneratedColumn<String>(
    'updated_by_device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<int> itemType = GeneratedColumn<int>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<int> reason = GeneratedColumn<int>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    itemType,
    itemId,
    delta,
    reason,
    saleId,
    atMs,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_version')) {
      context.handle(
        _rowVersionMeta,
        rowVersion.isAcceptableOrUnknown(data['row_version']!, _rowVersionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_device')) {
      context.handle(
        _updatedByDeviceMeta,
        updatedByDevice.isAcceptableOrUnknown(
          data['updated_by_device']!,
          _updatedByDeviceMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    } else if (isInserting) {
      context.missing(_atMsMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      rowVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device'],
      ),
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_type'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reason'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final int rowVersion;
  final int updatedAtMs;
  final String? updatedByDevice;
  final int? deletedAtMs;
  final String id;

  /// 0 = produto, 1 = ficha.
  final int itemType;
  final String itemId;
  final int delta;

  /// Ver [StockMovementReason].
  final int reason;
  final String? saleId;
  final int atMs;
  final String deviceId;
  const StockMovement({
    required this.rowVersion,
    required this.updatedAtMs,
    this.updatedByDevice,
    this.deletedAtMs,
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.delta,
    required this.reason,
    this.saleId,
    required this.atMs,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_version'] = Variable<int>(rowVersion);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByDevice != null) {
      map['updated_by_device'] = Variable<String>(updatedByDevice);
    }
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    map['id'] = Variable<String>(id);
    map['item_type'] = Variable<int>(itemType);
    map['item_id'] = Variable<String>(itemId);
    map['delta'] = Variable<int>(delta);
    map['reason'] = Variable<int>(reason);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    map['at_ms'] = Variable<int>(atMs);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      rowVersion: Value(rowVersion),
      updatedAtMs: Value(updatedAtMs),
      updatedByDevice: updatedByDevice == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDevice),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
      id: Value(id),
      itemType: Value(itemType),
      itemId: Value(itemId),
      delta: Value(delta),
      reason: Value(reason),
      saleId: saleId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleId),
      atMs: Value(atMs),
      deviceId: Value(deviceId),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      rowVersion: serializer.fromJson<int>(json['rowVersion']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByDevice: serializer.fromJson<String?>(json['updatedByDevice']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
      id: serializer.fromJson<String>(json['id']),
      itemType: serializer.fromJson<int>(json['itemType']),
      itemId: serializer.fromJson<String>(json['itemId']),
      delta: serializer.fromJson<int>(json['delta']),
      reason: serializer.fromJson<int>(json['reason']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      atMs: serializer.fromJson<int>(json['atMs']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowVersion': serializer.toJson<int>(rowVersion),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByDevice': serializer.toJson<String?>(updatedByDevice),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
      'id': serializer.toJson<String>(id),
      'itemType': serializer.toJson<int>(itemType),
      'itemId': serializer.toJson<String>(itemId),
      'delta': serializer.toJson<int>(delta),
      'reason': serializer.toJson<int>(reason),
      'saleId': serializer.toJson<String?>(saleId),
      'atMs': serializer.toJson<int>(atMs),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StockMovement copyWith({
    int? rowVersion,
    int? updatedAtMs,
    Value<String?> updatedByDevice = const Value.absent(),
    Value<int?> deletedAtMs = const Value.absent(),
    String? id,
    int? itemType,
    String? itemId,
    int? delta,
    int? reason,
    Value<String?> saleId = const Value.absent(),
    int? atMs,
    String? deviceId,
  }) => StockMovement(
    rowVersion: rowVersion ?? this.rowVersion,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByDevice: updatedByDevice.present
        ? updatedByDevice.value
        : this.updatedByDevice,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
    id: id ?? this.id,
    itemType: itemType ?? this.itemType,
    itemId: itemId ?? this.itemId,
    delta: delta ?? this.delta,
    reason: reason ?? this.reason,
    saleId: saleId.present ? saleId.value : this.saleId,
    atMs: atMs ?? this.atMs,
    deviceId: deviceId ?? this.deviceId,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      rowVersion: data.rowVersion.present
          ? data.rowVersion.value
          : this.rowVersion,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByDevice: data.updatedByDevice.present
          ? data.updatedByDevice.value
          : this.updatedByDevice,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
      id: data.id.present ? data.id.value : this.id,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      delta: data.delta.present ? data.delta.value : this.delta,
      reason: data.reason.present ? data.reason.value : this.reason,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('itemType: $itemType, ')
          ..write('itemId: $itemId, ')
          ..write('delta: $delta, ')
          ..write('reason: $reason, ')
          ..write('saleId: $saleId, ')
          ..write('atMs: $atMs, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowVersion,
    updatedAtMs,
    updatedByDevice,
    deletedAtMs,
    id,
    itemType,
    itemId,
    delta,
    reason,
    saleId,
    atMs,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.rowVersion == this.rowVersion &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByDevice == this.updatedByDevice &&
          other.deletedAtMs == this.deletedAtMs &&
          other.id == this.id &&
          other.itemType == this.itemType &&
          other.itemId == this.itemId &&
          other.delta == this.delta &&
          other.reason == this.reason &&
          other.saleId == this.saleId &&
          other.atMs == this.atMs &&
          other.deviceId == this.deviceId);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<int> rowVersion;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByDevice;
  final Value<int?> deletedAtMs;
  final Value<String> id;
  final Value<int> itemType;
  final Value<String> itemId;
  final Value<int> delta;
  final Value<int> reason;
  final Value<String?> saleId;
  final Value<int> atMs;
  final Value<String> deviceId;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.id = const Value.absent(),
    this.itemType = const Value.absent(),
    this.itemId = const Value.absent(),
    this.delta = const Value.absent(),
    this.reason = const Value.absent(),
    this.saleId = const Value.absent(),
    this.atMs = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.rowVersion = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByDevice = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    required String id,
    required int itemType,
    required String itemId,
    required int delta,
    required int reason,
    this.saleId = const Value.absent(),
    required int atMs,
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemType = Value(itemType),
       itemId = Value(itemId),
       delta = Value(delta),
       reason = Value(reason),
       atMs = Value(atMs),
       deviceId = Value(deviceId);
  static Insertable<StockMovement> custom({
    Expression<int>? rowVersion,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByDevice,
    Expression<int>? deletedAtMs,
    Expression<String>? id,
    Expression<int>? itemType,
    Expression<String>? itemId,
    Expression<int>? delta,
    Expression<int>? reason,
    Expression<String>? saleId,
    Expression<int>? atMs,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rowVersion != null) 'row_version': rowVersion,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByDevice != null) 'updated_by_device': updatedByDevice,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (id != null) 'id': id,
      if (itemType != null) 'item_type': itemType,
      if (itemId != null) 'item_id': itemId,
      if (delta != null) 'delta': delta,
      if (reason != null) 'reason': reason,
      if (saleId != null) 'sale_id': saleId,
      if (atMs != null) 'at_ms': atMs,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<int>? rowVersion,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByDevice,
    Value<int?>? deletedAtMs,
    Value<String>? id,
    Value<int>? itemType,
    Value<String>? itemId,
    Value<int>? delta,
    Value<int>? reason,
    Value<String?>? saleId,
    Value<int>? atMs,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      rowVersion: rowVersion ?? this.rowVersion,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByDevice: updatedByDevice ?? this.updatedByDevice,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      delta: delta ?? this.delta,
      reason: reason ?? this.reason,
      saleId: saleId ?? this.saleId,
      atMs: atMs ?? this.atMs,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowVersion.present) {
      map['row_version'] = Variable<int>(rowVersion.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByDevice.present) {
      map['updated_by_device'] = Variable<String>(updatedByDevice.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<int>(itemType.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (reason.present) {
      map['reason'] = Variable<int>(reason.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('rowVersion: $rowVersion, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByDevice: $updatedByDevice, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('id: $id, ')
          ..write('itemType: $itemType, ')
          ..write('itemId: $itemId, ')
          ..write('delta: $delta, ')
          ..write('reason: $reason, ')
          ..write('saleId: $saleId, ')
          ..write('atMs: $atMs, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
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
  late final $ProductComboItemsTable productComboItems =
      $ProductComboItemsTable(this);
  late final $CashSessionsTable cashSessions = $CashSessionsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleLinesTable saleLines = $SaleLinesTable(this);
  late final $SaleChangeDotAllocationsTable saleChangeDotAllocations =
      $SaleChangeDotAllocationsTable(this);
  late final $FiadoPaymentsTable fiadoPayments = $FiadoPaymentsTable(this);
  late final $EventExpensesTable eventExpenses = $EventExpensesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    events,
    eventDotDenominations,
    products,
    productComboItems,
    cashSessions,
    sales,
    saleLines,
    saleChangeDotAllocations,
    fiadoPayments,
    eventExpenses,
    stockMovements,
  ];
}

typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String title,
      Value<String> notes,
      required int dateEpochMs,
      Value<String?> pixKey,
      Value<String?> pixMerchantName,
      Value<String?> pixMerchantCity,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> title,
      Value<String> notes,
      Value<int> dateEpochMs,
      Value<String?> pixKey,
      Value<String?> pixMerchantName,
      Value<String?> pixMerchantCity,
      Value<int> rowid,
    });

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnFilters<String> get pixKey => $composableBuilder(
    column: $table.pixKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pixMerchantName => $composableBuilder(
    column: $table.pixMerchantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pixMerchantCity => $composableBuilder(
    column: $table.pixMerchantCity,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<String> get pixKey => $composableBuilder(
    column: $table.pixKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pixMerchantName => $composableBuilder(
    column: $table.pixMerchantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pixMerchantCity => $composableBuilder(
    column: $table.pixMerchantCity,
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
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get dateEpochMs => $composableBuilder(
    column: $table.dateEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pixKey =>
      $composableBuilder(column: $table.pixKey, builder: (column) => column);

  GeneratedColumn<String> get pixMerchantName => $composableBuilder(
    column: $table.pixMerchantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pixMerchantCity => $composableBuilder(
    column: $table.pixMerchantCity,
    builder: (column) => column,
  );
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
          (
            ChurchEvent,
            BaseReferences<_$AppDatabase, $EventsTable, ChurchEvent>,
          ),
          ChurchEvent,
          PrefetchHooks Function()
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
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> dateEpochMs = const Value.absent(),
                Value<String?> pixKey = const Value.absent(),
                Value<String?> pixMerchantName = const Value.absent(),
                Value<String?> pixMerchantCity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                title: title,
                notes: notes,
                dateEpochMs: dateEpochMs,
                pixKey: pixKey,
                pixMerchantName: pixMerchantName,
                pixMerchantCity: pixMerchantCity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String title,
                Value<String> notes = const Value.absent(),
                required int dateEpochMs,
                Value<String?> pixKey = const Value.absent(),
                Value<String?> pixMerchantName = const Value.absent(),
                Value<String?> pixMerchantCity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                title: title,
                notes: notes,
                dateEpochMs: dateEpochMs,
                pixKey: pixKey,
                pixMerchantName: pixMerchantName,
                pixMerchantCity: pixMerchantCity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (ChurchEvent, BaseReferences<_$AppDatabase, $EventsTable, ChurchEvent>),
      ChurchEvent,
      PrefetchHooks Function()
    >;
typedef $$EventDotDenominationsTableCreateCompanionBuilder =
    EventDotDenominationsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String eventId,
      required String label,
      required int valueCents,
      Value<int> stockQty,
      Value<int> rowid,
    });
typedef $$EventDotDenominationsTableUpdateCompanionBuilder =
    EventDotDenominationsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> eventId,
      Value<String> label,
      Value<int> valueCents,
      Value<int> stockQty,
      Value<int> rowid,
    });

class $$EventDotDenominationsTableFilterComposer
    extends Composer<_$AppDatabase, $EventDotDenominationsTable> {
  $$EventDotDenominationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
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
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
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
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get valueCents => $composableBuilder(
    column: $table.valueCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);
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
          (
            EventDotDenom,
            BaseReferences<
              _$AppDatabase,
              $EventDotDenominationsTable,
              EventDotDenom
            >,
          ),
          EventDotDenom,
          PrefetchHooks Function()
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
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> valueCents = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventDotDenominationsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                label: label,
                valueCents: valueCents,
                stockQty: stockQty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String eventId,
                required String label,
                required int valueCents,
                Value<int> stockQty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventDotDenominationsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                label: label,
                valueCents: valueCents,
                stockQty: stockQty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        EventDotDenom,
        BaseReferences<
          _$AppDatabase,
          $EventDotDenominationsTable,
          EventDotDenom
        >,
      ),
      EventDotDenom,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String eventId,
      required String name,
      Value<String> description,
      required int priceCents,
      Value<bool> trackStock,
      Value<int> stockQty,
      Value<bool> active,
      Value<bool> isCombo,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> eventId,
      Value<String> name,
      Value<String> description,
      Value<int> priceCents,
      Value<bool> trackStock,
      Value<int> stockQty,
      Value<bool> active,
      Value<bool> isCombo,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
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

  ColumnFilters<bool> get isCombo => $composableBuilder(
    column: $table.isCombo,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
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

  ColumnOrderings<bool> get isCombo => $composableBuilder(
    column: $table.isCombo,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

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

  GeneratedColumn<bool> get isCombo =>
      $composableBuilder(column: $table.isCombo, builder: (column) => column);
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
          (
            ChurchProduct,
            BaseReferences<_$AppDatabase, $ProductsTable, ChurchProduct>,
          ),
          ChurchProduct,
          PrefetchHooks Function()
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
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> priceCents = const Value.absent(),
                Value<bool> trackStock = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> isCombo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                name: name,
                description: description,
                priceCents: priceCents,
                trackStock: trackStock,
                stockQty: stockQty,
                active: active,
                isCombo: isCombo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String eventId,
                required String name,
                Value<String> description = const Value.absent(),
                required int priceCents,
                Value<bool> trackStock = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<bool> isCombo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                name: name,
                description: description,
                priceCents: priceCents,
                trackStock: trackStock,
                stockQty: stockQty,
                active: active,
                isCombo: isCombo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        ChurchProduct,
        BaseReferences<_$AppDatabase, $ProductsTable, ChurchProduct>,
      ),
      ChurchProduct,
      PrefetchHooks Function()
    >;
typedef $$ProductComboItemsTableCreateCompanionBuilder =
    ProductComboItemsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String comboProductId,
      required String childProductId,
      required int qty,
      Value<int> rowid,
    });
typedef $$ProductComboItemsTableUpdateCompanionBuilder =
    ProductComboItemsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> comboProductId,
      Value<String> childProductId,
      Value<int> qty,
      Value<int> rowid,
    });

class $$ProductComboItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductComboItemsTable> {
  $$ProductComboItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comboProductId => $composableBuilder(
    column: $table.comboProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childProductId => $composableBuilder(
    column: $table.childProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductComboItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductComboItemsTable> {
  $$ProductComboItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comboProductId => $composableBuilder(
    column: $table.comboProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childProductId => $composableBuilder(
    column: $table.childProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductComboItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductComboItemsTable> {
  $$ProductComboItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comboProductId => $composableBuilder(
    column: $table.comboProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childProductId => $composableBuilder(
    column: $table.childProductId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);
}

class $$ProductComboItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductComboItemsTable,
          ProductComboItem,
          $$ProductComboItemsTableFilterComposer,
          $$ProductComboItemsTableOrderingComposer,
          $$ProductComboItemsTableAnnotationComposer,
          $$ProductComboItemsTableCreateCompanionBuilder,
          $$ProductComboItemsTableUpdateCompanionBuilder,
          (
            ProductComboItem,
            BaseReferences<
              _$AppDatabase,
              $ProductComboItemsTable,
              ProductComboItem
            >,
          ),
          ProductComboItem,
          PrefetchHooks Function()
        > {
  $$ProductComboItemsTableTableManager(
    _$AppDatabase db,
    $ProductComboItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductComboItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductComboItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductComboItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> comboProductId = const Value.absent(),
                Value<String> childProductId = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductComboItemsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                comboProductId: comboProductId,
                childProductId: childProductId,
                qty: qty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String comboProductId,
                required String childProductId,
                required int qty,
                Value<int> rowid = const Value.absent(),
              }) => ProductComboItemsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                comboProductId: comboProductId,
                childProductId: childProductId,
                qty: qty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductComboItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductComboItemsTable,
      ProductComboItem,
      $$ProductComboItemsTableFilterComposer,
      $$ProductComboItemsTableOrderingComposer,
      $$ProductComboItemsTableAnnotationComposer,
      $$ProductComboItemsTableCreateCompanionBuilder,
      $$ProductComboItemsTableUpdateCompanionBuilder,
      (
        ProductComboItem,
        BaseReferences<
          _$AppDatabase,
          $ProductComboItemsTable,
          ProductComboItem
        >,
      ),
      ProductComboItem,
      PrefetchHooks Function()
    >;
typedef $$CashSessionsTableCreateCompanionBuilder =
    CashSessionsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String eventId,
      required String title,
      required int openedAtMs,
      Value<String?> openedBy,
      Value<int?> closedAtMs,
      Value<int> initialCashFloatCents,
      Value<int?> closedCashDrawerCents,
      Value<String?> closedNotes,
      Value<String?> closedBy,
      Value<int> rowid,
    });
typedef $$CashSessionsTableUpdateCompanionBuilder =
    CashSessionsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> eventId,
      Value<String> title,
      Value<int> openedAtMs,
      Value<String?> openedBy,
      Value<int?> closedAtMs,
      Value<int> initialCashFloatCents,
      Value<int?> closedCashDrawerCents,
      Value<String?> closedNotes,
      Value<String?> closedBy,
      Value<int> rowid,
    });

class $$CashSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CashSessionsTable> {
  $$CashSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openedAtMs => $composableBuilder(
    column: $table.openedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openedBy => $composableBuilder(
    column: $table.openedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedAtMs => $composableBuilder(
    column: $table.closedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialCashFloatCents => $composableBuilder(
    column: $table.initialCashFloatCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedCashDrawerCents => $composableBuilder(
    column: $table.closedCashDrawerCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedNotes => $composableBuilder(
    column: $table.closedNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashSessionsTable> {
  $$CashSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openedAtMs => $composableBuilder(
    column: $table.openedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedBy => $composableBuilder(
    column: $table.openedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAtMs => $composableBuilder(
    column: $table.closedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialCashFloatCents => $composableBuilder(
    column: $table.initialCashFloatCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedCashDrawerCents => $composableBuilder(
    column: $table.closedCashDrawerCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedNotes => $composableBuilder(
    column: $table.closedNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashSessionsTable> {
  $$CashSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get openedAtMs => $composableBuilder(
    column: $table.openedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openedBy =>
      $composableBuilder(column: $table.openedBy, builder: (column) => column);

  GeneratedColumn<int> get closedAtMs => $composableBuilder(
    column: $table.closedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialCashFloatCents => $composableBuilder(
    column: $table.initialCashFloatCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get closedCashDrawerCents => $composableBuilder(
    column: $table.closedCashDrawerCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedNotes => $composableBuilder(
    column: $table.closedNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closedBy =>
      $composableBuilder(column: $table.closedBy, builder: (column) => column);
}

class $$CashSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashSessionsTable,
          CashSession,
          $$CashSessionsTableFilterComposer,
          $$CashSessionsTableOrderingComposer,
          $$CashSessionsTableAnnotationComposer,
          $$CashSessionsTableCreateCompanionBuilder,
          $$CashSessionsTableUpdateCompanionBuilder,
          (
            CashSession,
            BaseReferences<_$AppDatabase, $CashSessionsTable, CashSession>,
          ),
          CashSession,
          PrefetchHooks Function()
        > {
  $$CashSessionsTableTableManager(_$AppDatabase db, $CashSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> openedAtMs = const Value.absent(),
                Value<String?> openedBy = const Value.absent(),
                Value<int?> closedAtMs = const Value.absent(),
                Value<int> initialCashFloatCents = const Value.absent(),
                Value<int?> closedCashDrawerCents = const Value.absent(),
                Value<String?> closedNotes = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashSessionsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                title: title,
                openedAtMs: openedAtMs,
                openedBy: openedBy,
                closedAtMs: closedAtMs,
                initialCashFloatCents: initialCashFloatCents,
                closedCashDrawerCents: closedCashDrawerCents,
                closedNotes: closedNotes,
                closedBy: closedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String eventId,
                required String title,
                required int openedAtMs,
                Value<String?> openedBy = const Value.absent(),
                Value<int?> closedAtMs = const Value.absent(),
                Value<int> initialCashFloatCents = const Value.absent(),
                Value<int?> closedCashDrawerCents = const Value.absent(),
                Value<String?> closedNotes = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashSessionsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                title: title,
                openedAtMs: openedAtMs,
                openedBy: openedBy,
                closedAtMs: closedAtMs,
                initialCashFloatCents: initialCashFloatCents,
                closedCashDrawerCents: closedCashDrawerCents,
                closedNotes: closedNotes,
                closedBy: closedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashSessionsTable,
      CashSession,
      $$CashSessionsTableFilterComposer,
      $$CashSessionsTableOrderingComposer,
      $$CashSessionsTableAnnotationComposer,
      $$CashSessionsTableCreateCompanionBuilder,
      $$CashSessionsTableUpdateCompanionBuilder,
      (
        CashSession,
        BaseReferences<_$AppDatabase, $CashSessionsTable, CashSession>,
      ),
      CashSession,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String eventId,
      Value<String?> sessionId,
      required int soldAtMs,
      required int totalCents,
      required int amountReceivedCents,
      Value<String> paymentMethod,
      Value<String?> notes,
      Value<bool> changePending,
      Value<String?> customerName,
      Value<int> discountCents,
      Value<String?> discountReason,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> eventId,
      Value<String?> sessionId,
      Value<int> soldAtMs,
      Value<int> totalCents,
      Value<int> amountReceivedCents,
      Value<String> paymentMethod,
      Value<String?> notes,
      Value<bool> changePending,
      Value<String?> customerName,
      Value<int> discountCents,
      Value<String?> discountReason,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get changePending => $composableBuilder(
    column: $table.changePending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountReason => $composableBuilder(
    column: $table.discountReason,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get changePending => $composableBuilder(
    column: $table.changePending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountReason => $composableBuilder(
    column: $table.discountReason,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get changePending => $composableBuilder(
    column: $table.changePending,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountCents => $composableBuilder(
    column: $table.discountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountReason => $composableBuilder(
    column: $table.discountReason,
    builder: (column) => column,
  );
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
          (PosSale, BaseReferences<_$AppDatabase, $SalesTable, PosSale>),
          PosSale,
          PrefetchHooks Function()
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
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int> soldAtMs = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> amountReceivedCents = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> changePending = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<int> discountCents = const Value.absent(),
                Value<String?> discountReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                sessionId: sessionId,
                soldAtMs: soldAtMs,
                totalCents: totalCents,
                amountReceivedCents: amountReceivedCents,
                paymentMethod: paymentMethod,
                notes: notes,
                changePending: changePending,
                customerName: customerName,
                discountCents: discountCents,
                discountReason: discountReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String eventId,
                Value<String?> sessionId = const Value.absent(),
                required int soldAtMs,
                required int totalCents,
                required int amountReceivedCents,
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> changePending = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<int> discountCents = const Value.absent(),
                Value<String?> discountReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                sessionId: sessionId,
                soldAtMs: soldAtMs,
                totalCents: totalCents,
                amountReceivedCents: amountReceivedCents,
                paymentMethod: paymentMethod,
                notes: notes,
                changePending: changePending,
                customerName: customerName,
                discountCents: discountCents,
                discountReason: discountReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (PosSale, BaseReferences<_$AppDatabase, $SalesTable, PosSale>),
      PosSale,
      PrefetchHooks Function()
    >;
typedef $$SaleLinesTableCreateCompanionBuilder =
    SaleLinesCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String saleId,
      Value<int> lineKind,
      Value<String?> productId,
      Value<String?> dotDenominationId,
      Value<String?> freeLabel,
      required int qty,
      required int unitPriceCents,
      required int lineTotalCents,
      Value<int> rowid,
    });
typedef $$SaleLinesTableUpdateCompanionBuilder =
    SaleLinesCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> saleId,
      Value<int> lineKind,
      Value<String?> productId,
      Value<String?> dotDenominationId,
      Value<String?> freeLabel,
      Value<int> qty,
      Value<int> unitPriceCents,
      Value<int> lineTotalCents,
      Value<int> rowid,
    });

class $$SaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineKind => $composableBuilder(
    column: $table.lineKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dotDenominationId => $composableBuilder(
    column: $table.dotDenominationId,
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
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineKind => $composableBuilder(
    column: $table.lineKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dotDenominationId => $composableBuilder(
    column: $table.dotDenominationId,
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
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<int> get lineKind =>
      $composableBuilder(column: $table.lineKind, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get dotDenominationId => $composableBuilder(
    column: $table.dotDenominationId,
    builder: (column) => column,
  );

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
          (
            PosSaleLine,
            BaseReferences<_$AppDatabase, $SaleLinesTable, PosSaleLine>,
          ),
          PosSaleLine,
          PrefetchHooks Function()
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
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<int> lineKind = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> dotDenominationId = const Value.absent(),
                Value<String?> freeLabel = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> lineTotalCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                saleId: saleId,
                lineKind: lineKind,
                productId: productId,
                dotDenominationId: dotDenominationId,
                freeLabel: freeLabel,
                qty: qty,
                unitPriceCents: unitPriceCents,
                lineTotalCents: lineTotalCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String saleId,
                Value<int> lineKind = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> dotDenominationId = const Value.absent(),
                Value<String?> freeLabel = const Value.absent(),
                required int qty,
                required int unitPriceCents,
                required int lineTotalCents,
                Value<int> rowid = const Value.absent(),
              }) => SaleLinesCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                saleId: saleId,
                lineKind: lineKind,
                productId: productId,
                dotDenominationId: dotDenominationId,
                freeLabel: freeLabel,
                qty: qty,
                unitPriceCents: unitPriceCents,
                lineTotalCents: lineTotalCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        PosSaleLine,
        BaseReferences<_$AppDatabase, $SaleLinesTable, PosSaleLine>,
      ),
      PosSaleLine,
      PrefetchHooks Function()
    >;
typedef $$SaleChangeDotAllocationsTableCreateCompanionBuilder =
    SaleChangeDotAllocationsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String saleId,
      required String dotDenominationId,
      required int qty,
      Value<int> rowid,
    });
typedef $$SaleChangeDotAllocationsTableUpdateCompanionBuilder =
    SaleChangeDotAllocationsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> saleId,
      Value<String> dotDenominationId,
      Value<int> qty,
      Value<int> rowid,
    });

class $$SaleChangeDotAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleChangeDotAllocationsTable> {
  $$SaleChangeDotAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dotDenominationId => $composableBuilder(
    column: $table.dotDenominationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dotDenominationId => $composableBuilder(
    column: $table.dotDenominationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get dotDenominationId => $composableBuilder(
    column: $table.dotDenominationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);
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
          (
            ChangeDotRow,
            BaseReferences<
              _$AppDatabase,
              $SaleChangeDotAllocationsTable,
              ChangeDotRow
            >,
          ),
          ChangeDotRow,
          PrefetchHooks Function()
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
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> dotDenominationId = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleChangeDotAllocationsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                saleId: saleId,
                dotDenominationId: dotDenominationId,
                qty: qty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String saleId,
                required String dotDenominationId,
                required int qty,
                Value<int> rowid = const Value.absent(),
              }) => SaleChangeDotAllocationsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                saleId: saleId,
                dotDenominationId: dotDenominationId,
                qty: qty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        ChangeDotRow,
        BaseReferences<
          _$AppDatabase,
          $SaleChangeDotAllocationsTable,
          ChangeDotRow
        >,
      ),
      ChangeDotRow,
      PrefetchHooks Function()
    >;
typedef $$FiadoPaymentsTableCreateCompanionBuilder =
    FiadoPaymentsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String saleId,
      required int amountCents,
      required String method,
      required int paidAtMs,
      Value<String?> sessionId,
      Value<String?> notes,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$FiadoPaymentsTableUpdateCompanionBuilder =
    FiadoPaymentsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> saleId,
      Value<int> amountCents,
      Value<String> method,
      Value<int> paidAtMs,
      Value<String?> sessionId,
      Value<String?> notes,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$FiadoPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $FiadoPaymentsTable> {
  $$FiadoPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAtMs => $composableBuilder(
    column: $table.paidAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FiadoPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FiadoPaymentsTable> {
  $$FiadoPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAtMs => $composableBuilder(
    column: $table.paidAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FiadoPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FiadoPaymentsTable> {
  $$FiadoPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get paidAtMs =>
      $composableBuilder(column: $table.paidAtMs, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$FiadoPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FiadoPaymentsTable,
          FiadoPayment,
          $$FiadoPaymentsTableFilterComposer,
          $$FiadoPaymentsTableOrderingComposer,
          $$FiadoPaymentsTableAnnotationComposer,
          $$FiadoPaymentsTableCreateCompanionBuilder,
          $$FiadoPaymentsTableUpdateCompanionBuilder,
          (
            FiadoPayment,
            BaseReferences<_$AppDatabase, $FiadoPaymentsTable, FiadoPayment>,
          ),
          FiadoPayment,
          PrefetchHooks Function()
        > {
  $$FiadoPaymentsTableTableManager(_$AppDatabase db, $FiadoPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FiadoPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FiadoPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FiadoPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int> paidAtMs = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FiadoPaymentsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                saleId: saleId,
                amountCents: amountCents,
                method: method,
                paidAtMs: paidAtMs,
                sessionId: sessionId,
                notes: notes,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String saleId,
                required int amountCents,
                required String method,
                required int paidAtMs,
                Value<String?> sessionId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => FiadoPaymentsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                saleId: saleId,
                amountCents: amountCents,
                method: method,
                paidAtMs: paidAtMs,
                sessionId: sessionId,
                notes: notes,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FiadoPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FiadoPaymentsTable,
      FiadoPayment,
      $$FiadoPaymentsTableFilterComposer,
      $$FiadoPaymentsTableOrderingComposer,
      $$FiadoPaymentsTableAnnotationComposer,
      $$FiadoPaymentsTableCreateCompanionBuilder,
      $$FiadoPaymentsTableUpdateCompanionBuilder,
      (
        FiadoPayment,
        BaseReferences<_$AppDatabase, $FiadoPaymentsTable, FiadoPayment>,
      ),
      FiadoPayment,
      PrefetchHooks Function()
    >;
typedef $$EventExpensesTableCreateCompanionBuilder =
    EventExpensesCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required String eventId,
      required String description,
      required int amountCents,
      Value<String> category,
      required int paidAtMs,
      Value<String?> notes,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$EventExpensesTableUpdateCompanionBuilder =
    EventExpensesCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<String> eventId,
      Value<String> description,
      Value<int> amountCents,
      Value<String> category,
      Value<int> paidAtMs,
      Value<String?> notes,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$EventExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $EventExpensesTable> {
  $$EventExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAtMs => $composableBuilder(
    column: $table.paidAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $EventExpensesTable> {
  $$EventExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAtMs => $composableBuilder(
    column: $table.paidAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventExpensesTable> {
  $$EventExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get paidAtMs =>
      $composableBuilder(column: $table.paidAtMs, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$EventExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventExpensesTable,
          EventExpense,
          $$EventExpensesTableFilterComposer,
          $$EventExpensesTableOrderingComposer,
          $$EventExpensesTableAnnotationComposer,
          $$EventExpensesTableCreateCompanionBuilder,
          $$EventExpensesTableUpdateCompanionBuilder,
          (
            EventExpense,
            BaseReferences<_$AppDatabase, $EventExpensesTable, EventExpense>,
          ),
          EventExpense,
          PrefetchHooks Function()
        > {
  $$EventExpensesTableTableManager(_$AppDatabase db, $EventExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> paidAtMs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventExpensesCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                description: description,
                amountCents: amountCents,
                category: category,
                paidAtMs: paidAtMs,
                notes: notes,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required String eventId,
                required String description,
                required int amountCents,
                Value<String> category = const Value.absent(),
                required int paidAtMs,
                Value<String?> notes = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => EventExpensesCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                eventId: eventId,
                description: description,
                amountCents: amountCents,
                category: category,
                paidAtMs: paidAtMs,
                notes: notes,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventExpensesTable,
      EventExpense,
      $$EventExpensesTableFilterComposer,
      $$EventExpensesTableOrderingComposer,
      $$EventExpensesTableAnnotationComposer,
      $$EventExpensesTableCreateCompanionBuilder,
      $$EventExpensesTableUpdateCompanionBuilder,
      (
        EventExpense,
        BaseReferences<_$AppDatabase, $EventExpensesTable, EventExpense>,
      ),
      EventExpense,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      required String id,
      required int itemType,
      required String itemId,
      required int delta,
      required int reason,
      Value<String?> saleId,
      required int atMs,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> rowVersion,
      Value<int> updatedAtMs,
      Value<String?> updatedByDevice,
      Value<int?> deletedAtMs,
      Value<String> id,
      Value<int> itemType,
      Value<String> itemId,
      Value<int> delta,
      Value<int> reason,
      Value<String?> saleId,
      Value<int> atMs,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowVersion => $composableBuilder(
    column: $table.rowVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDevice => $composableBuilder(
    column: $table.updatedByDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<int> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovement,
            BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
          ),
          StockMovement,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> itemType = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<int> reason = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<int> atMs = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                itemType: itemType,
                itemId: itemId,
                delta: delta,
                reason: reason,
                saleId: saleId,
                atMs: atMs,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> rowVersion = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByDevice = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                required String id,
                required int itemType,
                required String itemId,
                required int delta,
                required int reason,
                Value<String?> saleId = const Value.absent(),
                required int atMs,
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                rowVersion: rowVersion,
                updatedAtMs: updatedAtMs,
                updatedByDevice: updatedByDevice,
                deletedAtMs: deletedAtMs,
                id: id,
                itemType: itemType,
                itemId: itemId,
                delta: delta,
                reason: reason,
                saleId: saleId,
                atMs: atMs,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovement,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>,
      ),
      StockMovement,
      PrefetchHooks Function()
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
  $$ProductComboItemsTableTableManager get productComboItems =>
      $$ProductComboItemsTableTableManager(_db, _db.productComboItems);
  $$CashSessionsTableTableManager get cashSessions =>
      $$CashSessionsTableTableManager(_db, _db.cashSessions);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleLinesTableTableManager get saleLines =>
      $$SaleLinesTableTableManager(_db, _db.saleLines);
  $$SaleChangeDotAllocationsTableTableManager get saleChangeDotAllocations =>
      $$SaleChangeDotAllocationsTableTableManager(
        _db,
        _db.saleChangeDotAllocations,
      );
  $$FiadoPaymentsTableTableManager get fiadoPayments =>
      $$FiadoPaymentsTableTableManager(_db, _db.fiadoPayments);
  $$EventExpensesTableTableManager get eventExpenses =>
      $$EventExpensesTableTableManager(_db, _db.eventExpenses);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
}
