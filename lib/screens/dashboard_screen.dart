import 'package:fuel_split/services/exports.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'This Month (${DateFormat.MMMM().format(DateTime.now())})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Charts & Visualizations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 200,
                child: const Center(child: Text('Charts coming soon!')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}