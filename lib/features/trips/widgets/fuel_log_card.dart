import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fuel_log.dart';

class TopupSummary {
  final double distance;
  final double mileage;
  final double costPerKm;

  TopupSummary({
    required this.distance,
    required this.mileage,
    required this.costPerKm,
  });
}

class FuelLogCard extends StatelessWidget {
  final FuelLog log;
  final TopupSummary? summary;

  const FuelLogCard({super.key, required this.log, this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isTrip = log.isTripConsumption;
    final Color iconColor = isTrip ? Colors.blue : theme.primaryColor;
    final IconData icon = isTrip ? Icons.directions_car_filled : Icons.local_gas_station;
    final String title = isTrip ? 'Trip Fuel Consumption' : 'Gas Station Refuel';
    final double pricePerLiter = log.amountLiters > 0 ? log.totalCost / log.amountLiters : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        '${log.amountLiters.toStringAsFixed(2)} Liters • ₹${pricePerLiter.toStringAsFixed(2)}/l',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      if (log.odometerReading != null && log.odometerReading! > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Odometer: ${log.odometerReading!.toStringAsFixed(0)} km',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${log.totalCost.toStringAsFixed(0)}',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat.yMMMd().format(log.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (!isTrip && log.tripsCost > 0) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trips Cost in Period:',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  Text(
                    '₹${log.tripsCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
            if (summary != null) ...[
              const SizedBox(height: 12),
              if (!(!isTrip && log.tripsCost > 0))
                Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(context, 'Distance', '${summary!.distance.toStringAsFixed(1)} km'),
                  _buildSummaryItem(context, 'Economy', '${summary!.mileage.toStringAsFixed(2)} km/l'),
                  _buildSummaryItem(context, 'Cost/km', '₹${summary!.costPerKm.toStringAsFixed(2)}'),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}
