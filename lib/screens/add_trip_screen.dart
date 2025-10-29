import 'package:fuel_split/services/exports.dart';
import 'package:drift/drift.dart' as drift;

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _mileageController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  late final StreamSubscription _passengerSub;
  List<Passenger> _allPassengers = [];
  final List<Passenger> _selectedPassengers = [];
  bool _isRoundTrip = false;


  @override
  void initState() {
    super.initState();
    _passengerSub = database.watchAllPassengers().listen((passengers) {
      if (mounted) {
        setState(() {
          _allPassengers = passengers;
        });
      }
    });
    // Fetch all available passengers to display in the selector
    database.watchAllPassengers().first.then((passengers) {
      if (mounted) setState(() => _allPassengers = passengers);
    });
  }

  @override
  void dispose() {
    _passengerSub.cancel();
    _startLocationController.dispose();
    _endLocationController.dispose();
    _distanceController.dispose();
    _mileageController.dispose();
    _fuelPriceController.dispose();
    super.dispose();
  }

  void _showAddPassengerDialog() {
    final nameController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Passenger'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- OPTION 1: CHOOSE FROM CONTACTS ---
              ElevatedButton.icon(
                icon: const Icon(Icons.contact_phone_outlined),
                label: const Text('Choose from Contacts'),
                onPressed: () {
                  // Close this dialog first
                  Navigator.of(context).pop();
                  // Then, call our contact picker logic
                  ContactService.pickContactAndSave(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 8),

              // --- OPTION 2: ENTER MANUALLY ---
              Text('Enter Manually', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact Number (Optional)'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // This button is now only for the manual entry fields
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  final newPassenger = PassengersCompanion(
                    name: drift.Value(name),
                    contactNumber: drift.Value(contactController.text),
                  );
                  database.insertPassenger(newPassenger);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Manual Entry'),
            ),
          ],
        );
      },
    );
  }

  void _showCostInputDialogAndSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPassengers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one passenger.')),
        );
        return;
      }

      // Show a dialog to get the final cost info
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enter Cost Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Vehicle Mileage (km/l)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _fuelPriceController,
                decoration: const InputDecoration(labelText: 'Fuel Price (per liter)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                _calculateAndSaveTrip(); // Proceed to save
              },
              child: const Text('Calculate & Save'),
            ),
          ],
        ),
      );
    }
  }



  void _calculateAndSaveTrip() {
    // Get the single-journey distance from the user input
    double oneWayDistance = double.tryParse(_distanceController.text) ?? 0.0;
    final double mileage = double.tryParse(_mileageController.text) ?? 0.0;
    final double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;
    final double finalDistanceInKm = _isRoundTrip ? oneWayDistance * 2 : oneWayDistance;

    // Create a note to clarify the trip type
    final String tripNote = _isRoundTrip
        ? 'Round trip from ${_startLocationController.text} to ${_endLocationController.text} and back.'
        : '';

    if (finalDistanceInKm <= 0 || mileage <= 0 || fuelPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid numbers for distance and costs.')));
      return;
    }

    // All subsequent calculations now use the 'finalDistanceInKm'
    final double totalLitersUsed = finalDistanceInKm / mileage;
    final double totalFuelCost = totalLitersUsed * fuelPrice;
    final double costPerPassenger = totalFuelCost / _selectedPassengers.length;
    final newTrip = TripsCompanion(
      startLocation: drift.Value(_startLocationController.text),
      endLocation: drift.Value(_endLocationController.text),
      distance: drift.Value(finalDistanceInKm), // Save the final (possibly doubled) distance
      tripDate: drift.Value(DateTime.now()),
      isRoundTrip: drift.Value(_isRoundTrip), // Save the flag to the database
      notes: drift.Value(tripNote), // Add our descriptive note
    );

    database.createTripWithPassengers(newTrip, _selectedPassengers,costPerPassenger).then((tripId) {
      final consumptionLog = FuelLogsCompanion(
        amountLiters: drift.Value(totalLitersUsed),
        totalCost: drift.Value(totalFuelCost),
        logDate: drift.Value(DateTime.now()),
        isTripConsumption: drift.Value(true),
        tripId: drift.Value(tripId),
      );
      database.insertFuelLog(consumptionLog);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual trip saved successfully!')),
      );
      Navigator.of(context).pop(); // Go back to the trip list screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Trip Manually'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Trip Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startLocationController,
                decoration: const InputDecoration(labelText: 'Start Location'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endLocationController,
                decoration: const InputDecoration(labelText: 'End Location'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Round Trip'),
                value: _isRoundTrip,
                onChanged: (bool value) {
                  setState(() {
                    _isRoundTrip = value;
                  });
                },
                secondary: const Icon(Icons.sync_alt),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Passengers', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _showAddPassengerDialog,
                    tooltip: 'Add New Passenger',
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              if (_allPassengers.isEmpty)
                const Text('No passengers available. Please add passengers first.')
              else
                Wrap(
                  spacing: 8.0,
                  children: _allPassengers.map((passenger) {
                    final isSelected = _selectedPassengers.contains(passenger);
                    return FilterChip(
                      label: Text(passenger.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPassengers.add(passenger);
                          } else {
                            _selectedPassengers.remove(passenger);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showCostInputDialogAndSave,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Next: Add Costs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}