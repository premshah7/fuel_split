import 'package:fuel_split/services/exports.dart';

class TripCardBundle {
  final List<Passenger> passengers;
  final FuelLog? fuelLog;

  TripCardBundle({required this.passengers, this.fuelLog});
}