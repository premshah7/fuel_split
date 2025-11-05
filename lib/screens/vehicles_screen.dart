// import 'package:fuel_split/services/exports.dart';
//
// class VehiclesScreen extends StatefulWidget {
//   const VehiclesScreen({super.key});
//
//   @override
//   State<VehiclesScreen> createState() => _VehiclesScreenState();
// }
//
// class _VehiclesScreenState extends State<VehiclesScreen> {
//   void _showAddVehicleDialog() {
//     final nameController = TextEditingController();
//     final mileageController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Add New Vehicle'),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Vehicle Name (e.g., My Car)')),
//           TextField(controller: mileageController, decoration: const InputDecoration(labelText: 'Default Mileage (km/l)'), keyboardType: TextInputType.number),
//         ]),
//         actions: [
//           TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               final name = nameController.text;
//               final mileage = double.tryParse(mileageController.text) ?? 0.0;
//               if (name.isNotEmpty && mileage > 0) {
//                 final newVehicle = VehiclesCompanion(
//                   name: Value(name),
//                   defaultMileage: Value(mileage),
//                 );
//                 database.insertVehicle(newVehicle);
//                 Navigator.of(ctx).pop();
//               }
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Vehicles'),
//       ),
//       body: StreamBuilder<List<Vehicle>>(
//         stream: database.watchAllVehicles(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//           final vehicles = snapshot.data ?? [];
//           if (vehicles.isEmpty) {
//             return const EmptyStateWidget(icon: Icons.no_transfer, message: 'No vehicles added yet.');
//           }
//           return ListView.builder(
//             itemCount: vehicles.length,
//             itemBuilder: (context, index) {
//               final vehicle = vehicles[index];
//               return Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.directions_car),
//                   title: Text(vehicle.name),
//                   subtitle: Text('Avg. ${vehicle.defaultMileage} km/l'),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//                     onPressed: () => database.deleteVehicle(vehicle.id),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddVehicleDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }