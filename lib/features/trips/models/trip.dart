import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String startLocation;
  final String endLocation;
  final double distance;
  final DateTime tripDate;
  final bool isRoundTrip;
  final String? notes;
  final double otherCosts;
  final int passengerCount;
  final double totalCost;

  Trip({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.tripDate,
    required this.isRoundTrip,
    this.notes,
    this.otherCosts = 0.0,
    this.passengerCount = 0,
    this.totalCost = 0.0,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      startLocation: data['startLocation'] ?? '',
      endLocation: data['endLocation'] ?? '',
      distance: (data['distance'] ?? 0.0).toDouble(),
      tripDate: (data['tripDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRoundTrip: data['isRoundTrip'] ?? false,
      notes: data['notes'],
      otherCosts: (data['otherCosts'] ?? 0.0).toDouble(),
      passengerCount: data['passengerCount'] ?? 0,
      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startLocation': startLocation,
      'endLocation': endLocation,
      'distance': distance,
      'tripDate': Timestamp.fromDate(tripDate),
      'isRoundTrip': isRoundTrip,
      'notes': notes,
      'otherCosts': otherCosts,
      'passengerCount': passengerCount,
      'totalCost': totalCost,
    };
  }
}
