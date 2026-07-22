import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/firebase_utils.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/trip.dart';
import '../models/fuel_log.dart';
import '../../passengers/models/passenger.dart';

final tripRepositoryProvider = Provider<TripRepository?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  return TripRepository(FirebaseFirestore.instance, user.uid);
});

final allTripsProvider = StreamProvider<List<Trip>>((ref) {
  final repo = ref.watch(tripRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAllTrips();
});

final unsettledDebtsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(tripRepositoryProvider);
  if (repo == null) return [];
  return repo.getUnsettledDebts();
});

final allFuelLogsProvider = StreamProvider<List<FuelLog>>((ref) {
  final repo = ref.watch(tripRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAllFuelLogs();
});

class TripRepository {
  final FirebaseFirestore _db;
  final String _uid;

  TripRepository(this._db, this._uid);

  DocumentReference get _userDoc => _db.collection('users').doc(_uid);
  CollectionReference get _tripsRef => _userDoc.collection('trips');
  CollectionReference get _fuelLogsRef => _userDoc.collection('fuel_logs');

  Stream<List<Trip>> watchAllTrips() {
    return _tripsRef.orderBy('tripDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
    });
  }

  Stream<List<FuelLog>> watchAllFuelLogs() {
    return _fuelLogsRef.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FuelLog.fromFirestore(doc))
          .where((log) => !log.isTripConsumption)
          .toList();
    });
  }

  Future<void> addManualFuelLog({
    required double amountLiters,
    required double totalCost,
    double? odometer,
  }) async {
    // 1. Fetch latest manual fuel log
    final prevLogsQuery = await _fuelLogsRef
        .where('isTripConsumption', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    double tripsCost = 0.0;
    final now = DateTime.now();

    // 2. Query trips in interval
    Query tripsQuery = _tripsRef;
    if (prevLogsQuery.docs.isNotEmpty) {
      final prevLog = FuelLog.fromFirestore(prevLogsQuery.docs.first);
      tripsQuery = tripsQuery
          .where('tripDate', isGreaterThan: prevLog.date)
          .where('tripDate', isLessThanOrEqualTo: now);
    } else {
      tripsQuery = tripsQuery.where('tripDate', isLessThanOrEqualTo: now);
    }

    final tripsSnapshot = await tripsQuery.get();
    for (var doc in tripsSnapshot.docs) {
      tripsCost += (doc['totalCost'] ?? 0.0).toDouble();
    }

    // 3. Save new refuel log with computed tripsCost
    await _fuelLogsRef.add({
      'tripId': '',
      'amountLiters': amountLiters,
      'totalCost': totalCost,
      'odometerReading': odometer,
      'date': FieldValue.serverTimestamp(),
      'isTripConsumption': false,
      'tripsCost': tripsCost,
    });
  }

  Future<void> deleteFuelLog(String logId) async {
    await _fuelLogsRef.doc(logId).delete();
  }

  Stream<Trip?> watchTrip(String tripId) {
    return _tripsRef.doc(tripId).snapshots().map((doc) {
      if (doc.exists) return Trip.fromFirestore(doc);
      return null;
    });
  }

  Stream<List<TripPassenger>> watchPassengersForTrip(String tripId) {
    return _tripsRef.doc(tripId).collection('passengers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TripPassenger.fromFirestore(doc)).toList();
    });
  }

  Future<FuelLog?> getFuelLogForTrip(String tripId) async {
    final query = await _fuelLogsRef.where('tripId', isEqualTo: tripId).limit(1).get();
    if (query.docs.isNotEmpty) {
      return FuelLog.fromFirestore(query.docs.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUnsettledDebts() async {
    final tripsSnapshot = await _tripsRef.get();
    List<Map<String, dynamic>> debts = [];
    
    for (var tripDoc in tripsSnapshot.docs) {
      final tripName = '${tripDoc['startLocation']} to ${tripDoc['endLocation']}';
      final paxSnapshot = await _tripsRef.doc(tripDoc.id).collection('passengers').where('isPaid', isEqualTo: false).get();
      
      for (var paxDoc in paxSnapshot.docs) {
        debts.add({
          'tripId': tripDoc.id,
          'tripName': tripName,
          'passengerId': paxDoc.id,
          ...paxDoc.data()
        });
      }
    }
    return debts;
  }

  Future<void> createTripWithRelations({
    required Trip trip,
    double? volume,
    required List<Passenger> passengers,
  }) async {
    final batch = _db.batch();
    
    // 1. Create Trip Doc
    final tripDoc = _tripsRef.doc(); // Generate ID
    
    batch.set(tripDoc, {
      'startLocation': FirebaseUtils.sanitizeString(trip.startLocation, maxLength: 200),
      'endLocation': FirebaseUtils.sanitizeString(trip.endLocation, maxLength: 200),
      'distance': trip.distance,
      'tripDate': trip.tripDate,
      'isRoundTrip': trip.isRoundTrip,
      'notes': FirebaseUtils.sanitizeString(trip.notes, maxLength: 500),
      'otherCosts': trip.otherCosts,
      'passengerCount': trip.passengerCount,
      'totalCost': trip.totalCost,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Create Fuel Log if volume provided
    if (volume != null && volume > 0) {
      final fuelLogDoc = _fuelLogsRef.doc();
      batch.set(fuelLogDoc, {
        'tripId': tripDoc.id,
        'amountLiters': volume,
        'totalCost': trip.totalCost, // Assuming total trip cost was fuel
        'date': FieldValue.serverTimestamp(),
      });
    }

    // 3. Create Passenger Docs
    if (passengers.isNotEmpty) {
      final costPerPassenger = trip.totalCost / trip.passengerCount; // Divide by all, including driver
      
      for (final pax in passengers) {
        final paxDoc = tripDoc.collection('passengers').doc(pax.id);
        batch.set(paxDoc, {
          'name': pax.name,
          'contactNumber': pax.contactNumber,
          'costShare': costPerPassenger,
          'isPaid': false,
        });
      }
    }

    await batch.commit();
  }

  Future<void> updateTripAndRecalculateCosts({
    required Trip originalTrip,
    required double newDistance,
    required bool newIsRoundTrip,
    required String newStartLocation,
    required String newEndLocation,
    required String newNotes,
    required double newOtherCosts,
  }) async {
    final fuelLog = await getFuelLogForTrip(originalTrip.id);
    
    if (fuelLog == null) {
      // Fallback if no fuel log exists just update fields
      await _tripsRef.doc(originalTrip.id).update({
        'startLocation': FirebaseUtils.sanitizeString(newStartLocation, maxLength: 200),
        'endLocation': FirebaseUtils.sanitizeString(newEndLocation, maxLength: 200),
        'distance': newDistance,
        'isRoundTrip': newIsRoundTrip,
        'notes': FirebaseUtils.sanitizeString(newNotes, maxLength: 500),
        'otherCosts': newOtherCosts,
      });
      return;
    }

    double impliedMileage = 0;
    double impliedFuelPrice = 0;
    if (fuelLog.amountLiters > 0) {
      impliedMileage = originalTrip.distance / fuelLog.amountLiters;
      impliedFuelPrice = fuelLog.totalCost / fuelLog.amountLiters;
    }

    double newAmountLiters = 0;
    double newFuelCost = 0;
    if (impliedMileage > 0) {
      newAmountLiters = newDistance / impliedMileage;
      newFuelCost = newAmountLiters * impliedFuelPrice;
    }

    double newTotalTripCost = newFuelCost + newOtherCosts;
    WriteBatch batch = _db.batch();

    // 1. Update Trip
    batch.update(_tripsRef.doc(originalTrip.id), {
      'startLocation': FirebaseUtils.sanitizeString(newStartLocation, maxLength: 200),
      'endLocation': FirebaseUtils.sanitizeString(newEndLocation, maxLength: 200),
      'distance': newDistance,
      'isRoundTrip': newIsRoundTrip,
      'notes': FirebaseUtils.sanitizeString(newNotes, maxLength: 500),
      'otherCosts': newOtherCosts,
      'totalCost': newTotalTripCost,
    });

    // 2. Update FuelLog
    batch.update(_fuelLogsRef.doc(fuelLog.id), {
      'amountLiters': newAmountLiters,
      'totalCost': newFuelCost,
    });

    // 3. Update Passengers
    final paxSnapshot = await _tripsRef.doc(originalTrip.id).collection('passengers').get();
    if (paxSnapshot.docs.isNotEmpty) {
      double newCostPerPax = newTotalTripCost / paxSnapshot.docs.length;
      for (var doc in paxSnapshot.docs) {
        batch.update(doc.reference, {'costShare': newCostPerPax});
      }
    }

    await batch.commit();
  }

  Future<void> deleteTrip(String tripId) async {
    final fuelLog = await getFuelLogForTrip(tripId);
    WriteBatch batch = _db.batch();
    
    if (fuelLog != null) {
      batch.delete(_fuelLogsRef.doc(fuelLog.id));
    }
    
    final paxSnapshot = await _tripsRef.doc(tripId).collection('passengers').get();
    for (var doc in paxSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    batch.delete(_tripsRef.doc(tripId));
    await batch.commit();
  }

  Future<void> updatePassengerPaymentStatus(String tripId, String passengerDocId, bool newStatus) async {
    await _tripsRef.doc(tripId).collection('passengers').doc(passengerDocId).update({
      'isPaid': newStatus,
    });
  }
}
