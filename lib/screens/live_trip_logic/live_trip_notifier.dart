import 'package:fuel_split/services/exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liveTripNotifierProvider = StateNotifierProvider.autoDispose
    .family<LiveTripNotifier, LiveTripState, List<Passenger>>(
        (ref, passengers) => LiveTripNotifier(passengers));

class LiveTripNotifier extends StateNotifier<LiveTripState> {
  final List<Passenger> _passengers;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _startPosition;
  Position? _lastPosition;

  LiveTripNotifier(this._passengers) : super(const LiveTripState());

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<bool> toggleTracking() async {
    if (state.isTracking) {
      _positionStreamSubscription?.cancel();
      state = state.copyWith(isTracking: false);
      return true; // Signal to UI to show dialog
    } else {
      final hasPermission = await LocationService.checkAndRequestPermissions();
      if (!hasPermission) return false;

      _startPosition = await Geolocator.getCurrentPosition();
      _lastPosition = _startPosition;
      final address = await LocationService.getAddressFromCoordinates(_startPosition!);

      state = state.copyWith(isTracking: true, startAddress: address);
      _listenForLocationUpdates();
      return false; // Don't show dialog, we are just starting
    }
  }

  void _listenForLocationUpdates() {
    final locationSettings = LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5);
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (position.accuracy > 50) return;
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(_lastPosition!.latitude, _lastPosition!.longitude, position.latitude, position.longitude);
        state = state.copyWith(totalDistance: state.totalDistance + distance);
        _lastPosition = position;
      }
    });
  }

  Future<bool> calculateAndSaveTrip(String mileageStr, String fuelPriceStr) async {
    final mileage = double.tryParse(mileageStr) ?? 0.0;
    final fuelPrice = double.tryParse(fuelPriceStr) ?? 0.0;
    if (mileage <= 0 || fuelPrice <= 0 || _lastPosition == null) return false;

    final endAddress = await LocationService.getAddressFromCoordinates(_lastPosition!);
    final distanceInKm = state.totalDistance / 1000.0;
    final totalLitersUsed = distanceInKm / mileage;
    final totalFuelCost = totalLitersUsed * fuelPrice;

    try {
      await DatabaseService.createTripWithLog(
        startLocation: state.startAddress,
        endLocation: endAddress,
        distance: distanceInKm,
        isRoundTrip: false,
        notes: 'Live GPS tracked trip.',
        passengers: _passengers,
        totalFuelCost: totalFuelCost,
        totalLitersUsed: totalLitersUsed,
      );
      return true;
    } catch (e) {
      debugPrint("Error saving trip: $e");
      return false;
    }
  }
}