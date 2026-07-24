import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/fuel_log.dart';
import '../repositories/trip_repository.dart';

class AddFuelLogScreen extends ConsumerStatefulWidget {
  final FuelLog? initialLog;
  const AddFuelLogScreen({super.key, this.initialLog});

  @override
  ConsumerState<AddFuelLogScreen> createState() => _AddFuelLogScreenState();
}

class _AddFuelLogScreenState extends ConsumerState<AddFuelLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _costController;
  late final TextEditingController _odometerController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final log = widget.initialLog;
    _amountController = TextEditingController(text: log != null ? log.amountLiters.toString() : '');
    _costController = TextEditingController(text: log != null ? log.totalCost.toString() : '');
    _odometerController = TextEditingController(text: log?.odometerReading != null ? log!.odometerReading!.toString() : '');
    _selectedDate = log?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final double cost = double.tryParse(_costController.text) ?? 0.0;
      final double odometer = double.tryParse(_odometerController.text) ?? 0.0;

      if (amount <= 0 || cost <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount and cost.')));
        setState(() => _isLoading = false);
        return;
      }

      try {
        final repo = ref.read(tripRepositoryProvider);
        if (repo != null) {
          if (widget.initialLog != null) {
            await repo.updateManualFuelLog(
              logId: widget.initialLog!.id,
              amountLiters: amount,
              totalCost: cost,
              odometer: odometer > 0 ? odometer : null,
              date: _selectedDate,
            );
          } else {
            await repo.addManualFuelLog(
              amountLiters: amount,
              totalCost: cost,
              odometer: odometer > 0 ? odometer : null,
              date: _selectedDate,
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.initialLog != null ? 'Refuel log updated successfully!' : 'Refuel log saved successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save log: $e')),
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
    final isEditing = widget.initialLog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Refuel' : 'Add Refuel', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
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
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Fuel Amount (Liters)',
                        prefixIcon: Icon(Icons.local_gas_station_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the amount' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                        labelText: 'Total Cost (₹)',
                        prefixIcon: Icon(Icons.currency_rupee_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the cost' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _odometerController,
                      decoration: const InputDecoration(
                        labelText: 'Odometer Reading (km)',
                        prefixIcon: Icon(Icons.speed_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter the reading' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() => _selectedDate = pickedDate);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Refuel Date',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _saveLog,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEditing ? 'Update Refuel Log' : 'Save Refuel Log', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
