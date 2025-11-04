import 'package:fuel_split/services/exports.dart';

class TripListScreen extends StatefulWidget {
  final void Function(int index) onNavigateToPassengers;
  const TripListScreen({super.key, required this.onNavigateToPassengers});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: StreamBuilder<List<Trip>>(
        stream: database.watchAllTrips(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
              return FutureBuilder<TripCardBundle>(
                future: DatabaseService.getTripCardDetails(trip.id),
                builder: (context, cardBundleSnapshot) {
                  if (!cardBundleSnapshot.hasData) {
                    return Opacity(
                      opacity: 0.5,
                      child: TripCard(trip: trip, passengers: const [], fuelLog: null),
                    );
                  }

                  final cardData = cardBundleSnapshot.data!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)),
                      );
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Trip?'),
                          content: const Text('Are you sure you want to permanently delete this trip and all its associated data?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () {
                                DatabaseService.deleteTrip(trip.id);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: TripCard(
                      trip: trip,
                      passengers: cardData.passengers,
                      fuelLog: cardData.fuelLog,
                    ),
                  );
                },
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
                    // --- OPTION 1: LIVE TRIP WITH PASSENGERS ---
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Start Live Trip (With Passengers)'),
                      subtitle: const Text('Select passengers and split the cost'),
                      onTap: () async {
                        Navigator.of(ctx).pop(); // Close the bottom sheet
                        final allPassengers = await database.watchAllPassengers().first;
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
                                    widget.onNavigateToPassengers(2);
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LiveTripScreen(passengers: selectedPassengers)),
                            );
                          }
                        }
                      },
                    ),

                    // --- NEW: OPTION 2: LIVE SOLO TRIP ---
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Start Solo Trip (Just Me)'),
                      subtitle: const Text('Track your own distance and fuel usage'),
                      onTap: () {
                        Navigator.of(ctx).pop(); // Close the bottom sheet
                        // Navigate to the LiveTripScreen with an EMPTY list of passengers.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LiveTripScreen(passengers: []),
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    // --- OPTION 3: ADD MANUALLY ---
                    ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: const Text('Add Manually'),
                      subtitle: const Text('Enter trip details after the fact'),
                      onTap: () {
                        Navigator.of(ctx).pop(); // Close the bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddTripScreen()),
                        );
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

// In lib/screens/trip_list_screen.dart, AFTER the _TripListScreenState class

class PassengerSelectionDialog extends StatefulWidget {
  final List<Passenger> allPassengers;

  const PassengerSelectionDialog({super.key, required this.allPassengers});

  @override
  _PassengerSelectionDialogState createState() => _PassengerSelectionDialogState();
}

class _PassengerSelectionDialogState extends State<PassengerSelectionDialog> {
  // This list will hold the passengers the user ticks in the checkbox
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
                // Update the state of this dialog when a checkbox is ticked
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
        TextButton(
          onPressed: () => Navigator.pop(context), // Close and return null
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedPassengers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select at least one passenger.')),
              );
              return;
            }
            // Close the dialog and return the list of selected passengers as the result
            Navigator.pop(context, _selectedPassengers);
          },
          child: const Text('Start Trip'),
        ),
      ],
    );
  }
}