import 'package:fuel_split/services/exports.dart';

class AddTripScreen extends StatefulWidget {
  final Trip? tripToEdit;
  const AddTripScreen({super.key, this.tripToEdit});
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
  final _otherCostsController = TextEditingController(text: '0.0');

  late final StreamSubscription _passengerSub;
  List<Passenger> _allPassengers = [];
  final List<Passenger> _selectedPassengers = [];
  bool _isRoundTrip = false;

  final DatabaseService _dbService = DatabaseService();
  bool get _isEditMode => widget.tripToEdit != null;

  @override
  void initState() {
    super.initState();
    _passengerSub = _dbService.watchAllPassengers().listen((passengers) {
      if (mounted) setState(() => _allPassengers = passengers);
    });

    if (_isEditMode) {
      _startLocationController.text = widget.tripToEdit!.startLocation;
      _endLocationController.text = widget.tripToEdit!.endLocation;
      _distanceController.text = widget.tripToEdit!.distance.toString();
      _otherCostsController.text = widget.tripToEdit!.otherCosts.toString();
      _isRoundTrip = widget.tripToEdit!.isRoundTrip;
    }
  }

  @override
  void dispose() {
    _passengerSub.cancel();
    _startLocationController.dispose();
    _endLocationController.dispose();
    _distanceController.dispose();
    _mileageController.dispose();
    _fuelPriceController.dispose();
    _otherCostsController.dispose();
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
              ElevatedButton.icon(
                icon: const Icon(Icons.contact_phone_outlined),
                label: const Text('Choose from Contacts'),
                onPressed: () {
                  Navigator.of(context).pop();
                  ContactService.pickContactAndSave(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('OR')), Expanded(child: Divider())]),
              const SizedBox(height: 8),
              Text('Enter Manually', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Number (Optional)'), keyboardType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  _dbService.addPassenger(name: name, contactNumber: contactController.text);
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
      if (!_isEditMode && _selectedPassengers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one passenger.')));
        return;
      }
      if (_isEditMode) {
        _calculateAndSaveTrip();
        return;
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enter Fuel Price'),
          content: TextField(
            controller: _fuelPriceController,
            decoration: const InputDecoration(labelText: 'Fuel Price (per liter)'),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); _calculateAndSaveTrip(); }, child: const Text('Calculate & Save')),
          ],
        ),
      );
    }
  }

  void _calculateAndSaveTrip() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final oneWayDistance = double.tryParse(_distanceController.text) ?? 0.0;
    final otherCosts = double.tryParse(_otherCostsController.text) ?? 0.0;
    final finalDistanceInKm = _isRoundTrip && !_isEditMode ? oneWayDistance * 2 : oneWayDistance;
    final tripNote = _isRoundTrip ? 'Round trip from ${_startLocationController.text} to ${_endLocationController.text} and back.' : '';

    if (finalDistanceInKm <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter a valid distance.')));
      return;
    }

    if (_isEditMode) {
      try {
        await _dbService.updateTrip(widget.tripToEdit!.id, {
          'startLocation': _startLocationController.text,
          'endLocation': _endLocationController.text,
          'distance': finalDistanceInKm,
          'isRoundTrip': _isRoundTrip,
          'notes': tripNote,
          'otherCosts': otherCosts,
        });
        messenger.showSnackBar(const SnackBar(content: Text('Trip updated successfully!')));
        navigator.pop();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } else {
      final mileage = double.tryParse(_mileageController.text) ?? 0.0;
      final fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;
      if (mileage <= 0 || fuelPrice <= 0) {
        messenger.showSnackBar(const SnackBar(content: Text('Please enter valid mileage and price.')));
        return;
      }

      final totalLitersUsed = finalDistanceInKm / mileage;
      final totalFuelCost = totalLitersUsed * fuelPrice;

      try {
        await _dbService.createTripWithLog(
          startLocation: _startLocationController.text,
          endLocation: _endLocationController.text,
          distance: finalDistanceInKm,
          isRoundTrip: _isRoundTrip,
          notes: tripNote,
          passengers: _selectedPassengers,
          totalFuelCost: totalFuelCost,
          totalLitersUsed: totalLitersUsed,
          otherCosts: otherCosts,
        );
        messenger.showSnackBar(const SnackBar(content: Text('Manual trip saved successfully!')));
        navigator.pop();
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Failed to save trip: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Trip' : 'Add Trip Manually')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _startLocationController, decoration: const InputDecoration(labelText: 'Start Location'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _endLocationController, decoration: const InputDecoration(labelText: 'End Location'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              if (!_isEditMode)
                TextFormField(controller: _mileageController, decoration: const InputDecoration(labelText: 'Vehicle Mileage (km/l)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              if (!_isEditMode) const SizedBox(height: 16),
              TextFormField(controller: _distanceController, decoration: InputDecoration(labelText: _isEditMode ? 'Total Distance (km)' : 'Distance (km) - One Way'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 8),
              SwitchListTile(title: const Text('Round Trip'), value: _isRoundTrip, onChanged: (bool value) => setState(() => _isRoundTrip = value), secondary: const Icon(Icons.sync_alt)),
              const SizedBox(height: 16),
              TextFormField(controller: _otherCostsController, decoration: const InputDecoration(labelText: 'Other Costs (Tolls, etc.)'), keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              if (!_isEditMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Passengers', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: const Icon(Icons.add_circle), onPressed: _showAddPassengerDialog, color: Theme.of(context).primaryColor, tooltip: 'Add New Passenger'),
                  ],
                ),
                if (_allPassengers.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('No passengers available. Tap + to add one.'))
                else Wrap(
                  spacing: 8.0,
                  children: _allPassengers.map((passenger) {
                    final isSelected = _selectedPassengers.contains(passenger);
                    return FilterChip(
                      label: Text(passenger.name),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => selected ? _selectedPassengers.add(passenger) : _selectedPassengers.remove(passenger)),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showCostInputDialogAndSave,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isEditMode ? 'Save Changes' : 'Next: Add Fuel Price'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}