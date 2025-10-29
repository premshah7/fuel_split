import 'package:fuel_split/services/exports.dart';

class TripDetailsBundle {
  final Trip trip;
  final List<Passenger> passengers;
  final FuelLog? fuelLog;

  TripDetailsBundle({required this.trip, required this.passengers, this.fuelLog});
}