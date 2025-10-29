import 'package:fuel_split/services/exports.dart';
import 'package:drift/drift.dart' as drift;

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

  @override
  void dispose() {
    _amountController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  void _saveLog() {
    if (_formKey.currentState!.validate()) {
      final newLog = FuelLogsCompanion(
        amountLiters: drift.Value(double.parse(_amountController.text)),
        totalCost: drift.Value(double.parse(_costController.text)),
        odometerReading: drift.Value(double.parse(_odometerController.text)),
        logDate: drift.Value(DateTime.now()),
        isTripConsumption: const drift.Value(false),
      );

      database.insertFuelLog(newLog).then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fuel log saved!')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save log: $error')),
        );
      });
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