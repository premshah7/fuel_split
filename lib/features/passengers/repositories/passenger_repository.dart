import 'package:cloud_firestore/cloud_firestore.dart';
// Removed firebase_auth.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/firebase_utils.dart'; // We'll create this helper
import '../models/passenger.dart';
import '../../auth/repositories/auth_repository.dart';

final passengerRepositoryProvider = Provider<PassengerRepository?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  return PassengerRepository(FirebaseFirestore.instance, user.uid);
});

final allPassengersProvider = StreamProvider<List<Passenger>>((ref) {
  final repo = ref.watch(passengerRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAllPassengers();
});

class PassengerRepository {
  final FirebaseFirestore _db;
  final String _uid;

  PassengerRepository(this._db, this._uid);

  CollectionReference get _passengersRef => _db.collection('users').doc(_uid).collection('passengers');

  Stream<List<Passenger>> watchAllPassengers() {
    return _passengersRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Passenger.fromFirestore(doc)).toList();
    });
  }

  Future<void> addPassenger({required String name, String? contactNumber}) async {
    await _passengersRef.add({
      'name': FirebaseUtils.sanitizeString(name, maxLength: 100),
      'contactNumber': FirebaseUtils.sanitizeString(contactNumber, maxLength: 50),
    });
  }

  Future<void> updatePassenger({required String id, required String name, String? contactNumber}) async {
    await _passengersRef.doc(id).update({
      'name': FirebaseUtils.sanitizeString(name, maxLength: 100),
      'contactNumber': FirebaseUtils.sanitizeString(contactNumber, maxLength: 50),
    });
  }

  Future<void> deletePassenger(String id) async {
    await _passengersRef.doc(id).delete();
  }
}
