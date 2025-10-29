import 'package:fuel_split/services/exports.dart';
import 'package:intl/intl.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final List<Passenger> passengers;

  const TripCard({super.key, required this.trip, required this.passengers});

  @override
  Widget build(BuildContext context) {
    final passengerNames = passengers.map((p) => p.name).join(', ');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MODIFIED: Location Section for better readability ---
            Row(
              children: [
                Icon(Icons.trip_origin, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'From: ${trip.startLocation}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trip.isRoundTrip)
                  Icon(
                    Icons.sync_alt,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                    // tooltip: 'Round Trip',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'To: ${trip.endLocation}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // --- End of modification ---

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(context, Icons.directions_car, '${trip.distance.toStringAsFixed(1)} km'),
                _buildInfoChip(context, Icons.calendar_today, DateFormat.yMMMd().format(trip.tripDate)),
              ],
            ),
            if (passengerNames.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.people_alt_outlined, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'With: $passengerNames',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}