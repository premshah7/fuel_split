import 'package:cloud_firestore/cloud_firestore.dart';

class FuelLog {
  final String id;
  final String tripId;
  final double amountLiters;
  final double totalCost;
  final DateTime date;
  final bool isTripConsumption;
  final double? odometerReading;
  final double tripsCost;

  FuelLog({
    required this.id,
    required this.tripId,
    required this.amountLiters,
    required this.totalCost,
    required this.date,
    this.isTripConsumption = true,
    this.odometerReading,
    this.tripsCost = 0.0,
  });

  factory FuelLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FuelLog(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      amountLiters: (data['amountLiters'] ?? 0.0).toDouble(),
      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? (data['logDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTripConsumption: data['isTripConsumption'] ?? true,
      odometerReading: data['odometerReading'] != null ? (data['odometerReading'] as num).toDouble() : null,
      tripsCost: (data['tripsCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'amountLiters': amountLiters,
      'totalCost': totalCost,
      'date': Timestamp.fromDate(date),
      'isTripConsumption': isTripConsumption,
      'odometerReading': odometerReading,
      'tripsCost': tripsCost,
    };
  }
}
