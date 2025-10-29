import 'package:fuel_split/screens/add_fuel_log_screen.dart';
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
      appBar: AppBar(
        title: const Text('Fuel Logs'),
      ),
      body: StreamBuilder<List<FuelLog>>(
        stream: database.watchAllFuelLogs(),
        builder: (context, snapshot) {
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
              // Use the new, beautiful card
              return FuelLogCard(log: log);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fuel_logs_fab',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelLogScreen()));
        },
        label: const Text('Add Refuel'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}