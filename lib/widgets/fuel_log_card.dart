import 'package:fuel_split/services/exports.dart';
import 'package:intl/intl.dart';

class FuelLogCard extends StatelessWidget {
  final FuelLog log;
  const FuelLogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    // Differentiate based on the log type
    final bool isTrip = log.isTripConsumption;
    final Color iconColor = isTrip ? Colors.blue : Theme.of(context).primaryColor;
    final IconData icon = isTrip ? Icons.directions_car_filled : Icons.local_gas_station;
    final String title = isTrip ? 'Trip Fuel Consumption' : 'Gas Station Refuel';
    final double pricePerLiter = log.totalCost / log.amountLiters;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${log.amountLiters.toStringAsFixed(2)} Liters • ₹${pricePerLiter.toStringAsFixed(2)}/l',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${log.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(DateFormat.yMMMd().format(log.logDate), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}