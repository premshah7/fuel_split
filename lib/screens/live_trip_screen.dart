import 'package:fuel_split/services/exports.dart';

class LiveTripScreen extends StatefulWidget {
  final List<Passenger> passengers;
  const LiveTripScreen({super.key, required this.passengers});

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  bool _isTracking = false;
  double _totalDistance = 0.0;
  String _startAddress = 'Press Start to begin your trip';
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _startPosition;
  Position? _lastPosition;

  final _mileageController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _otherCostsController = TextEditingController(text: '0.0');

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mileageController.dispose();
    _fuelPriceController.dispose();
    _otherCostsController.dispose();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      _positionStreamSubscription?.cancel();
      setState(() { _isTracking = false; });
      _showCostInputDialog();
    } else {
      final hasPermission = await LocationService.checkAndRequestPermissions();
      if (!hasPermission || !mounted) return;

      final locationSettings = LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 5);
      _startPosition = await Geolocator.getCurrentPosition();
      _lastPosition = _startPosition;
      final address = await LocationService.getAddressFromCoordinates(_startPosition!);

      setState(() {
        _isTracking = true;
        _startAddress = address;
      });

      _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        if (position.accuracy > 50) return;
        if (_lastPosition != null) {
          final distance = Geolocator.distanceBetween(_lastPosition!.latitude, _lastPosition!.longitude, position.latitude, position.longitude);
          setState(() {
            _totalDistance += distance;
            _lastPosition = position;
          });
        }
      });
    }
  }

  void _showCostInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Trip Costs'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _mileageController, decoration: const InputDecoration(labelText: 'Vehicle Mileage (km/l)'), keyboardType: TextInputType.number),
            TextField(controller: _fuelPriceController, decoration: const InputDecoration(labelText: 'Fuel Price (per liter)'), keyboardType: TextInputType.number),
            TextField(controller: _otherCostsController, decoration: const InputDecoration(labelText: 'Other Costs (Tolls, etc.)'), keyboardType: TextInputType.number),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: _calculateAndSaveTrip,
              child: const Text('Calculate & Save'),
            ),
          ],
        );
      },
    );
  }

  void _calculateAndSaveTrip() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final mileage = double.tryParse(_mileageController.text) ?? 0.0;
    final fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;
    final otherCosts = double.tryParse(_otherCostsController.text) ?? 0.0;
    if (mileage <= 0 || fuelPrice <= 0 || _lastPosition == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter valid mileage and price.')));
      return;
    }

    final endAddress = await LocationService.getAddressFromCoordinates(_lastPosition!);
    final distanceInKm = _totalDistance / 1000.0;
    final totalLitersUsed = distanceInKm / mileage;
    final totalFuelCost = totalLitersUsed * fuelPrice;

    try {
      await DatabaseService.createTripWithLog(
        startLocation: _startAddress,
        endLocation: endAddress,
        distance: distanceInKm,
        isRoundTrip: false,
        notes: 'Live GPS tracked trip.',
        passengers: widget.passengers,
        totalFuelCost: totalFuelCost,
        totalLitersUsed: totalLitersUsed,
        otherCosts: otherCosts,
      );
      
      messenger.showSnackBar(const SnackBar(content: Text('Trip saved successfully!')));
      navigator.pop();
      navigator.pop();

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to save trip: $e')));
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Trip Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${(_totalDistance / 1000).toStringAsFixed(2)} km', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 20),
            Text(
              _isTracking ? 'From: $_startAddress' : 'Press Start to begin your trip',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FloatingActionButton.large(
              onPressed: _toggleTracking,
              backgroundColor: _isTracking ? Colors.red : Colors.green,
              child: Icon(_isTracking ? Icons.stop : Icons.play_arrow, size: 60),
            ),
          ],
        ),
      ),
    );
  }
}