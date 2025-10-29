import 'package:fuel_split/services/exports.dart';


class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Future<Map<String, dynamic>>? _tripDetailsFuture;

  @override
  void initState() {
    super.initState();
    _tripDetailsFuture = _fetchTripDetails();
  }

  Future<Map<String, dynamic>> _fetchTripDetails() async {
    final passengers = await database.getPassengersForTrip(widget.trip.id);
    final fuelLog = await database.getFuelLogForTrip(widget.trip.id);
    return {'passengers': passengers, 'fuelLog': fuelLog};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tripDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading trip details.'));
          }
          final List<Passenger> passengers = snapshot.data!['passengers'];
          final FuelLog? fuelLog = snapshot.data!['fuelLog'];
          return _buildTripDetailsView(passengers, fuelLog);
        },
      ),
    );
  }

  Widget _buildTripDetailsView(List<Passenger> passengers, FuelLog? fuelLog) {
    double costPerPassenger = 0;
    double totalCost = fuelLog?.totalCost ?? 0.0;
    if (fuelLog != null && passengers.isNotEmpty) {
      costPerPassenger = fuelLog.totalCost / passengers.length;
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header Card and Fuel Card (Add your existing card code here if you have it)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: ${widget.trip.startLocation}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('To: ${widget.trip.endLocation}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Passengers Card
        if (passengers.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Passengers & Share', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...passengers.map((passenger) {
                    final String message = """
                      Hi ${passenger.name},
                      Here is the summary for our recent trip:
                      🚗 *Trip Details*
                      - *From:* ${widget.trip.startLocation}
                      - *To:* ${widget.trip.endLocation}
                      - *Distance:* ${widget.trip.distance.toStringAsFixed(1)} km
                      
                      💰 *Cost Breakdown*
                      - *Total Fuel Cost:* ₹${totalCost.toStringAsFixed(2)}
                      - *Your Share:* *₹${costPerPassenger.toStringAsFixed(2)}*
                      
                      Thanks for sharing the ride!
                      """;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(passenger.name[0])),
                      title: Text(passenger.name),
                      subtitle: Text('Share: ₹${costPerPassenger.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.share, color: Colors.green),
                        onPressed: () => SharingService.launchWhatsApp(context, passenger: passenger, message: message),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}