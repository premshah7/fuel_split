import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../repositories/passenger_repository.dart';
import '../models/passenger.dart';
import '../../../core/utils/contact_helper.dart';

class PassengerListScreen extends ConsumerWidget {
  const PassengerListScreen({super.key});

  void _showPassengerSheet(BuildContext context, WidgetRef ref, {Passenger? passenger}) {
    final nameController = TextEditingController(text: passenger?.name);
    final phoneController = TextEditingController(text: passenger?.contactNumber);
    final isEditing = passenger != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Passenger' : 'New Passenger',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (!isEditing)
                    TextButton.icon(
                      onPressed: () async {
                        final contact = await ContactHelper.pickContact(context);
                        if (contact != null) {
                          nameController.text = contact.displayName ?? '';
                          if (contact.phones.isNotEmpty) {
                            phoneController.text = contact.phones.first.number;
                          }
                        }
                      },
                      icon: const Icon(Icons.contacts_rounded),
                      label: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (Optional)', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  
                  if (isEditing) {
                    await ref.read(passengerRepositoryProvider)?.updatePassenger(
                      id: passenger.id,
                      name: nameController.text.trim(),
                      contactNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    );
                  } else {
                    await ref.read(passengerRepositoryProvider)?.addPassenger(
                      name: nameController.text.trim(),
                      contactNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    );
                  }
                  
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEditing ? 'Update Passenger' : 'Save Passenger'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Passenger passenger) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Passenger?'),
        content: Text('Are you sure you want to remove ${passenger.name} from your crew directory? This will not affect existing trips they are part of.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(passengerRepositoryProvider)?.deletePassenger(passenger.id);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final passengersAsync = ref.watch(allPassengersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Crew Directory',
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          passengersAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error loading passengers: $err'))),
            data: (passengers) {
              if (passengers.isEmpty) {
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
                          child: Icon(Icons.group_add_rounded, size: 64, color: theme.primaryColor),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text('No Crew Members', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Add friends to easily split fuel costs.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
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
                      final pax = passengers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                pax.name.isNotEmpty ? pax.name[0].toUpperCase() : '?',
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            title: Text(pax.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            subtitle: pax.contactNumber != null && pax.contactNumber!.isNotEmpty
                                ? Text(pax.contactNumber!, style: TextStyle(color: Colors.grey.shade500))
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showPassengerSheet(context, ref, passenger: pax),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, ref, pax),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
                      );
                    },
                    childCount: passengers.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPassengerSheet(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Crew', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
