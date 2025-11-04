// lib/data/database.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// --- TABLE DEFINITIONS ---
// class Vehicles extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text().withLength(min: 1, max: 50)();
//   RealColumn get defaultMileage => real()(); // in km/l
// }

class FuelLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amountLiters => real()();
  RealColumn get totalCost => real()();
  RealColumn get odometerReading => real().nullable()();
  DateTimeColumn get logDate => dateTime()();
  BoolColumn get isTripConsumption => boolean().withDefault(const Constant(false))();
  IntColumn get tripId => integer().nullable().references(Trips, #id)();
}

class Trips extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startLocation => text().withLength(min: 1, max: 100)();
  TextColumn get endLocation => text().withLength(min: 1, max: 100)();
  RealColumn get distance => real()();
  DateTimeColumn get tripDate => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isRoundTrip => boolean().withDefault(const Constant(false))();
   RealColumn get otherCosts => real().withDefault(const Constant(0.0))();
}

class Passengers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get contactNumber => text().nullable()();
}

class TripPassengers extends Table {
  IntColumn get tripId => integer().references(Trips, #id)();
  IntColumn get passengerId => integer().references(Passengers, #id)();
  RealColumn get costShare => real()();
  @override
  Set<Column> get primaryKey => {tripId, passengerId};
}

// --- DATABASE CLASS DEFINITION ---
@DriftDatabase(tables: [FuelLogs, Trips, Passengers, TripPassengers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- Core Methods ---
  Future<int> insertFuelLog(FuelLogsCompanion log) => into(fuelLogs).insert(log);
  Stream<List<FuelLog>> watchAllFuelLogs() => (select(fuelLogs)..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)])).watch();
  Stream<List<Passenger>> watchAllPassengers() => select(passengers).watch();
  Future<int> insertPassenger(PassengersCompanion passenger) => into(passengers).insert(passenger);
  Future<int> deletePassenger(int id) => (delete(passengers)..where((tbl) => tbl.id.equals(id))).go();
  Stream<List<Trip>> watchAllTrips() => (select(trips)..orderBy([(t) => OrderingTerm(expression: t.tripDate, mode: OrderingMode.desc)])).watch();
  Future<int> deleteFuelLog(int logId) => (delete(fuelLogs)..where((tbl) => tbl.id.equals(logId))).go();
  Future<bool> updateTrip(TripsCompanion trip) => update(trips).replace(trip);
  Future<FuelLog?> getFuelLogForTrip(int tripId) => (select(fuelLogs)..where((tbl) => tbl.tripId.equals(tripId) & tbl.isTripConsumption.equals(true))).getSingleOrNull();

  Future<List<Passenger>> getPassengersForTrip(int tripId) {
    final query = select(tripPassengers).join([
      innerJoin(passengers, passengers.id.equalsExp(tripPassengers.passengerId))
    ])..where(tripPassengers.tripId.equals(tripId));
    return query.map((row) => row.readTable(passengers)).get();
  }

  Future<int> createTripWithPassengers(TripsCompanion trip, List<Passenger> passengers, double costPerPassenger) {
    return transaction(() async {
      final tripId = await into(this.trips).insert(trip);
      for (final passenger in passengers) {
        await into(tripPassengers).insert(TripPassengersCompanion(
          tripId: Value(tripId),
          passengerId: Value(passenger.id),
          costShare: Value(costPerPassenger),
        ));
      }
      return tripId;
    });
  }
  Future<void> deleteTripAndAssociations(int tripId) {
    return transaction(() async {
      await (delete(tripPassengers)..where((tbl) => tbl.tripId.equals(tripId))).go();
      await (delete(fuelLogs)..where((tbl) => tbl.tripId.equals(tripId))).go();
      await (delete(trips)..where((tbl) => tbl.id.equals(tripId))).go();
    });
  }
}


// --- CONNECTION FUNCTION ---
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}