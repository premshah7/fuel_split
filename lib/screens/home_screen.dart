import 'package:fuel_split/services/exports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // NEW: We define a method to change the tab
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // MODIFIED: The list of pages is no longer static or const.
  // We will initialize it in initState to pass the callback function.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // We create the list of pages here, passing the _changeTab function
    // as a callback to the TripListScreen.
    _pages = [
      TripListScreen(onNavigateToPassengers: _changeTab), // Pass the function
      const FuelLogListScreen(),
      const PassengerListScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body now uses the _pages list we created in initState
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station_outlined),
            activeIcon: Icon(Icons.local_gas_station),
            label: 'Fuel Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Passengers',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _changeTab, // The tap handler is now our new function
      ),
    );
  }
}