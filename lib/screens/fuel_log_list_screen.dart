import 'package:fuel_split/services/exports.dart';

class FuelLogListScreen extends StatefulWidget {
  const FuelLogListScreen({super.key});
  @override
  State<FuelLogListScreen> createState() => _FuelLogListScreenState();
}

class _FuelLogListScreenState extends State<FuelLogListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Logs')),
      body: StreamBuilder<List<FuelLog>>(
        stream: database.watchAllFuelLogs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              message: 'No fuel logs yet.\nComplete a trip or add one manually.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return GestureDetector(
                onLongPress: () {
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () {
                            // Call the delete service and close the dialog
                            DatabaseService.deleteFuelLog(log.id);
                            Navigator.of(ctx).pop();
                            // Optionally show a snackbar confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${log.isTripConsumption ? "Trip" : "Refuel"} log deleted.')),
                            );
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                child: FuelLogCard(log: log),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fuel_logs_fab',
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddFuelLogScreen()));
        },
        label: const Text('Add Refuel'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}