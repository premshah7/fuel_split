import 'package:cloud_firestore/cloud_firestore.dart';

class Passenger {
  final String id;
  final String name;
  final String? contactNumber;

  Passenger({required this.id, required this.name, this.contactNumber});

  factory Passenger.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Passenger(
      id: doc.id,
      name: data['name'] ?? '',
      contactNumber: data['contactNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactNumber': contactNumber,
    };
  }
}

class TripPassenger {
  final String id;
  final String name;
  final String? contactNumber;
  final double costShare;
  final bool isPaid;

  TripPassenger({
    required this.id,
    required this.name,
    this.contactNumber,
    required this.costShare,
    required this.isPaid,
  });

  factory TripPassenger.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TripPassenger(
      id: doc.id,
      name: data['name'] ?? '',
      contactNumber: data['contactNumber'],
      costShare: (data['costShare'] ?? 0.0).toDouble(),
      isPaid: data['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactNumber': contactNumber,
      'costShare': costShare,
      'isPaid': isPaid,
    };
  }
}
