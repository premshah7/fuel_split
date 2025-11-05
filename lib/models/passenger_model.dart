import 'package:cloud_firestore/cloud_firestore.dart';

class Passenger {
  final String id;
  final String name;
  final String? contactNumber;

  Passenger({required this.id, required this.name, this.contactNumber});

  factory Passenger.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Passenger(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      contactNumber: data['contactNumber'],
    );
  }
}