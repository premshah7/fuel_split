import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../repositories/trip_repository.dart';
import '../models/fuel_log.dart';
import '../widgets/fuel_log_card.dart';

class FuelLogListScreen extends ConsumerWidget {
  const FuelLogListScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, FuelLog log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Fuel Log?'),
        content: Text(
            'Are you sure you want to delete this ${log.isTripConsumption ? "trip consumption" : "refuel"} log? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final repo = ref.read(tripRepositoryProvider);
              if (repo != null) {
                await repo.deleteFuelLog(log.id);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${log.isTripConsumption ? "Trip" : "Refuel"} log deleted.'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editLog(BuildContext context, FuelLog log) {
    if (!log.isTripConsumption) {
      context.push('/edit-refuel/${log.id}', extra: log);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allFuelLogsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Fuel Logs',
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          
          logsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load logs', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.local_gas_station_rounded, size: 64, color: theme.primaryColor),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text('No Fuel Logs', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Log your manual refuels to track fuel economy.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final log = logs[index];
                      TopupSummary? summary;

                      if (!log.isTripConsumption) {
                        // Find the previous manual refuel log (which has an index > current index in DESCENDING order)
                        FuelLog? previousLog;
                        for (int i = index + 1; i < logs.length; i++) {
                          if (!logs[i].isTripConsumption) {
                            previousLog = logs[i];
                            break;
                          }
                        }
                        if (previousLog != null &&
                            log.odometerReading != null &&
                            previousLog.odometerReading != null &&
                            log.odometerReading! > previousLog.odometerReading!) {
                          final distance = log.odometerReading! - previousLog.odometerReading!;
                          final mileage = log.amountLiters > 0 ? distance / log.amountLiters : 0.0;
                          final costPerKm = distance > 0 ? log.totalCost / distance : 0.0;
                          summary = TopupSummary(
                            distance: distance,
                            mileage: mileage,
                            costPerKm: costPerKm,
                          );
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: !log.isTripConsumption ? () => _editLog(context, log) : null,
                          onLongPress: () => _confirmDelete(context, ref, log),
                          child: FuelLogCard(
                            log: log,
                            summary: summary,
                            onEdit: !log.isTripConsumption ? () => _editLog(context, log) : null,
                            onDelete: () => _confirmDelete(context, ref, log),
                          ),
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
                    },
                    childCount: logs.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-refuel');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Refuel', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
