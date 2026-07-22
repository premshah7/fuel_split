import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../repositories/trip_repository.dart';
import '../models/trip.dart';
import '../../../core/utils/location_helper.dart';

class EditTripScreen extends ConsumerStatefulWidget {
  final String tripId;
  final Trip? initialTrip;

  const EditTripScreen({
    super.key,
    required this.tripId,
    this.initialTrip,
  });

  @override
  ConsumerState<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _startLocationController;
  late final TextEditingController _endLocationController;
  late final TextEditingController _distanceController;
  late final TextEditingController _otherCostsController;
  late final TextEditingController _notesController;
  
  bool _isRoundTrip = false;
  bool _isLoading = false;
  bool _isLoadingLocationStart = false;
  bool _isLoadingLocationEnd = false;
  Trip? _loadedTrip;

  @override
  void initState() {
    super.initState();
    final trip = widget.initialTrip;
    _loadedTrip = trip;

    _startLocationController = TextEditingController(text: trip?.startLocation ?? '');
    _endLocationController = TextEditingController(text: trip?.endLocation ?? '');
    _distanceController = TextEditingController(text: trip?.distance.toString() ?? '');
    _otherCostsController = TextEditingController(text: trip?.otherCosts.toString() ?? '0.0');
    _notesController = TextEditingController(text: trip?.notes ?? '');
    _isRoundTrip = trip?.isRoundTrip ?? false;

    if (trip == null) {
      _loadTripFromDatabase();
    }
  }

  Future<void> _loadTripFromDatabase() async {
    final repo = ref.read(tripRepositoryProvider);
    if (repo == null) return;
    
    // We get the stream or first value
    final trips = await repo.watchAllTrips().first;
    final trip = trips.firstWhere((t) => t.id == widget.tripId, orElse: () => Trip(
      id: '', startLocation: '', endLocation: '', distance: 0, tripDate: DateTime.now(), isRoundTrip: false
    ));

    if (trip.id.isNotEmpty && mounted) {
      setState(() {
        _loadedTrip = trip;
        _startLocationController.text = trip.startLocation;
        _endLocationController.text = trip.endLocation;
        _distanceController.text = trip.distance.toString();
        _otherCostsController.text = trip.otherCosts.toString();
        _notesController.text = trip.notes ?? '';
        _isRoundTrip = trip.isRoundTrip;
      });
    }
  }

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    _distanceController.dispose();
    _otherCostsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocationForStart() async {
    setState(() => _isLoadingLocationStart = true);
    final address = await LocationHelper.getCurrentAddress(context);
    if (address != null && mounted) {
      setState(() {
        _startLocationController.text = address;
      });
    }
    if (mounted) {
      setState(() => _isLoadingLocationStart = false);
    }
  }

  Future<void> _fetchCurrentLocationForEnd() async {
    setState(() => _isLoadingLocationEnd = true);
    final address = await LocationHelper.getCurrentAddress(context);
    if (address != null && mounted) {
      setState(() {
        _endLocationController.text = address;
      });
    }
    if (mounted) {
      setState(() => _isLoadingLocationEnd = false);
    }
  }

  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      if (_loadedTrip == null) return;

      setState(() => _isLoading = true);

      final distance = double.tryParse(_distanceController.text) ?? 0.0;
      final otherCosts = double.tryParse(_otherCostsController.text) ?? 0.0;

      try {
        final repo = ref.read(tripRepositoryProvider);
        if (repo != null) {
          await repo.updateTripAndRecalculateCosts(
            originalTrip: _loadedTrip!,
            newDistance: distance,
            newIsRoundTrip: _isRoundTrip,
            newStartLocation: _startLocationController.text.trim(),
            newEndLocation: _endLocationController.text.trim(),
            newNotes: _notesController.text.trim(),
            newOtherCosts: otherCosts,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip updated successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update trip: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loadedTrip == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Column(
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
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                  suffixIcon: _isLoadingLocationStart
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
                                  suffixIcon: _isLoadingLocationEnd
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
                          TextFormField(
                            controller: _distanceController,
                            decoration: const InputDecoration(
                              labelText: 'Distance (km)',
                              prefixIcon: Icon(Icons.straighten_outlined),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) => value == null || value.isEmpty ? 'Please enter the distance' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otherCostsController,
                            decoration: const InputDecoration(
                              labelText: 'Other Costs (₹)',
                              prefixIcon: Icon(Icons.currency_rupee_outlined),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes / Description',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Round Trip', style: TextStyle(fontWeight: FontWeight.bold)),
                            value: _isRoundTrip,
                            onChanged: (val) {
                              setState(() {
                                _isRoundTrip = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveTrip,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
