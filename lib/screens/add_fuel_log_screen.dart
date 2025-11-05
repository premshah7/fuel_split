import 'package:fuel_split/services/exports.dart';

class AddFuelLogScreen extends StatefulWidget {
  const AddFuelLogScreen({super.key});

  @override
  State<AddFuelLogScreen> createState() => _AddFuelLogScreenState();
}

class _AddFuelLogScreenState extends State<AddFuelLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();

  final DatabaseService _dbService = DatabaseService();

  @override
  void dispose() {
    _amountController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final double cost = double.tryParse(_costController.text) ?? 0.0;
      final double odometer = double.tryParse(_odometerController.text) ?? 0.0;

      if (amount <= 0 || cost <= 0) {
        messenger.showSnackBar(const SnackBar(content: Text('Please enter a valid amount and cost.')));
        return;
      }

      try {
        await _dbService.addManualFuelLog(
          amountLiters: amount,
          totalCost: cost,
          odometer: odometer,
        );

        messenger.showSnackBar(
          const SnackBar(content: Text('Fuel log saved successfully!')),
        );
        navigator.pop();
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to save log: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Fuel Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Fuel Amount (Liters)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter the amount' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Total Cost'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter the cost' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(labelText: 'Odometer Reading (km)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter the reading' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLog,
                child: const Text('Save Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}