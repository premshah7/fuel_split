import 'package:fuel_split/screens/payment_screen.dart';
import 'package:fuel_split/services/exports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  void _changeTab(int index) {
    setState(() { _selectedIndex = index; });
  }

  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = [
      TripListScreen(onNavigateToPassengers: _changeTab),
      const PaymentsScreen(),
      const FuelLogListScreen(),
      const PassengerListScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), label: 'Payments'), // <-- NEW TAB
          BottomNavigationBarItem(icon: Icon(Icons.local_gas_station_outlined), label: 'Fuel'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Passengers'),
        ],
        currentIndex: _selectedIndex,
        onTap: _changeTab,
      ),
    );
  }
}