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
    required this.otherCosts,
    required this.passengerCount,
    required this.totalCost,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    // Cast the document's data to a Map.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Trip(
      id: doc.id,
      startLocation: data['startLocation'] ?? 'Unknown Start',
      endLocation: data['endLocation'] ?? 'Unknown End',
      distance: (data['distance'] ?? 0.0).toDouble(),
      tripDate: (data['tripDate'] as Timestamp? ?? Timestamp.now()).toDate(),
      isRoundTrip: data['isRoundTrip'] ?? false,
      notes: data['notes'],
      otherCosts: (data['otherCosts'] ?? 0.0).toDouble(),
      passengerCount: data['passengerCount'] ?? 0,
      totalCost: (data['totalCost'] ?? 0.0).toDouble(),
    );
  }
}