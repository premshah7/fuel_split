import 'package:fuel_split/services/exports.dart';
import 'package:drift/drift.dart' hide Column;

class PassengerListScreen extends StatefulWidget {
  const PassengerListScreen({super.key});

  @override
  State<PassengerListScreen> createState() => _PassengerListScreenState();
}

class _PassengerListScreenState extends State<PassengerListScreen> {
  void _showAddPassengerDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Passenger Manually'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
            TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Number (Optional)'), keyboardType: TextInputType.phone),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  final newPassenger = PassengersCompanion(
                    name: Value(name),
                    contactNumber: Value(contactController.text),
                  );
                  database.insertPassenger(newPassenger);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passengers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_phone_outlined),
            onPressed: () => ContactService.pickContactAndSave(context),
            tooltip: 'Add from Contacts',
          ),
        ],
      ),
      body: StreamBuilder<List<Passenger>>(
        stream: database.watchAllPassengers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final passengers = snapshot.data ?? [];
          if (passengers.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline,
              message: 'No passengers added yet.\nAdd one manually or from your contacts.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: passengers.length,
            itemBuilder: (context, index) {
              final passenger = passengers[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(passenger.name.isNotEmpty ? passenger.name[0] : '?')),
                  title: Text(passenger.name),
                  subtitle: Text(passenger.contactNumber ?? 'No contact number'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Passenger?'),
                          content: Text('Are you sure you want to delete ${passenger.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () {
                                database.deletePassenger(passenger.id);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'passengers_fab',
        onPressed: _showAddPassengerDialog,
        label: const Text('Add Manually'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}