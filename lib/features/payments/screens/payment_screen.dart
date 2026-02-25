import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../trips/repositories/trip_repository.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../auth/repositories/auth_repository.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final debtsAsync = ref.watch(unsettledDebtsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Unsettled Debts',
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(unsettledDebtsProvider),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          debtsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error loading debts: $err'))),
            data: (debtsList) {
              if (debtsList.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text('All Settled Up!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('No outstanding balances to collect.', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                );
              }

              // Group debts by passenger name
              final Map<String, List<Map<String, dynamic>>> groupedDebts = {};
              for (var debt in debtsList) {
                final name = debt['name'] as String;
                groupedDebts.putIfAbsent(name, () => []).add(debt);
              }

              final totalOutstanding = debtsList.fold(0.0, (sum, item) => sum + (item['costShare'] as double));

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // Grand Total Card
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Outstanding', style: TextStyle(color: isDark ? Colors.white70 : Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            '₹${totalOutstanding.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.white),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    Text('Balances By Person', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    
                    ...groupedDebts.entries.map((entry) {
                      final name = entry.key;
                      final personDebts = entry.value;
                      final personTotal = personDebts.fold(0.0, (sum, i) => sum + (i['costShare'] as double));

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                        ),
                        child: ExpansionTile(
                          shape: Border.all(color: Colors.transparent),
                          collapsedShape: Border.all(color: Colors.transparent),
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          subtitle: Text('Owes ₹${personTotal.toStringAsFixed(0)}', style: TextStyle(color: Colors.redAccent.shade200, fontWeight: FontWeight.w500)),
                          children: [
                            const Divider(height: 1),
                            ...personDebts.map((d) {
                              return ListTile(
                                dense: true,
                                title: Text(d['tripName']),
                                subtitle: Text('₹${(d['costShare'] as double).toStringAsFixed(2)}'),
                                trailing: TextButton(
                                  onPressed: () async {
                                    // Mark as paid
                                    await ref.read(tripRepositoryProvider)?.updatePassengerPaymentStatus(
                                      d['tripId'],
                                      d['passengerId'],
                                      true,
                                    );
                                    // Invalidate to refresh the list
                                    ref.invalidate(unsettledDebtsProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked ${d['tripName']} as paid by $name.')));
                                    }
                                  },
                                  child: const Text('Mark Paid'),
                                ),
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 48),
                                      ),
                                      onPressed: () {
                                        final user = ref.read(authRepositoryProvider).currentUser;
                                        final driverName = user?.displayName ?? user?.email?.split('@')[0] ?? 'me';

                                        final message = UrlLauncherHelper.generateTotalDebtMessage(
                                          driverName: driverName,
                                          totalOwed: personTotal,
                                        );
                                        // Assume the first debt has the latest contact number
                                        final contactNumber = personDebts.first['contactNumber'] as String?;
                                        UrlLauncherHelper.launchWhatsApp(contactNumber, message);
                                      },
                                      icon: const Icon(Icons.share, color: Colors.green),
                                      label: const Text('Reminder'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        minimumSize: const Size(double.infinity, 48),
                                      ),
                                      onPressed: () async {
                                        // Settle all for this person
                                        final repo = ref.read(tripRepositoryProvider);
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(child: CircularProgressIndicator()),
                                        );

                                        for (var d in personDebts) {
                                          await repo?.updatePassengerPaymentStatus(d['tripId'], d['passengerId'], true);
                                        }
                                        
                                        ref.invalidate(unsettledDebtsProvider);
                                        if (context.mounted) {
                                          Navigator.pop(context); // pop loading
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All debts settled for $name.')));
                                        }
                                      },
                                      icon: const Icon(Icons.done_all),
                                      label: const Text('Settle All'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
                    }),
                    
                    const SizedBox(height: 100),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
