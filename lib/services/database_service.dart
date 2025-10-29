import 'package:fuel_split/services/exports.dart';
import 'package:drift/drift.dart' as drift;

class DatabaseService {
  // In lib/services/database_service.dart

  static Future<void> createTripWithLog({
    required String startLocation,
    required String endLocation,
    required double distance,
    required bool isRoundTrip,
    required String notes,
    required List<Passenger> passengers,
    required double totalFuelCost,
    required double totalLitersUsed,
  }) async {
    // print("DEBUG: DatabaseService.createTripWithLog called.");
    try {
      final newTrip = TripsCompanion(
        startLocation: drift.Value(startLocation),
        endLocation: drift.Value(endLocation),
        distance: drift.Value(distance),
        isRoundTrip: drift.Value(isRoundTrip),
        notes: drift.Value(notes),
        tripDate: drift.Value(DateTime.now()),
      );

      final double costPerPassenger = passengers.isNotEmpty ? totalFuelCost / passengers.length : 0.0;
      // print("DEBUG: Calling database.createTripWithPassengers...");

      // This is a critical point of failure. The try/catch will expose any errors.
      final tripId = await database.createTripWithPassengers(newTrip, passengers, costPerPassenger);
      // print("DEBUG: Trip created with ID: $tripId. Now creating fuel log...");

      final consumptionLog = FuelLogsCompanion(
        amountLiters: drift.Value(totalLitersUsed),
        totalCost: drift.Value(totalFuelCost),
        logDate: drift.Value(DateTime.now()),
        isTripConsumption: const drift.Value(true),
        tripId: drift.Value(tripId),
      );
      await database.insertFuelLog(consumptionLog);
      // print("DEBUG: Fuel log created. Save successful.");

    } catch (e, s) {
      // THIS WILL CATCH ANY SILENT DATABASE ERROR
      // print("DEBUG: CRITICAL ERROR in DatabaseService: $e");
      // print(s); // Print the full stack trace
      // Re-throw the error so the UI layer can catch it if it wants to.
      rethrow;
    }
  }
}