import 'package:cloud_firestore/cloud_firestore.dart';

class TripPassengerDetail {
  final String id;
  final String name;
  final double costShare;
  final bool isPaid;

  TripPassengerDetail({
    required this.id,
    required this.name,
    required this.costShare,
    required this.isPaid,
  });

  factory TripPassengerDetail.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripPassengerDetail(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      costShare: (data['costShare'] ?? 0.0).toDouble(),
      isPaid: data['isPaid'] ?? false,
    );
  }
}