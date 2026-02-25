import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../../passengers/models/passenger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../auth/repositories/auth_repository.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  final Trip? initialTrip;

  const TripDetailScreen({
    super.key,
    required this.tripId,
    this.initialTrip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tripAsync = ref.watch(allTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement Edit Trip
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async {
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

              if (confirm == true && context.mounted) {
                await ref.read(tripRepositoryProvider)?.deleteTrip(tripId);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading trip details: $err')),
        data: (trips) {
          final trip = trips.firstWhere((t) => t.id == tripId, orElse: () => initialTrip ?? Trip(
            id: '', startLocation: '', endLocation: '', distance: 0, tripDate: DateTime.now(), isRoundTrip: false
          ));
          
          if (trip.id.isEmpty) return const Center(child: Text('Trip not found.'));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark 
                              ? [theme.primaryColor.withValues(alpha: 0.2), theme.primaryColor.withValues(alpha: 0.05)]
                              : [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(trip.startLocation, style: theme.textTheme.titleMedium?.copyWith(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Icon(trip.isRoundTrip ? Icons.sync_alt : Icons.arrow_right_alt, color: isDark ? theme.primaryColor : Colors.black54),
                                ),
                                Expanded(child: Text(trip.endLocation, style: theme.textTheme.titleMedium?.copyWith(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatDetail(context, Icons.calendar_today, DateFormat('MMM d, yyyy').format(trip.tripDate), isDark),
                                _buildStatDetail(context, Icons.straighten, '${trip.distance.toStringAsFixed(1)} km', isDark),
                                _buildStatDetail(context, Icons.currency_rupee, '₹${trip.totalCost.toStringAsFixed(0)}', isDark),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
                      
                      const SizedBox(height: 32),
                      
                      // Passengers List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Crew & Shares', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${trip.passengerCount} Total', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPassengersList(context, ref, trip),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatDetail(BuildContext context, IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: isDark ? Theme.of(context).primaryColor : Colors.black54, size: 20),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildPassengersList(BuildContext context, WidgetRef ref, Trip trip) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // We can also fetch the driver from user profile, but for now we list the shares
    return StreamBuilder<List<TripPassenger>>(
      stream: ref.read(tripRepositoryProvider)?.watchPassengersForTrip(trip.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load passengers'));
        }
        
        final passengers = snapshot.data ?? [];
        
        if (passengers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: const Center(child: Text('No crew members tracked for this trip.')),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: passengers.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
            itemBuilder: (context, index) {
              final pax = passengers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  child: Text(pax.name.isNotEmpty ? pax.name[0].toUpperCase() : '?', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                ),
                title: Text(pax.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('Should pay: ₹${pax.costShare.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade500)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.green),
                      tooltip: 'Send via WhatsApp',
                      onPressed: () {
                        final user = ref.read(authRepositoryProvider).currentUser;
                        final driverName = user?.displayName ?? user?.email?.split('@')[0] ?? 'me';
                        
                        final message = UrlLauncherHelper.generateTripReceiptMessage(
                          driverName: driverName,
                          startLocation: trip.startLocation,
                          endLocation: trip.endLocation,
                          totalCost: trip.totalCost,
                          yourShare: pax.costShare,
                        );
                        UrlLauncherHelper.launchWhatsApp(pax.contactNumber, message);
                      },
                    ),
                    Checkbox(
                      value: pax.isPaid,
                      activeColor: theme.primaryColor,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(tripRepositoryProvider)?.updatePassengerPaymentStatus(trip.id, pax.id, val);
                        }
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
            },
          ),
        );
      },
    );
  }
}
