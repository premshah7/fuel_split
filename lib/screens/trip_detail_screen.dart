import 'package:fuel_split/services/exports.dart';
import 'package:intl/intl.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> with SingleTickerProviderStateMixin {
  Future<Map<String, dynamic>>? _tripDetailsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tripDetailsFuture = _fetchTripDetails();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchTripDetails() async {
    final passengers = await database.getPassengersForTrip(widget.trip.id);
    final fuelLog = await database.getFuelLogForTrip(widget.trip.id);
    return {'passengers': passengers, 'fuelLog': fuelLog};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTripScreen(tripToEdit: widget.trip)),
              ).then((_) {
                setState(() {
                  _tripDetailsFuture = _fetchTripDetails();
                });
              });
            },
            tooltip: 'Edit Trip',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tripDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  const Text('Error loading trip details.'),
                ],
              ),
            );
          }
          final List<Passenger> passengers = snapshot.data!['passengers'];
          final FuelLog? fuelLog = snapshot.data!['fuelLog'];
          return _buildTripDetailsView(passengers, fuelLog);
        },
      ),
    );
  }

  Widget _buildTripDetailsView(List<Passenger> passengers, FuelLog? fuelLog) {
    double totalFuelCost = fuelLog?.totalCost ?? 0.0;
    double totalTripCost = totalFuelCost + widget.trip.otherCosts;
    double costPerPassenger = 0;
    double mileage = 0;

    if (totalTripCost > 0 && passengers.isNotEmpty) {
      costPerPassenger = totalTripCost / passengers.length;
    }
    if (fuelLog != null && fuelLog.amountLiters > 0) {
      mileage = widget.trip.distance / fuelLog.amountLiters;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Trip Route Card ---
          _buildRouteCard(context),
          const SizedBox(height: 16),

          // --- Cost Summary Card ---
          _buildCostSummaryCard(context, totalTripCost, costPerPassenger, mileage),
          const SizedBox(height: 16),

          // --- Passengers Card ---
          if (passengers.isNotEmpty)
            _buildPassengersCard(context, passengers, totalTripCost, costPerPassenger),
        ],
      ),
    );
  }

  // --- Helper Widgets for Building the Cards ---

  Widget _buildRouteCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildLocationRow(context, Icons.trip_origin, 'From', widget.trip.startLocation, Theme.of(context).primaryColor),
            Padding(
              padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
              child: Container(width: 2, height: 24, color: Colors.grey.shade300),
            ),
            _buildLocationRow(context, Icons.location_on, 'To', widget.trip.endLocation, Colors.red),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(context, Icons.straighten, '${widget.trip.distance.toStringAsFixed(1)} km', 'Distance'),
                _buildStatChip(context, Icons.calendar_today, DateFormat.yMMMd().format(widget.trip.tripDate), 'Date'),
                if (widget.trip.isRoundTrip)
                  _buildStatChip(context, Icons.sync_alt, 'Round', 'Trip Type'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummaryCard(BuildContext context, double totalTripCost, double costPerPassenger, double mileage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Total Trip Cost', '₹${totalTripCost.toStringAsFixed(2)}', Icons.monetization_on, Colors.green),
            _buildDetailRow(context, 'Cost / Person', costPerPassenger > 0 ? '₹${costPerPassenger.toStringAsFixed(2)}' : 'N/A', Icons.group, Colors.blue),
            _buildDetailRow(context, 'Vehicle Mileage', mileage > 0 ? '${mileage.toStringAsFixed(1)} km/l' : 'N/A', Icons.local_gas_station, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersCard(BuildContext context, List<Passenger> passengers, double totalTripCost, double costPerPassenger) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passengers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...passengers.map((passenger) {
              final String message = """
Hi ${passenger.name},
Here is the summary for our recent trip:
🚗 *Trip Details*
- *From:* ${widget.trip.startLocation}
- *To:* ${widget.trip.endLocation}
- *Distance:* ${widget.trip.distance.toStringAsFixed(1)} km
💰 *Cost Breakdown*
- *Total Trip Cost:* ₹${totalTripCost.toStringAsFixed(2)}
- *Your Share:* *₹${costPerPassenger.toStringAsFixed(2)}*
Thanks for sharing the ride!
""";
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(passenger.name.isNotEmpty ? passenger.name[0] : '?')),
                title: Text(passenger.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Share: ₹${costPerPassenger.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  onPressed: () => SharingService.launchWhatsApp(context, passenger: passenger, message: message),
                  tooltip: 'Share via WhatsApp',
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, String label, String location, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 2),
              Text(location, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}