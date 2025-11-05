import 'package:fuel_split/models/trip_passenger_model.dart';
import 'package:fuel_split/models/unsettled_debt_model.dart';
import 'package:fuel_split/services/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // --- Trips ---
  Future<void> createTripWithLog({
    required String startLocation,
    required String endLocation,
    required double distance,
    required bool isRoundTrip,
    required String notes,
    required List<Passenger> passengers,
    required double totalFuelCost,
    required double totalLitersUsed,
    required double otherCosts,
  }) async {
    if (_uid == null) return;

    final double totalTripCost = totalFuelCost + otherCosts;
    final double costPerPassenger = passengers.isNotEmpty ? totalTripCost / passengers.length : 0.0;

    WriteBatch batch = _db.batch();

    // 1. Create the main trip document
    DocumentReference tripDocRef = _db.collection('users').doc(_uid).collection('trips').doc();
    batch.set(tripDocRef, {
      'startLocation': startLocation,
      'endLocation': endLocation,
      'distance': distance,
      'isRoundTrip': isRoundTrip,
      'notes': notes,
      'otherCosts': otherCosts,
      'tripDate': FieldValue.serverTimestamp(),
      'passengerCount': passengers.length,
      'totalCost': totalTripCost,
    });

    // 2. Create the associated fuel log document
    DocumentReference fuelLogDocRef = _db.collection('users').doc(_uid).collection('fuel_logs').doc();
    batch.set(fuelLogDocRef, {
      'amountLiters': totalLitersUsed,
      'totalCost': totalFuelCost,
      'logDate': FieldValue.serverTimestamp(),
      'isTripConsumption': true,
      'tripId': tripDocRef.id,
    });

    // 3. For each passenger, create a document in the trip's sub-collection
    for (final passenger in passengers) {
      DocumentReference passengerDocRef = tripDocRef.collection('passengers').doc(passenger.id);
      batch.set(passengerDocRef, {
        'passengerId': passenger.id,
        'name': passenger.name,
        'costShare': costPerPassenger,
        'isPaid': false,
        'ownerId': _uid,
      });
    }

    // 4. Commit all operations at once
    await batch.commit();
  }

  Stream<List<Trip>> watchAllTrips() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('trips')
        .orderBy('tripDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }
  Future<void> updateTrip(String tripId, Map<String, Object> data) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('trips').doc(tripId).update(data);
  }

  Future<void> deleteTrip(String tripId) {
    if (_uid == null) throw Exception("User not logged in");
    // For full cleanup, a Cloud Function is better. This is the client-side best effort.
    final WriteBatch batch = _db.batch();
    final tripRef = _db.collection('users').doc(_uid).collection('trips').doc(tripId);
    batch.delete(tripRef);
    // You could also add logic here to delete the associated fuel log.
    return batch.commit();
  }

  // --- PASSENGERS ---
  Future<DocumentReference> addPassenger({required String name, String? contactNumber}) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('passengers').add({
      'name': name,
      'contactNumber': contactNumber,
    });
  }

  Stream<List<Passenger>> watchAllPassengers() {
    if (_uid == null) return Stream.value([]);
    return _db.collection('users').doc(_uid).collection('passengers').snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Passenger.fromFirestore(doc)).toList());
  }

  Future<void> updatePassenger(String passengerId, {required String name, String? contactNumber}) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('passengers').doc(passengerId).update({
      'name': name,
      'contactNumber': contactNumber,
    });
  }

  Future<void> updatePassengerPaymentStatus({
    required String tripId,
    required String passengerDocId,
    required bool newStatus,
  }) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('trips').doc(tripId).collection('passengers').doc(passengerDocId).update({
      'isPaid': newStatus,
    });
  }

  Future<void> deletePassenger(String passengerId) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('passengers').doc(passengerId).delete();
  }

  // --- FUEL LOGS ---
  Future<void> addManualFuelLog({required double amountLiters, required double totalCost, double? odometer}) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('fuel_logs').add({
      'amountLiters': amountLiters,
      'totalCost': totalCost,
      'odometerReading': odometer,
      'logDate': FieldValue.serverTimestamp(),
      'isTripConsumption': false,
    });
  }

  Stream<List<FuelLog>> watchAllFuelLogs() {
    if (_uid == null) return Stream.value([]);
    return _db.collection('users').doc(_uid).collection('fuel_logs').orderBy('logDate', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FuelLog.fromFirestore(doc)).toList());
  }

  Future<void> deleteFuelLog(String logId) {
    if (_uid == null) throw Exception("User not logged in");
    return _db.collection('users').doc(_uid).collection('fuel_logs').doc(logId).delete();
  }

  // --- TRIP DETAILS (Reading Sub-collections) ---
  Stream<List<TripPassengerDetail>> watchPassengersForTrip(String tripId) {
    if (_uid == null) return Stream.value([]);
    return _db.collection('users').doc(_uid).collection('trips').doc(tripId).collection('passengers').snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TripPassengerDetail.fromFirestore(doc)).toList());
  }

  Stream<List<UnsettledDebt>> watchAllUnsettledDebts() {
    if (_uid == null) return Stream.value([]);

    var query = _db
        .collectionGroup('passengers')
        .where('ownerId', isEqualTo: _uid)
        .where('isPaid', isEqualTo: false);

    return query.snapshots().asyncMap((snapshot) async {
      final debts = <UnsettledDebt>[];
      for (final doc in snapshot.docs) {
        // For each unpaid passenger document, we need to get its parent trip document.
        final tripRef = doc.reference.parent.parent;
        if (tripRef != null) {
          final tripDoc = await tripRef.get();
          if (tripDoc.exists) {
            final tripData = tripDoc.data() as Map<String, dynamic>;
            final passengerData = doc.data() as Map<String, dynamic>;

            debts.add(UnsettledDebt(
              tripId: tripDoc.id,
              tripName: '${tripData['startLocation']} → ${tripData['endLocation']}',
              tripDate: (tripData['tripDate'] as Timestamp).toDate(),
              passengerName: passengerData['name'],
              amountOwed: (passengerData['costShare'] ?? 0.0).toDouble(),
            ));
          }
        }
      }
      debts.sort((a, b) => b.tripDate.compareTo(a.tripDate));
      return debts;
    });
  }


}