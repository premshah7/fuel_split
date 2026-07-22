import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../repositories/trip_repository.dart';
import '../../auth/repositories/auth_repository.dart';

class TripsListScreen extends ConsumerStatefulWidget {
  const TripsListScreen({super.key});

  @override
  ConsumerState<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends ConsumerState<TripsListScreen> {
  String _selectedFilter = 'current_month';

  String _getFilterLabel(DateTime now) {
    if (_selectedFilter == 'current_month') {
      return 'Current Month (${DateFormat('MMMM yyyy').format(now)})';
    } else if (_selectedFilter == 'all') {
      return 'All History';
    } else {
      final parts = _selectedFilter.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(allTripsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();

    return Scaffold(
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load trips', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        data: (allTrips) {
          // Extract month options dynamically
          final monthYears = allTrips.map((t) {
            return '${t.tripDate.year}-${t.tripDate.month.toString().padLeft(2, '0')}';
          }).toSet().toList();
          monthYears.sort((a, b) => b.compareTo(a)); // Descending order

          // Filter the trips list
          final filteredTrips = allTrips.where((t) {
            if (_selectedFilter == 'current_month') {
              return t.tripDate.year == now.year && t.tripDate.month == now.month;
            } else if (_selectedFilter == 'all') {
              return true;
            } else {
              final parts = _selectedFilter.split('-');
              final year = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              return t.tripDate.year == year && t.tripDate.month == month;
            }
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your Trips',
                      style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFilterLabel(now),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list_rounded),
                    tooltip: 'Filter Trips',
                    initialValue: _selectedFilter,
                    onSelected: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'current_month',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 18),
                              SizedBox(width: 12),
                              Text('Current Month'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              Icon(Icons.history_toggle_off_rounded, size: 18),
                              SizedBox(width: 12),
                              Text('All History'),
                            ],
                          ),
                        ),
                        if (monthYears.isNotEmpty) ...[
                          const PopupMenuDivider(),
                          ...monthYears.map((my) {
                            final parts = my.split('-');
                            final year = int.parse(parts[0]);
                            final month = int.parse(parts[1]);
                            final date = DateTime(year, month);
                            final label = DateFormat('MMMM yyyy').format(date);
                            return PopupMenuItem(
                              value: my,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 18),
                                  const SizedBox(width: 12),
                                  Text(label),
                                ],
                              ),
                            );
                          }),
                        ],
                      ];
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.local_gas_station_outlined),
                    tooltip: 'Fuel Logs',
                    onPressed: () => context.push('/fuel-logs'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              
              if (filteredTrips.isEmpty)
                SliverFillRemaining(
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
                        Text('No Trips Found', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter == 'current_month'
                              ? 'No trips completed this month yet.'
                              : 'No trips match the selected month filter.',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trip = filteredTrips[index];
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
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                  builder: (context) {
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.edit_outlined),
                                            title: const Text('Edit Trip'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              context.push('/edit-trip/${trip.id}', extra: trip);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            title: const Text('Delete Trip', style: TextStyle(color: Colors.redAccent)),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Trip?'),
                                                  content: const Text('This will permanently delete this trip and all associated data.'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                    FilledButton(
                                                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await ref.read(tripRepositoryProvider)?.deleteTrip(trip.id);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
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
                                              Text(DateFormat('dd/MM/yyyy').format(trip.tripDate), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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
                      childCount: filteredTrips.length,
                    ),
                  ),
                ),
              
              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
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
