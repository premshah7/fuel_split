// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startLocationMeta = const VerificationMeta(
    'startLocation',
  );
  @override
  late final GeneratedColumn<String> startLocation = GeneratedColumn<String>(
    'start_location',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endLocationMeta = const VerificationMeta(
    'endLocation',
  );
  @override
  late final GeneratedColumn<String> endLocation = GeneratedColumn<String>(
    'end_location',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
    'distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripDateMeta = const VerificationMeta(
    'tripDate',
  );
  @override
  late final GeneratedColumn<DateTime> tripDate = GeneratedColumn<DateTime>(
    'trip_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _isRoundTripMeta = const VerificationMeta(
    'isRoundTrip',
  );
  @override
  late final GeneratedColumn<bool> isRoundTrip = GeneratedColumn<bool>(
    'is_round_trip',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_round_trip" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startLocation,
    endLocation,
    distance,
    tripDate,
    notes,
    isRoundTrip,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_location')) {
      context.handle(
        _startLocationMeta,
        startLocation.isAcceptableOrUnknown(
          data['start_location']!,
          _startLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startLocationMeta);
    }
    if (data.containsKey('end_location')) {
      context.handle(
        _endLocationMeta,
        endLocation.isAcceptableOrUnknown(
          data['end_location']!,
          _endLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endLocationMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMeta);
    }
    if (data.containsKey('trip_date')) {
      context.handle(
        _tripDateMeta,
        tripDate.isAcceptableOrUnknown(data['trip_date']!, _tripDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tripDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_round_trip')) {
      context.handle(
        _isRoundTripMeta,
        isRoundTrip.isAcceptableOrUnknown(
          data['is_round_trip']!,
          _isRoundTripMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_location'],
      )!,
      endLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_location'],
      )!,
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance'],
      )!,
      tripDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trip_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isRoundTrip: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_round_trip'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final int id;
  final String startLocation;
  final String endLocation;
  final double distance;
  final DateTime tripDate;
  final String? notes;
  final bool isRoundTrip;
  const Trip({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.tripDate,
    this.notes,
    required this.isRoundTrip,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_location'] = Variable<String>(startLocation);
    map['end_location'] = Variable<String>(endLocation);
    map['distance'] = Variable<double>(distance);
    map['trip_date'] = Variable<DateTime>(tripDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_round_trip'] = Variable<bool>(isRoundTrip);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      startLocation: Value(startLocation),
      endLocation: Value(endLocation),
      distance: Value(distance),
      tripDate: Value(tripDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isRoundTrip: Value(isRoundTrip),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<int>(json['id']),
      startLocation: serializer.fromJson<String>(json['startLocation']),
      endLocation: serializer.fromJson<String>(json['endLocation']),
      distance: serializer.fromJson<double>(json['distance']),
      tripDate: serializer.fromJson<DateTime>(json['tripDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isRoundTrip: serializer.fromJson<bool>(json['isRoundTrip']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startLocation': serializer.toJson<String>(startLocation),
      'endLocation': serializer.toJson<String>(endLocation),
      'distance': serializer.toJson<double>(distance),
      'tripDate': serializer.toJson<DateTime>(tripDate),
      'notes': serializer.toJson<String?>(notes),
      'isRoundTrip': serializer.toJson<bool>(isRoundTrip),
    };
  }

  Trip copyWith({
    int? id,
    String? startLocation,
    String? endLocation,
    double? distance,
    DateTime? tripDate,
    Value<String?> notes = const Value.absent(),
    bool? isRoundTrip,
  }) => Trip(
    id: id ?? this.id,
    startLocation: startLocation ?? this.startLocation,
    endLocation: endLocation ?? this.endLocation,
    distance: distance ?? this.distance,
    tripDate: tripDate ?? this.tripDate,
    notes: notes.present ? notes.value : this.notes,
    isRoundTrip: isRoundTrip ?? this.isRoundTrip,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      startLocation: data.startLocation.present
          ? data.startLocation.value
          : this.startLocation,
      endLocation: data.endLocation.present
          ? data.endLocation.value
          : this.endLocation,
      distance: data.distance.present ? data.distance.value : this.distance,
      tripDate: data.tripDate.present ? data.tripDate.value : this.tripDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isRoundTrip: data.isRoundTrip.present
          ? data.isRoundTrip.value
          : this.isRoundTrip,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('startLocation: $startLocation, ')
          ..write('endLocation: $endLocation, ')
          ..write('distance: $distance, ')
          ..write('tripDate: $tripDate, ')
          ..write('notes: $notes, ')
          ..write('isRoundTrip: $isRoundTrip')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startLocation,
    endLocation,
    distance,
    tripDate,
    notes,
    isRoundTrip,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.startLocation == this.startLocation &&
          other.endLocation == this.endLocation &&
          other.distance == this.distance &&
          other.tripDate == this.tripDate &&
          other.notes == this.notes &&
          other.isRoundTrip == this.isRoundTrip);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<int> id;
  final Value<String> startLocation;
  final Value<String> endLocation;
  final Value<double> distance;
  final Value<DateTime> tripDate;
  final Value<String?> notes;
  final Value<bool> isRoundTrip;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.startLocation = const Value.absent(),
    this.endLocation = const Value.absent(),
    this.distance = const Value.absent(),
    this.tripDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isRoundTrip = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    required String startLocation,
    required String endLocation,
    required double distance,
    required DateTime tripDate,
    this.notes = const Value.absent(),
    this.isRoundTrip = const Value.absent(),
  }) : startLocation = Value(startLocation),
       endLocation = Value(endLocation),
       distance = Value(distance),
       tripDate = Value(tripDate);
  static Insertable<Trip> custom({
    Expression<int>? id,
    Expression<String>? startLocation,
    Expression<String>? endLocation,
    Expression<double>? distance,
    Expression<DateTime>? tripDate,
    Expression<String>? notes,
    Expression<bool>? isRoundTrip,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startLocation != null) 'start_location': startLocation,
      if (endLocation != null) 'end_location': endLocation,
      if (distance != null) 'distance': distance,
      if (tripDate != null) 'trip_date': tripDate,
      if (notes != null) 'notes': notes,
      if (isRoundTrip != null) 'is_round_trip': isRoundTrip,
    });
  }

  TripsCompanion copyWith({
    Value<int>? id,
    Value<String>? startLocation,
    Value<String>? endLocation,
    Value<double>? distance,
    Value<DateTime>? tripDate,
    Value<String?>? notes,
    Value<bool>? isRoundTrip,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      distance: distance ?? this.distance,
      tripDate: tripDate ?? this.tripDate,
      notes: notes ?? this.notes,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startLocation.present) {
      map['start_location'] = Variable<String>(startLocation.value);
    }
    if (endLocation.present) {
      map['end_location'] = Variable<String>(endLocation.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (tripDate.present) {
      map['trip_date'] = Variable<DateTime>(tripDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isRoundTrip.present) {
      map['is_round_trip'] = Variable<bool>(isRoundTrip.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('startLocation: $startLocation, ')
          ..write('endLocation: $endLocation, ')
          ..write('distance: $distance, ')
          ..write('tripDate: $tripDate, ')
          ..write('notes: $notes, ')
          ..write('isRoundTrip: $isRoundTrip')
          ..write(')'))
        .toString();
  }
}

class $FuelLogsTable extends FuelLogs with TableInfo<$FuelLogsTable, FuelLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountLitersMeta = const VerificationMeta(
    'amountLiters',
  );
  @override
  late final GeneratedColumn<double> amountLiters = GeneratedColumn<double>(
    'amount_liters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerReadingMeta = const VerificationMeta(
    'odometerReading',
  );
  @override
  late final GeneratedColumn<double> odometerReading = GeneratedColumn<double>(
    'odometer_reading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTripConsumptionMeta = const VerificationMeta(
    'isTripConsumption',
  );
  @override
  late final GeneratedColumn<bool> isTripConsumption = GeneratedColumn<bool>(
    'is_trip_consumption',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trip_consumption" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountLiters,
    totalCost,
    odometerReading,
    logDate,
    isTripConsumption,
    tripId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_liters')) {
      context.handle(
        _amountLitersMeta,
        amountLiters.isAcceptableOrUnknown(
          data['amount_liters']!,
          _amountLitersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountLitersMeta);
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    if (data.containsKey('odometer_reading')) {
      context.handle(
        _odometerReadingMeta,
        odometerReading.isAcceptableOrUnknown(
          data['odometer_reading']!,
          _odometerReadingMeta,
        ),
      );
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('is_trip_consumption')) {
      context.handle(
        _isTripConsumptionMeta,
        isTripConsumption.isAcceptableOrUnknown(
          data['is_trip_consumption']!,
          _isTripConsumptionMeta,
        ),
      );
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountLiters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_liters'],
      )!,
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      )!,
      odometerReading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_reading'],
      ),
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      isTripConsumption: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trip_consumption'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
    );
  }

  @override
  $FuelLogsTable createAlias(String alias) {
    return $FuelLogsTable(attachedDatabase, alias);
  }
}

class FuelLog extends DataClass implements Insertable<FuelLog> {
  final int id;
  final double amountLiters;
  final double totalCost;
  final double? odometerReading;
  final DateTime logDate;
  final bool isTripConsumption;
  final int? tripId;
  const FuelLog({
    required this.id,
    required this.amountLiters,
    required this.totalCost,
    this.odometerReading,
    required this.logDate,
    required this.isTripConsumption,
    this.tripId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_liters'] = Variable<double>(amountLiters);
    map['total_cost'] = Variable<double>(totalCost);
    if (!nullToAbsent || odometerReading != null) {
      map['odometer_reading'] = Variable<double>(odometerReading);
    }
    map['log_date'] = Variable<DateTime>(logDate);
    map['is_trip_consumption'] = Variable<bool>(isTripConsumption);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    return map;
  }

  FuelLogsCompanion toCompanion(bool nullToAbsent) {
    return FuelLogsCompanion(
      id: Value(id),
      amountLiters: Value(amountLiters),
      totalCost: Value(totalCost),
      odometerReading: odometerReading == null && nullToAbsent
          ? const Value.absent()
          : Value(odometerReading),
      logDate: Value(logDate),
      isTripConsumption: Value(isTripConsumption),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
    );
  }

  factory FuelLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelLog(
      id: serializer.fromJson<int>(json['id']),
      amountLiters: serializer.fromJson<double>(json['amountLiters']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
      odometerReading: serializer.fromJson<double?>(json['odometerReading']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      isTripConsumption: serializer.fromJson<bool>(json['isTripConsumption']),
      tripId: serializer.fromJson<int?>(json['tripId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountLiters': serializer.toJson<double>(amountLiters),
      'totalCost': serializer.toJson<double>(totalCost),
      'odometerReading': serializer.toJson<double?>(odometerReading),
      'logDate': serializer.toJson<DateTime>(logDate),
      'isTripConsumption': serializer.toJson<bool>(isTripConsumption),
      'tripId': serializer.toJson<int?>(tripId),
    };
  }

  FuelLog copyWith({
    int? id,
    double? amountLiters,
    double? totalCost,
    Value<double?> odometerReading = const Value.absent(),
    DateTime? logDate,
    bool? isTripConsumption,
    Value<int?> tripId = const Value.absent(),
  }) => FuelLog(
    id: id ?? this.id,
    amountLiters: amountLiters ?? this.amountLiters,
    totalCost: totalCost ?? this.totalCost,
    odometerReading: odometerReading.present
        ? odometerReading.value
        : this.odometerReading,
    logDate: logDate ?? this.logDate,
    isTripConsumption: isTripConsumption ?? this.isTripConsumption,
    tripId: tripId.present ? tripId.value : this.tripId,
  );
  FuelLog copyWithCompanion(FuelLogsCompanion data) {
    return FuelLog(
      id: data.id.present ? data.id.value : this.id,
      amountLiters: data.amountLiters.present
          ? data.amountLiters.value
          : this.amountLiters,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      odometerReading: data.odometerReading.present
          ? data.odometerReading.value
          : this.odometerReading,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      isTripConsumption: data.isTripConsumption.present
          ? data.isTripConsumption.value
          : this.isTripConsumption,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelLog(')
          ..write('id: $id, ')
          ..write('amountLiters: $amountLiters, ')
          ..write('totalCost: $totalCost, ')
          ..write('odometerReading: $odometerReading, ')
          ..write('logDate: $logDate, ')
          ..write('isTripConsumption: $isTripConsumption, ')
          ..write('tripId: $tripId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountLiters,
    totalCost,
    odometerReading,
    logDate,
    isTripConsumption,
    tripId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelLog &&
          other.id == this.id &&
          other.amountLiters == this.amountLiters &&
          other.totalCost == this.totalCost &&
          other.odometerReading == this.odometerReading &&
          other.logDate == this.logDate &&
          other.isTripConsumption == this.isTripConsumption &&
          other.tripId == this.tripId);
}

class FuelLogsCompanion extends UpdateCompanion<FuelLog> {
  final Value<int> id;
  final Value<double> amountLiters;
  final Value<double> totalCost;
  final Value<double?> odometerReading;
  final Value<DateTime> logDate;
  final Value<bool> isTripConsumption;
  final Value<int?> tripId;
  const FuelLogsCompanion({
    this.id = const Value.absent(),
    this.amountLiters = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.odometerReading = const Value.absent(),
    this.logDate = const Value.absent(),
    this.isTripConsumption = const Value.absent(),
    this.tripId = const Value.absent(),
  });
  FuelLogsCompanion.insert({
    this.id = const Value.absent(),
    required double amountLiters,
    required double totalCost,
    this.odometerReading = const Value.absent(),
    required DateTime logDate,
    this.isTripConsumption = const Value.absent(),
    this.tripId = const Value.absent(),
  }) : amountLiters = Value(amountLiters),
       totalCost = Value(totalCost),
       logDate = Value(logDate);
  static Insertable<FuelLog> custom({
    Expression<int>? id,
    Expression<double>? amountLiters,
    Expression<double>? totalCost,
    Expression<double>? odometerReading,
    Expression<DateTime>? logDate,
    Expression<bool>? isTripConsumption,
    Expression<int>? tripId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountLiters != null) 'amount_liters': amountLiters,
      if (totalCost != null) 'total_cost': totalCost,
      if (odometerReading != null) 'odometer_reading': odometerReading,
      if (logDate != null) 'log_date': logDate,
      if (isTripConsumption != null) 'is_trip_consumption': isTripConsumption,
      if (tripId != null) 'trip_id': tripId,
    });
  }

  FuelLogsCompanion copyWith({
    Value<int>? id,
    Value<double>? amountLiters,
    Value<double>? totalCost,
    Value<double?>? odometerReading,
    Value<DateTime>? logDate,
    Value<bool>? isTripConsumption,
    Value<int?>? tripId,
  }) {
    return FuelLogsCompanion(
      id: id ?? this.id,
      amountLiters: amountLiters ?? this.amountLiters,
      totalCost: totalCost ?? this.totalCost,
      odometerReading: odometerReading ?? this.odometerReading,
      logDate: logDate ?? this.logDate,
      isTripConsumption: isTripConsumption ?? this.isTripConsumption,
      tripId: tripId ?? this.tripId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountLiters.present) {
      map['amount_liters'] = Variable<double>(amountLiters.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (odometerReading.present) {
      map['odometer_reading'] = Variable<double>(odometerReading.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (isTripConsumption.present) {
      map['is_trip_consumption'] = Variable<bool>(isTripConsumption.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelLogsCompanion(')
          ..write('id: $id, ')
          ..write('amountLiters: $amountLiters, ')
          ..write('totalCost: $totalCost, ')
          ..write('odometerReading: $odometerReading, ')
          ..write('logDate: $logDate, ')
          ..write('isTripConsumption: $isTripConsumption, ')
          ..write('tripId: $tripId')
          ..write(')'))
        .toString();
  }
}

class $PassengersTable extends Passengers
    with TableInfo<$PassengersTable, Passenger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PassengersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNumberMeta = const VerificationMeta(
    'contactNumber',
  );
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
    'contact_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, contactNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'passengers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Passenger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_number')) {
      context.handle(
        _contactNumberMeta,
        contactNumber.isAcceptableOrUnknown(
          data['contact_number']!,
          _contactNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Passenger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Passenger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_number'],
      ),
    );
  }

  @override
  $PassengersTable createAlias(String alias) {
    return $PassengersTable(attachedDatabase, alias);
  }
}

class Passenger extends DataClass implements Insertable<Passenger> {
  final int id;
  final String name;
  final String? contactNumber;
  const Passenger({required this.id, required this.name, this.contactNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactNumber != null) {
      map['contact_number'] = Variable<String>(contactNumber);
    }
    return map;
  }

  PassengersCompanion toCompanion(bool nullToAbsent) {
    return PassengersCompanion(
      id: Value(id),
      name: Value(name),
      contactNumber: contactNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(contactNumber),
    );
  }

  factory Passenger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Passenger(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactNumber: serializer.fromJson<String?>(json['contactNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contactNumber': serializer.toJson<String?>(contactNumber),
    };
  }

  Passenger copyWith({
    int? id,
    String? name,
    Value<String?> contactNumber = const Value.absent(),
  }) => Passenger(
    id: id ?? this.id,
    name: name ?? this.name,
    contactNumber: contactNumber.present
        ? contactNumber.value
        : this.contactNumber,
  );
  Passenger copyWithCompanion(PassengersCompanion data) {
    return Passenger(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Passenger(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactNumber: $contactNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, contactNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Passenger &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactNumber == this.contactNumber);
}

class PassengersCompanion extends UpdateCompanion<Passenger> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contactNumber;
  const PassengersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactNumber = const Value.absent(),
  });
  PassengersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contactNumber = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Passenger> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contactNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactNumber != null) 'contact_number': contactNumber,
    });
  }

  PassengersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contactNumber,
  }) {
    return PassengersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactNumber.present) {
      map['contact_number'] = Variable<String>(contactNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PassengersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactNumber: $contactNumber')
          ..write(')'))
        .toString();
  }
}

class $TripPassengersTable extends TripPassengers
    with TableInfo<$TripPassengersTable, TripPassenger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPassengersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id)',
    ),
  );
  static const VerificationMeta _passengerIdMeta = const VerificationMeta(
    'passengerId',
  );
  @override
  late final GeneratedColumn<int> passengerId = GeneratedColumn<int>(
    'passenger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES passengers (id)',
    ),
  );
  static const VerificationMeta _costShareMeta = const VerificationMeta(
    'costShare',
  );
  @override
  late final GeneratedColumn<double> costShare = GeneratedColumn<double>(
    'cost_share',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tripId, passengerId, costShare];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_passengers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripPassenger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('passenger_id')) {
      context.handle(
        _passengerIdMeta,
        passengerId.isAcceptableOrUnknown(
          data['passenger_id']!,
          _passengerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passengerIdMeta);
    }
    if (data.containsKey('cost_share')) {
      context.handle(
        _costShareMeta,
        costShare.isAcceptableOrUnknown(data['cost_share']!, _costShareMeta),
      );
    } else if (isInserting) {
      context.missing(_costShareMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tripId, passengerId};
  @override
  TripPassenger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPassenger(
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      )!,
      passengerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passenger_id'],
      )!,
      costShare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_share'],
      )!,
    );
  }

  @override
  $TripPassengersTable createAlias(String alias) {
    return $TripPassengersTable(attachedDatabase, alias);
  }
}

