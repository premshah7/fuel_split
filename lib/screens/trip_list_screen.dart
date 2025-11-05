import 'package:fuel_split/services/exports.dart';

class TripListScreen extends StatefulWidget {
  final void Function(int index) onNavigateToPassengers;
  const TripListScreen({super.key, required this.onNavigateToPassengers});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        // === THIS IS THE NEW SECTION ===
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show a confirmation dialog before logging out
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () {
                        // Call our new service to sign the user out
                        AuthService.signOut();
                        // We don't need to navigate. The AuthWrapper in main.dart
                        // will automatically detect the sign-out and show the LoginScreen.
                        Navigator.of(ctx).pop(); // Close the dialog
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Logout',
          ),
        ],

      ),
      body: StreamBuilder<List<Trip>>(
        stream: _dbService.watchAllTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.map_outlined,
              message: 'No trips recorded yet.\nTap the + button to start a new trip.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)));
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Trip?'),
                      content: const Text('Are you sure you want to delete this trip?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () {
                            _dbService.deleteTrip(trip.id);
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${trip.startLocation} to ${trip.endLocation}'),
                    subtitle: Text('${trip.distance.toStringAsFixed(1)} km'),
                    trailing: Text('₹${trip.totalCost.toStringAsFixed(2)}'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'trips_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Start Live Trip (With Passengers)'),
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final allPassengers = await _dbService.watchAllPassengers().first;
                        if (!mounted) return;

                        if (allPassengers.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('No Passengers Found'),
                              content: const Text('To start a trip with passengers, you need to add one first.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop();
                                    widget.onNavigateToPassengers(2); // Index of passenger screen
                                  },
                                  child: const Text('Go to Passengers'),
                                ),
                              ],
                            ),
                          );
                         } else {
                          final selectedPassengers = await showDialog<List<Passenger>>(
                            context: context,
                            builder: (context) => PassengerSelectionDialog(allPassengers: allPassengers),
                          );
                          if (selectedPassengers != null && selectedPassengers.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LiveTripScreen(passengers: selectedPassengers)));
                          }
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Start Solo Trip (Just Me)'),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveTripScreen(passengers: [])));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: const Text('Add Manually'),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTripScreen()));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        label: const Text('New Trip'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class PassengerSelectionDialog extends StatefulWidget {
  final List<Passenger> allPassengers;
  const PassengerSelectionDialog({super.key, required this.allPassengers});

  @override
  _PassengerSelectionDialogState createState() => _PassengerSelectionDialogState();
}

class _PassengerSelectionDialogState extends State<PassengerSelectionDialog> {
  final List<Passenger> _selectedPassengers = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Passengers'),
      content: SingleChildScrollView(
        child: Column(
          children: widget.allPassengers.map((passenger) {
            final isSelected = _selectedPassengers.contains(passenger);
            return CheckboxListTile(
              title: Text(passenger.name),
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedPassengers.add(passenger);
                  } else {
                    _selectedPassengers.remove(passenger);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_selectedPassengers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one passenger.')));
              return;
            }
            Navigator.pop(context, _selectedPassengers);
          },
          child: const Text('Start Trip'),
        ),
      ],
    );
  }
}