import 'package:cloud_firestore/cloud_firestore.dart';

class FuelLog {
  final String id;
  final double amountLiters;
  final double totalCost;
  final double? odometerReading;
  final DateTime logDate;
  final bool isTripConsumption;
  final String? tripId;

  FuelLog({
    required this.id,
    required this.amountLiters,
    required this.totalCost,
    this.odometerReading,
    required this.logDate,
    required this.isTripConsumption,
    this.tripId,
  });

  factory FuelLog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FuelLog(
      id: doc.id,
      amountLiters: (data['amountLiters'] ?? 0.0).toDouble(),
      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
      odometerReading: (data['odometerReading'])?.toDouble(),
      logDate: (data['logDate'] as Timestamp? ?? Timestamp.now()).toDate(),
      isTripConsumption: data['isTripConsumption'] ?? false,
      tripId: data['tripId'],
    );
  }
}