import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repositories/trip_repository.dart';

class AddFuelLogScreen extends ConsumerStatefulWidget {
  const AddFuelLogScreen({super.key});

  @override
  ConsumerState<AddFuelLogScreen> createState() => _AddFuelLogScreenState();
}

class _AddFuelLogScreenState extends ConsumerState<AddFuelLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  bool _isLoading = false;

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
          await repo.addManualFuelLog(
            amountLiters: amount,
            totalCost: cost,
            odometer: odometer,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fuel log saved successfully!')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Refuel', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    : const Text('Save Refuel Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
