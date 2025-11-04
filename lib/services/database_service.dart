import 'package:fuel_split/services/exports.dart';
import 'package:drift/drift.dart' as drift;

class DatabaseService {
  static Future<void> createTripWithLog({
    required String startLocation,
    required String endLocation,
    required double distance,
    required bool isRoundTrip,
    required String notes,
    required List<Passenger> passengers,
    required double totalFuelCost,
    required double totalLitersUsed,
    required double otherCosts,
  }) async {
    final newTrip = TripsCompanion(
      startLocation: drift.Value(startLocation),
      endLocation: drift.Value(endLocation),
      distance: drift.Value(distance),
      isRoundTrip: drift.Value(isRoundTrip),
      notes: drift.Value(notes),
      otherCosts: drift.Value(otherCosts),
      tripDate: drift.Value(DateTime.now()),
    );

    final double totalTripCost = totalFuelCost + otherCosts;
    final double costPerPassenger = passengers.isNotEmpty ? totalTripCost / passengers.length : 0.0;

    final tripId = await database.createTripWithPassengers(newTrip, passengers, costPerPassenger);

    final consumptionLog = FuelLogsCompanion(
      amountLiters: drift.Value(totalLitersUsed),
      totalCost: drift.Value(totalFuelCost),
      logDate: drift.Value(DateTime.now()),
      isTripConsumption: const drift.Value(true),
      tripId: drift.Value(tripId),
    );
    await database.insertFuelLog(consumptionLog);
  }
  static Future<void> deleteFuelLog(int logId) {
    return database.deleteFuelLog(logId);
  }

  static Future<void> deleteTrip(int tripId) {
    return database.deleteTripAndAssociations(tripId);
  }

  static Future<bool> updateTrip(int tripId, {
    required String startLocation,
    required String endLocation,
    required double distance,
    required bool isRoundTrip,
    required String notes,
    required double otherCosts,
  }) {
    final tripCompanion = TripsCompanion(
      id: drift.Value(tripId),
      startLocation: drift.Value(startLocation),
      endLocation: drift.Value(endLocation),
      distance: drift.Value(distance),
      isRoundTrip: drift.Value(isRoundTrip),
      notes: drift.Value(notes),
      otherCosts: drift.Value(otherCosts),
    );
    return database.updateTrip(tripCompanion);
  }
  static Future<TripCardBundle> getTripCardDetails(int tripId) async {
    final results = await Future.wait([
      database.getPassengersForTrip(tripId),
      database.getFuelLogForTrip(tripId),
    ]);

    final passengers = results[0] as List<Passenger>;
    final fuelLog = results[1] as FuelLog?;

    return TripCardBundle(passengers: passengers, fuelLog: fuelLog);

  }

}