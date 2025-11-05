import 'package:fuel_split/models/unsettled_debt_model.dart';
import 'package:fuel_split/services/exports.dart';
import 'package:intl/intl.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Settlements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: StreamBuilder<List<UnsettledDebt>>(
        stream: _dbService.watchAllUnsettledDebts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final allDebts = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDebtList(context, allDebts, 'today'),
              _buildDebtList(context, allDebts, 'week'),
              _buildDebtList(context, allDebts, 'month'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDebtList(BuildContext context, List<UnsettledDebt> allDebts, String filter) {
    final now = DateTime.now();
    List<UnsettledDebt> filteredDebts;

    if (filter == 'today') {
      final startOfToday = DateTime(now.year, now.month, now.day);
      filteredDebts = allDebts.where((d) => d.tripDate.isAfter(startOfToday)).toList();
    } else if (filter == 'week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      filteredDebts = allDebts.where((d) => d.tripDate.isAfter(startOfWeek)).toList();
    } else { // month
      final startOfMonth = DateTime(now.year, now.month, 1);
      filteredDebts = allDebts.where((d) => d.tripDate.isAfter(startOfMonth)).toList();
    }

    if (filteredDebts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline,
        message: 'All settled up for this period!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredDebts.length,
      itemBuilder: (context, index) {
        final debt = filteredDebts[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(debt.passengerName.isNotEmpty ? debt.passengerName[0] : '?')),
            title: Text('${debt.passengerName} owes ₹${debt.amountOwed.toStringAsFixed(2)}'),
            subtitle: Text('From trip: ${debt.tripName}'),
            trailing: Text(DateFormat.MMMd().format(debt.tripDate)),
            onTap: () {
              // This is a simplified navigation. A full implementation would
              // fetch the full Trip object from Firestore first.
              // For now, this demonstrates the user flow.
              // Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailScreen(trip: ??? )));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigate to trip ID: ${debt.tripId} to mark as paid.')),
              );
            },
          ),
        );
      },
    );
  }
}