class TripPassenger extends DataClass implements Insertable<TripPassenger> {
  final int tripId;
  final int passengerId;
  final double costShare;
  const TripPassenger({
    required this.tripId,
    required this.passengerId,
    required this.costShare,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trip_id'] = Variable<int>(tripId);
    map['passenger_id'] = Variable<int>(passengerId);
    map['cost_share'] = Variable<double>(costShare);
    return map;
  }

  TripPassengersCompanion toCompanion(bool nullToAbsent) {
    return TripPassengersCompanion(
      tripId: Value(tripId),
      passengerId: Value(passengerId),
      costShare: Value(costShare),
    );
  }

  factory TripPassenger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPassenger(
      tripId: serializer.fromJson<int>(json['tripId']),
      passengerId: serializer.fromJson<int>(json['passengerId']),
      costShare: serializer.fromJson<double>(json['costShare']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tripId': serializer.toJson<int>(tripId),
      'passengerId': serializer.toJson<int>(passengerId),
      'costShare': serializer.toJson<double>(costShare),
    };
  }

  TripPassenger copyWith({int? tripId, int? passengerId, double? costShare}) =>
      TripPassenger(
        tripId: tripId ?? this.tripId,
        passengerId: passengerId ?? this.passengerId,
        costShare: costShare ?? this.costShare,
      );
  TripPassenger copyWithCompanion(TripPassengersCompanion data) {
    return TripPassenger(
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      passengerId: data.passengerId.present
          ? data.passengerId.value
          : this.passengerId,
      costShare: data.costShare.present ? data.costShare.value : this.costShare,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPassenger(')
          ..write('tripId: $tripId, ')
          ..write('passengerId: $passengerId, ')
          ..write('costShare: $costShare')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tripId, passengerId, costShare);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPassenger &&
          other.tripId == this.tripId &&
          other.passengerId == this.passengerId &&
          other.costShare == this.costShare);
}

class TripPassengersCompanion extends UpdateCompanion<TripPassenger> {
  final Value<int> tripId;
  final Value<int> passengerId;
  final Value<double> costShare;
  final Value<int> rowid;
  const TripPassengersCompanion({
    this.tripId = const Value.absent(),
    this.passengerId = const Value.absent(),
    this.costShare = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripPassengersCompanion.insert({
    required int tripId,
    required int passengerId,
    required double costShare,
    this.rowid = const Value.absent(),
  }) : tripId = Value(tripId),
       passengerId = Value(passengerId),
       costShare = Value(costShare);
  static Insertable<TripPassenger> custom({
    Expression<int>? tripId,
    Expression<int>? passengerId,
    Expression<double>? costShare,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tripId != null) 'trip_id': tripId,
      if (passengerId != null) 'passenger_id': passengerId,
      if (costShare != null) 'cost_share': costShare,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripPassengersCompanion copyWith({
    Value<int>? tripId,
    Value<int>? passengerId,
    Value<double>? costShare,
    Value<int>? rowid,
  }) {
    return TripPassengersCompanion(
      tripId: tripId ?? this.tripId,
      passengerId: passengerId ?? this.passengerId,
      costShare: costShare ?? this.costShare,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (passengerId.present) {
      map['passenger_id'] = Variable<int>(passengerId.value);
    }
    if (costShare.present) {
      map['cost_share'] = Variable<double>(costShare.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripPassengersCompanion(')
          ..write('tripId: $tripId, ')
          ..write('passengerId: $passengerId, ')
          ..write('costShare: $costShare, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $FuelLogsTable fuelLogs = $FuelLogsTable(this);
  late final $PassengersTable passengers = $PassengersTable(this);
  late final $TripPassengersTable tripPassengers = $TripPassengersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    fuelLogs,
    passengers,
    tripPassengers,
  ];
}

typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      Value<int> id,
      required String startLocation,
      required String endLocation,
      required double distance,
      required DateTime tripDate,
      Value<String?> notes,
      Value<bool> isRoundTrip,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<int> id,
      Value<String> startLocation,
      Value<String> endLocation,
      Value<double> distance,
      Value<DateTime> tripDate,
      Value<String?> notes,
      Value<bool> isRoundTrip,
    });

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelLogsTable, List<FuelLog>> _fuelLogsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.fuelLogs,
    aliasName: $_aliasNameGenerator(db.trips.id, db.fuelLogs.tripId),
  );

  $$FuelLogsTableProcessedTableManager get fuelLogsRefs {
    final manager = $$FuelLogsTableTableManager(
      $_db,
      $_db.fuelLogs,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripPassengersTable, List<TripPassenger>>
  _tripPassengersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripPassengers,
    aliasName: $_aliasNameGenerator(db.trips.id, db.tripPassengers.tripId),
  );

  $$TripPassengersTableProcessedTableManager get tripPassengersRefs {
    final manager = $$TripPassengersTableTableManager(
      $_db,
      $_db.tripPassengers,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripPassengersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
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

  ColumnFilters<String> get startLocation => $composableBuilder(
    column: $table.startLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endLocation => $composableBuilder(
    column: $table.endLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tripDate => $composableBuilder(
    column: $table.tripDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRoundTrip => $composableBuilder(
    column: $table.isRoundTrip,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fuelLogsRefs(
    Expression<bool> Function($$FuelLogsTableFilterComposer f) f,
  ) {
    final $$FuelLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelLogs,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelLogsTableFilterComposer(
            $db: $db,
            $table: $db.fuelLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripPassengersRefs(
    Expression<bool> Function($$TripPassengersTableFilterComposer f) f,
  ) {
    final $$TripPassengersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPassengers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPassengersTableFilterComposer(
            $db: $db,
            $table: $db.tripPassengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
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

  ColumnOrderings<String> get startLocation => $composableBuilder(
    column: $table.startLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endLocation => $composableBuilder(
    column: $table.endLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tripDate => $composableBuilder(
    column: $table.tripDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRoundTrip => $composableBuilder(
    column: $table.isRoundTrip,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startLocation => $composableBuilder(
    column: $table.startLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endLocation => $composableBuilder(
    column: $table.endLocation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<DateTime> get tripDate =>
      $composableBuilder(column: $table.tripDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isRoundTrip => $composableBuilder(
    column: $table.isRoundTrip,
    builder: (column) => column,
  );

  Expression<T> fuelLogsRefs<T extends Object>(
    Expression<T> Function($$FuelLogsTableAnnotationComposer a) f,
  ) {
    final $$FuelLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelLogs,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripPassengersRefs<T extends Object>(
    Expression<T> Function($$TripPassengersTableAnnotationComposer a) f,
  ) {
    final $$TripPassengersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPassengers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPassengersTableAnnotationComposer(
            $db: $db,
            $table: $db.tripPassengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, $$TripsTableReferences),
          Trip,
          PrefetchHooks Function({bool fuelLogsRefs, bool tripPassengersRefs})
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startLocation = const Value.absent(),
                Value<String> endLocation = const Value.absent(),
                Value<double> distance = const Value.absent(),
                Value<DateTime> tripDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isRoundTrip = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                startLocation: startLocation,
                endLocation: endLocation,
                distance: distance,
                tripDate: tripDate,
                notes: notes,
                isRoundTrip: isRoundTrip,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startLocation,
                required String endLocation,
                required double distance,
                required DateTime tripDate,
                Value<String?> notes = const Value.absent(),
                Value<bool> isRoundTrip = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                startLocation: startLocation,
                endLocation: endLocation,
                distance: distance,
                tripDate: tripDate,
                notes: notes,
                isRoundTrip: isRoundTrip,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({fuelLogsRefs = false, tripPassengersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fuelLogsRefs) db.fuelLogs,
                    if (tripPassengersRefs) db.tripPassengers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fuelLogsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, FuelLog>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._fuelLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).fuelLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripPassengersRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          TripPassenger
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripPassengersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripPassengersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
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

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, $$TripsTableReferences),
      Trip,
      PrefetchHooks Function({bool fuelLogsRefs, bool tripPassengersRefs})
    >;
typedef $$FuelLogsTableCreateCompanionBuilder =
    FuelLogsCompanion Function({
      Value<int> id,
      required double amountLiters,
      required double totalCost,
      Value<double?> odometerReading,
      required DateTime logDate,
      Value<bool> isTripConsumption,
      Value<int?> tripId,
    });
typedef $$FuelLogsTableUpdateCompanionBuilder =
    FuelLogsCompanion Function({
      Value<int> id,
      Value<double> amountLiters,
      Value<double> totalCost,
      Value<double?> odometerReading,
      Value<DateTime> logDate,
      Value<bool> isTripConsumption,
      Value<int?> tripId,
    });

final class $$FuelLogsTableReferences
    extends BaseReferences<_$AppDatabase, $FuelLogsTable, FuelLog> {
  $$FuelLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.fuelLogs.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager? get tripId {
    final $_column = $_itemColumn<int>('trip_id');
    if ($_column == null) return null;
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FuelLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FuelLogsTable> {
  $$FuelLogsTableFilterComposer({
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

  ColumnFilters<double> get amountLiters => $composableBuilder(
    column: $table.amountLiters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTripConsumption => $composableBuilder(
    column: $table.isTripConsumption,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelLogsTable> {
  $$FuelLogsTableOrderingComposer({
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

  ColumnOrderings<double> get amountLiters => $composableBuilder(
    column: $table.amountLiters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTripConsumption => $composableBuilder(
    column: $table.isTripConsumption,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelLogsTable> {
  $$FuelLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amountLiters => $composableBuilder(
    column: $table.amountLiters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<double> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<bool> get isTripConsumption => $composableBuilder(
    column: $table.isTripConsumption,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelLogsTable,
          FuelLog,
          $$FuelLogsTableFilterComposer,
          $$FuelLogsTableOrderingComposer,
          $$FuelLogsTableAnnotationComposer,
          $$FuelLogsTableCreateCompanionBuilder,
          $$FuelLogsTableUpdateCompanionBuilder,
          (FuelLog, $$FuelLogsTableReferences),
          FuelLog,
          PrefetchHooks Function({bool tripId})
        > {
  $$FuelLogsTableTableManager(_$AppDatabase db, $FuelLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amountLiters = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<double?> odometerReading = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<bool> isTripConsumption = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
              }) => FuelLogsCompanion(
                id: id,
                amountLiters: amountLiters,
                totalCost: totalCost,
                odometerReading: odometerReading,
                logDate: logDate,
                isTripConsumption: isTripConsumption,
                tripId: tripId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amountLiters,
                required double totalCost,
                Value<double?> odometerReading = const Value.absent(),
                required DateTime logDate,
                Value<bool> isTripConsumption = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
              }) => FuelLogsCompanion.insert(
                id: id,
                amountLiters: amountLiters,
                totalCost: totalCost,
                odometerReading: odometerReading,
                logDate: logDate,
                isTripConsumption: isTripConsumption,
                tripId: tripId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FuelLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
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
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$FuelLogsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$FuelLogsTableReferences
                                    ._tripIdTable(db)
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

typedef $$FuelLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelLogsTable,
      FuelLog,
      $$FuelLogsTableFilterComposer,
      $$FuelLogsTableOrderingComposer,
      $$FuelLogsTableAnnotationComposer,
      $$FuelLogsTableCreateCompanionBuilder,
      $$FuelLogsTableUpdateCompanionBuilder,
      (FuelLog, $$FuelLogsTableReferences),
      FuelLog,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$PassengersTableCreateCompanionBuilder =
    PassengersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> contactNumber,
    });
typedef $$PassengersTableUpdateCompanionBuilder =
    PassengersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> contactNumber,
    });

final class $$PassengersTableReferences
    extends BaseReferences<_$AppDatabase, $PassengersTable, Passenger> {
  $$PassengersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripPassengersTable, List<TripPassenger>>
  _tripPassengersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripPassengers,
    aliasName: $_aliasNameGenerator(
      db.passengers.id,
      db.tripPassengers.passengerId,
    ),
  );

  $$TripPassengersTableProcessedTableManager get tripPassengersRefs {
    final manager = $$TripPassengersTableTableManager(
      $_db,
      $_db.tripPassengers,
    ).filter((f) => f.passengerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripPassengersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PassengersTableFilterComposer
    extends Composer<_$AppDatabase, $PassengersTable> {
  $$PassengersTableFilterComposer({
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

  ColumnFilters<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripPassengersRefs(
    Expression<bool> Function($$TripPassengersTableFilterComposer f) f,
  ) {
    final $$TripPassengersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPassengers,
      getReferencedColumn: (t) => t.passengerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPassengersTableFilterComposer(
            $db: $db,
            $table: $db.tripPassengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PassengersTableOrderingComposer
    extends Composer<_$AppDatabase, $PassengersTable> {
  $$PassengersTableOrderingComposer({
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

  ColumnOrderings<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PassengersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PassengersTable> {
  $$PassengersTableAnnotationComposer({
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

  GeneratedColumn<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => column,
  );

  Expression<T> tripPassengersRefs<T extends Object>(
    Expression<T> Function($$TripPassengersTableAnnotationComposer a) f,
  ) {
    final $$TripPassengersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripPassengers,
      getReferencedColumn: (t) => t.passengerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripPassengersTableAnnotationComposer(
            $db: $db,
            $table: $db.tripPassengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PassengersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PassengersTable,
          Passenger,
          $$PassengersTableFilterComposer,
          $$PassengersTableOrderingComposer,
          $$PassengersTableAnnotationComposer,
          $$PassengersTableCreateCompanionBuilder,
          $$PassengersTableUpdateCompanionBuilder,
          (Passenger, $$PassengersTableReferences),
          Passenger,
          PrefetchHooks Function({bool tripPassengersRefs})
        > {
  $$PassengersTableTableManager(_$AppDatabase db, $PassengersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PassengersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PassengersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PassengersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactNumber = const Value.absent(),
              }) => PassengersCompanion(
                id: id,
                name: name,
                contactNumber: contactNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contactNumber = const Value.absent(),
              }) => PassengersCompanion.insert(
                id: id,
                name: name,
                contactNumber: contactNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PassengersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripPassengersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tripPassengersRefs) db.tripPassengers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tripPassengersRefs)
                    await $_getPrefetchedData<
                      Passenger,
                      $PassengersTable,
                      TripPassenger
                    >(
                      currentTable: table,
                      referencedTable: $$PassengersTableReferences
                          ._tripPassengersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PassengersTableReferences(
                            db,
                            table,
                            p0,
                          ).tripPassengersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.passengerId == item.id,
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

typedef $$PassengersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PassengersTable,
      Passenger,
      $$PassengersTableFilterComposer,
      $$PassengersTableOrderingComposer,
      $$PassengersTableAnnotationComposer,
      $$PassengersTableCreateCompanionBuilder,
      $$PassengersTableUpdateCompanionBuilder,
      (Passenger, $$PassengersTableReferences),
      Passenger,
      PrefetchHooks Function({bool tripPassengersRefs})
    >;
typedef $$TripPassengersTableCreateCompanionBuilder =
    TripPassengersCompanion Function({
      required int tripId,
      required int passengerId,
      required double costShare,
      Value<int> rowid,
    });
typedef $$TripPassengersTableUpdateCompanionBuilder =
    TripPassengersCompanion Function({
      Value<int> tripId,
      Value<int> passengerId,
      Value<double> costShare,
      Value<int> rowid,
    });

final class $$TripPassengersTableReferences
    extends BaseReferences<_$AppDatabase, $TripPassengersTable, TripPassenger> {
  $$TripPassengersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.tripPassengers.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<int>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PassengersTable _passengerIdTable(_$AppDatabase db) =>
      db.passengers.createAlias(
        $_aliasNameGenerator(db.tripPassengers.passengerId, db.passengers.id),
      );

  $$PassengersTableProcessedTableManager get passengerId {
    final $_column = $_itemColumn<int>('passenger_id')!;

    final manager = $$PassengersTableTableManager(
      $_db,
      $_db.passengers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_passengerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripPassengersTableFilterComposer
    extends Composer<_$AppDatabase, $TripPassengersTable> {
  $$TripPassengersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get costShare => $composableBuilder(
    column: $table.costShare,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PassengersTableFilterComposer get passengerId {
    final $$PassengersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.passengerId,
      referencedTable: $db.passengers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PassengersTableFilterComposer(
            $db: $db,
            $table: $db.passengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPassengersTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPassengersTable> {
  $$TripPassengersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get costShare => $composableBuilder(
    column: $table.costShare,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PassengersTableOrderingComposer get passengerId {
    final $$PassengersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.passengerId,
      referencedTable: $db.passengers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PassengersTableOrderingComposer(
            $db: $db,
            $table: $db.passengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPassengersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPassengersTable> {
  $$TripPassengersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get costShare =>
      $composableBuilder(column: $table.costShare, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PassengersTableAnnotationComposer get passengerId {
    final $$PassengersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.passengerId,
      referencedTable: $db.passengers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PassengersTableAnnotationComposer(
            $db: $db,
            $table: $db.passengers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripPassengersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripPassengersTable,
          TripPassenger,
          $$TripPassengersTableFilterComposer,
          $$TripPassengersTableOrderingComposer,
          $$TripPassengersTableAnnotationComposer,
          $$TripPassengersTableCreateCompanionBuilder,
          $$TripPassengersTableUpdateCompanionBuilder,
          (TripPassenger, $$TripPassengersTableReferences),
          TripPassenger,
          PrefetchHooks Function({bool tripId, bool passengerId})
        > {
  $$TripPassengersTableTableManager(
    _$AppDatabase db,
    $TripPassengersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPassengersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPassengersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPassengersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> tripId = const Value.absent(),
                Value<int> passengerId = const Value.absent(),
                Value<double> costShare = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPassengersCompanion(
                tripId: tripId,
                passengerId: passengerId,
                costShare: costShare,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int tripId,
                required int passengerId,
                required double costShare,
                Value<int> rowid = const Value.absent(),
              }) => TripPassengersCompanion.insert(
                tripId: tripId,
                passengerId: passengerId,
                costShare: costShare,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripPassengersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false, passengerId = false}) {
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
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$TripPassengersTableReferences
                                    ._tripIdTable(db),
                                referencedColumn:
                                    $$TripPassengersTableReferences
                                        ._tripIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (passengerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.passengerId,
                                referencedTable: $$TripPassengersTableReferences
                                    ._passengerIdTable(db),
                                referencedColumn:
                                    $$TripPassengersTableReferences
                                        ._passengerIdTable(db)
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

typedef $$TripPassengersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripPassengersTable,
      TripPassenger,
      $$TripPassengersTableFilterComposer,
      $$TripPassengersTableOrderingComposer,
      $$TripPassengersTableAnnotationComposer,
      $$TripPassengersTableCreateCompanionBuilder,
      $$TripPassengersTableUpdateCompanionBuilder,
      (TripPassenger, $$TripPassengersTableReferences),
      TripPassenger,
      PrefetchHooks Function({bool tripId, bool passengerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$FuelLogsTableTableManager get fuelLogs =>
      $$FuelLogsTableTableManager(_db, _db.fuelLogs);
  $$PassengersTableTableManager get passengers =>
      $$PassengersTableTableManager(_db, _db.passengers);
  $$TripPassengersTableTableManager get tripPassengers =>
      $$TripPassengersTableTableManager(_db, _db.tripPassengers);
}
