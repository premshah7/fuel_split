import 'package:fuel_split/services/exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveTripScreen extends ConsumerWidget {
  final List<Passenger> passengers;
  const LiveTripScreen({super.key, required this.passengers});

  void _showCostInputDialog(BuildContext context, WidgetRef ref) {
    final mileageController = TextEditingController();
    final fuelPriceController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Trip Costs'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: mileageController, decoration: const InputDecoration(labelText: 'Vehicle Mileage (km/l)'), keyboardType: TextInputType.number),
            TextField(controller: fuelPriceController, decoration: const InputDecoration(labelText: 'Fuel Price (per liter)'), keyboardType: TextInputType.number),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final notifier = ref.read(liveTripNotifierProvider(passengers).notifier);
                final success = await notifier.calculateAndSaveTrip(mileageController.text, fuelPriceController.text);

                if (success && context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close live trip screen
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save trip. Please check values.')));
                }
              },
              child: const Text('Calculate & Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveTripNotifierProvider(passengers));

    return Scaffold(
      appBar: AppBar(title: const Text('Live Trip Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${(state.totalDistance / 1000).toStringAsFixed(2)} km', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 20),
            Text(
              state.isTracking ? 'From: ${state.startAddress}' : 'Press Start to begin your trip',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FloatingActionButton.large(
              onPressed: () async {
                final notifier = ref.read(liveTripNotifierProvider(passengers).notifier);
                final bool shouldShowDialog = await notifier.toggleTracking();
                if (shouldShowDialog) {
                  _showCostInputDialog(context, ref);
                }
              },
              backgroundColor: state.isTracking ? Colors.red : Colors.green,
              child: Icon(state.isTracking ? Icons.stop : Icons.play_arrow, size: 60),
            ),
          ],
        ),
      ),
    );
  }
}