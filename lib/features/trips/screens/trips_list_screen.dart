import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../repositories/trip_repository.dart';
import '../../auth/repositories/auth_repository.dart';

class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(allTripsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Your Trips',
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {}, // TODO: Settings
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          tripsAsync.when(
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
                    Text('Failed to load trips', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            data: (trips) {
              if (trips.isEmpty) {
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
                          child: Icon(Icons.directions_car_filled_rounded, size: 64, color: theme.primaryColor),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text('No Trips Yet', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Start tracking your fuel costs by adding your first trip!', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
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
                      final trip = trips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1),
                          ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            context.push('/trip/${trip.id}', extra: trip);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.route_rounded, color: theme.primaryColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${trip.startLocation} to ${trip.endLocation}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month, size: 14, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text('${trip.tripDate.day}/${trip.tripDate.month}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                          const SizedBox(width: 12),
                                          Icon(Icons.straighten, size: 14, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text('${trip.distance.toStringAsFixed(1)} km', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${trip.totalCost.toStringAsFixed(0)}',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor),
                                    ),
                                    Text('${trip.passengerCount} pax', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
                      );
                    },
                    childCount: trips.length,
                  ),
                ),
              );
            },
          ),
          
          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-trip');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Trip', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
