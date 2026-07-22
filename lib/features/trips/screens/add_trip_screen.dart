import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../repositories/trip_repository.dart';
import '../models/trip.dart';
// Removed fuel_log.dart import
import '../../passengers/models/passenger.dart';
import '../../passengers/repositories/passenger_repository.dart';
import '../../../core/utils/contact_helper.dart';
import '../../../core/utils/location_helper.dart';

class CurrentStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

final currentStepProvider = NotifierProvider<CurrentStepNotifier, int>(CurrentStepNotifier.new);

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key});

  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentStepProvider.notifier).reset();
    });
  }

  // Step 1: Route Controllers
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _distanceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Step 2: Fuel Controllers
  final _fuelPriceController = TextEditingController();
  final _mileageController = TextEditingController();

  // Step 3: Passengers State
  final List<Passenger> _selectedPassengers = [];

  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    _distanceController.dispose();
    _fuelPriceController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocationForStart() async {
    setState(() => _isLoadingLocation = true);
    
    final address = await LocationHelper.getCurrentAddress(context);
    
    if (address != null && mounted) {
      setState(() {
        _startLocationController.text = address;
      });
    }
    
    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  bool _isLoadingEndLocation = false;

  Future<void> _fetchCurrentLocationForEnd() async {
    setState(() => _isLoadingEndLocation = true);
    
    final address = await LocationHelper.getCurrentAddress(context);
    
    if (address != null && mounted) {
      setState(() {
        _endLocationController.text = address;
      });
    }
    
    if (mounted) {
      setState(() => _isLoadingEndLocation = false);
    }
  }

  void _showAddPassengerSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New Passenger', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () async {
                      final contact = await ContactHelper.pickContact(context);
                      if (contact != null) {
                        nameController.text = contact.displayName ?? '';
                        if (contact.phones.isNotEmpty) {
                          phoneController.text = contact.phones.first.number;
                        }
                      }
                    },
                    icon: const Icon(Icons.contacts_rounded),
                    label: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (Optional)', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  await ref.read(passengerRepositoryProvider)?.addPassenger(
                    name: nameController.text.trim(),
                    contactNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Passenger'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _saveTrip() async {
    if (_startLocationController.text.isEmpty || 
        _endLocationController.text.isEmpty || 
        _distanceController.text.isEmpty ||
        _fuelPriceController.text.isEmpty ||
        _mileageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all required fields.')));
      return;
    }

    final distance = double.tryParse(_distanceController.text) ?? 0.0;
    final fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;
    final mileage = double.tryParse(_mileageController.text) ?? 0.0;

    double fuelVolume = 0.0;
    double totalCost = 0.0;
    
    if (mileage > 0) {
      fuelVolume = distance / mileage;
      totalCost = fuelVolume * fuelPrice;
    }

    // Build Trip Object
    final trip = Trip(
      id: '', // Firestore will generate
      startLocation: _startLocationController.text.trim(),
      endLocation: _endLocationController.text.trim(),
      tripDate: _selectedDate,
      distance: distance,
      isRoundTrip: false, // Defaulting to false for this MVP version
      totalCost: totalCost,
      passengerCount: _selectedPassengers.length + 1, // Includes driver
    );

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // We need to implement createTripWithRelations in TripRepository
      // For now we will just create the bare trip
      await ref.read(tripRepositoryProvider)?.createTripWithRelations(
        trip: trip,
        volume: fuelVolume,
        passengers: _selectedPassengers,
      );
      
      if (mounted) {
        Navigator.pop(context); // Pop loading
        context.pop(); // Pop screen
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving trip: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(currentStepProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Trip', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(currentStepProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: currentStep,
        elevation: 0,
        margin: EdgeInsets.zero,
        controlsBuilder: (context, details) {
          final isLastStep = currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: details.onStepContinue,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isLastStep ? 'Save Trip' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                if (currentStep != 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        onStepContinue: () {
          if (currentStep < 2) {
            ref.read(currentStepProvider.notifier).increment();
          } else {
            _saveTrip();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            ref.read(currentStepProvider.notifier).decrement();
          }
        },
        steps: [
          Step(
            title: const Text('Route'),
            isActive: currentStep >= 0,
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildRouteForm().animate().fadeIn().slideX(begin: 0.1, end: 0),
          ),
          Step(
            title: const Text('Fuel'),
            isActive: currentStep >= 1,
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildFuelForm().animate().fadeIn().slideX(begin: 0.1, end: 0),
          ),
          Step(
            title: const Text('Crew'),
            isActive: currentStep >= 2,
            content: _buildPassengersForm().animate().fadeIn().slideX(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TypeAheadField<String>(
          controller: _startLocationController,
          suggestionsCallback: (pattern) async {
            if (pattern.length < 3) return [];
            return await LocationHelper.searchLocations(pattern);
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Start Location',
                prefixIcon: const Icon(Icons.my_location),
                suffixIcon: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.gps_fixed),
                        onPressed: _fetchCurrentLocationForStart,
                        tooltip: 'Fetch Current Location',
                      ),
              ),
            );
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(suggestion),
            );
          },
          onSelected: (suggestion) {
            _startLocationController.text = suggestion;
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No locations found'),
          ),
        ),
        const SizedBox(height: 16),
        TypeAheadField<String>(
          controller: _endLocationController,
          suggestionsCallback: (pattern) async {
            if (pattern.length < 3) return [];
            return await LocationHelper.searchLocations(pattern);
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Destination',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _isLoadingEndLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.gps_fixed),
                        onPressed: _fetchCurrentLocationForEnd,
                        tooltip: 'Fetch Current Location',
                      ),
              ),
            );
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(suggestion),
            );
          },
          onSelected: (suggestion) {
            _endLocationController.text = suggestion;
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No locations found'),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _distanceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Distance (km)', prefixIcon: Icon(Icons.straighten)),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)),
            child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _fuelPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Fuel Price (per Liter)', prefixIcon: Icon(Icons.currency_rupee)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _mileageController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Vehicle Mileage (km/L)', prefixIcon: Icon(Icons.speed)),
        ),
      ],
    );
  }

  Widget _buildPassengersForm() {
    final passengersAsync = ref.watch(allPassengersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Who rode with you?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select passengers to split the fuel cost evenly.', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 16),
        
        passengersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (passengers) {
            if (passengers.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('No passengers saved yet.', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _showAddPassengerSheet, 
                      icon: const Icon(Icons.add), 
                      label: const Text('Add Passenger'),
                    )
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: passengers.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                itemBuilder: (context, index) {
                  final passenger = passengers[index];
                  final isSelected = _selectedPassengers.any((p) => p.id == passenger.id);
                  
                  return CheckboxListTile(
                    title: Text(passenger.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: passenger.contactNumber != null ? Text(passenger.contactNumber!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)) : null,
                    value: isSelected,
                    activeColor: theme.primaryColor,
                    secondary: CircleAvatar(
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      child: Text(passenger.name[0].toUpperCase(), style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedPassengers.add(passenger);
                        } else {
                          _selectedPassengers.removeWhere((p) => p.id == passenger.id);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
