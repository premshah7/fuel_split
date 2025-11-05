import 'package:fuel_split/services/exports.dart';
import 'package:intl/intl.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                setState(() {});
              });
            },
            tooltip: 'Edit Trip',
          ),
        ],
      ),
      body: _buildTripDetailsView(),
    );
  }

  Widget _buildTripDetailsView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRouteCard(context),
          const SizedBox(height: 16),
          _buildCostSummaryCard(context),
          const SizedBox(height: 16),
          _buildPassengersCard(context),
        ],
      ),
    );
  }

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

  Widget _buildCostSummaryCard(BuildContext context) {
    // In a full implementation, you would fetch the FuelLog and calculate mileage here.
    // For now, we use the totalCost stored directly on the trip.
    final costPerPassenger = widget.trip.passengerCount > 0 ? widget.trip.totalCost / widget.trip.passengerCount : 0.0;

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
            _buildDetailRow(context, 'Total Trip Cost', '₹${widget.trip.totalCost.toStringAsFixed(2)}', Icons.monetization_on, Colors.green),
            _buildDetailRow(context, 'Cost / Person', costPerPassenger > 0 ? '₹${costPerPassenger.toStringAsFixed(2)}' : 'N/A', Icons.group, Colors.blue),
            _buildDetailRow(context, 'Other Costs', '₹${widget.trip.otherCosts.toStringAsFixed(2)}', Icons.request_quote, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersCard(BuildContext context) {
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
            // We use a StreamBuilder here to get the live payment status for passengers
            StreamBuilder<List<TripPassengerDetail>>(
              stream: _dbService.watchPassengersForTrip(widget.trip.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final passengers = snapshot.data ?? [];
                if (passengers.isEmpty) return const Text('No passengers on this trip.');

                return Column(
                  children: passengers.map((pax) {
                    final String message = "Hi ${pax.name}, your share for the trip was ₹${pax.costShare.toStringAsFixed(2)}.";
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(pax.name.isNotEmpty ? pax.name[0] : '?')),
                      title: Text(pax.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Share: ₹${pax.costShare.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Payment Status Chip (Now interactive)
                          InkWell(
                            onTap: () {
                              // Toggle the payment status
                              _dbService.updatePassengerPaymentStatus(
                                  tripId: widget.trip.id,
                                  passengerDocId: pax.id,
                                  newStatus: !pax.isPaid
                              );
                            },
                            child: Chip(
                              label: Text(pax.isPaid ? 'Paid' : 'Unpaid'),
                              backgroundColor: pax.isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              labelStyle: TextStyle(color: pax.isPaid ? Colors.green : Colors.orange),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.green),
                            onPressed: () {
                              // We need to fetch the full passenger object to get the contact number
                              // This is a limitation of this data model, but we can work around it for the message.
                              SharingService.launchWhatsApp(context, passenger: Passenger(id: pax.id, name: pax.name), message: message);
                            },
                            tooltip: 'Share via WhatsApp',
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
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