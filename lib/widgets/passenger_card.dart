// import 'package:ai_studio_distance/services/exports.dart';
// import 'package:intl/intl.dart';
//
// class PassengerCard extends StatefulWidget {
//   final Passenger passenger;
//   final double totalCost;
//   final VoidCallback onDelete;
//
//   const PassengerCard({
//     super.key,
//     required this.passenger,
//     required this.totalCost,
//     required this.onDelete,
//   });
//
//   @override
//   State<PassengerCard> createState() => _PassengerCardState();
// }
//
// class _PassengerCardState extends State<PassengerCard> {
//   // A future to hold the trip history. It's nullable so we can lazy-load it.
//   Future<List<PassengerTripDetail>>? _tripHistoryFuture;
//
//   // This method is called when the user expands the tile.
//   void _loadTripHistory() {
//     // We only fetch the data once. If the future is already set, we do nothing.
//     if (_tripHistoryFuture == null) {
//       setState(() {
//         _tripHistoryFuture = DatabaseService.getTripHistoryForPassenger(widget.passenger.id);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool hasHistory = widget.totalCost > 0;
//
//     return Card(
//       // We use a ClipRRect to keep the rounded corners when the tile expands
//       clipBehavior: Clip.antiAlias,
//       child: ExpansionTile(
//         title: _buildSummary(), // The part that's always visible
//         onExpansionChanged: (isExpanding) {
//           if (isExpanding) {
//             _loadTripHistory(); // Load the data only when the user expands
//           }
//         },
//         // The children are the detailed trip history, wrapped in a FutureBuilder
//         children: [
//           if (_tripHistoryFuture != null)
//             FutureBuilder<List<PassengerTripDetail>>(
//               future: _tripHistoryFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const ListTile(title: Text('No trip details found.'));
//                 }
//                 final tripHistory = snapshot.data!;
//                 // Build a list of tiles, one for each trip
//                 return Column(
//                   children: tripHistory.map((detail) => _buildTripDetailTile(detail)).toList(),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   // This is the summary part of the card (the un-expanded state)
//   Widget _buildSummary() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
//                 child: Text(widget.passenger.name[0]),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(widget.passenger.name, style: Theme.of(context).textTheme.titleMedium),
//                     if (widget.passenger.contactNumber != null)
//                       Text(widget.passenger.contactNumber!, style: Theme.of(context).textTheme.bodySmall),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//                 onPressed: widget.onDelete,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Chip(
//               avatar: Icon(Icons.receipt_long_outlined, color: Theme.of(context).primaryColor),
//               label: Text(
//                 widget.totalCost > 0
//                     ? 'Lifetime total: ₹${widget.totalCost.toStringAsFixed(2)}'
//                     : 'No trip history yet',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // This builds a single row for the expanded trip history list
//   Widget _buildTripDetailTile(PassengerTripDetail detail) {
//     return Container(
//       color: Colors.black.withOpacity(0.03),
//       child: ListTile(
//         title: Text('${detail.trip.startLocation} → ${detail.trip.endLocation}'),
//         subtitle: Text(DateFormat.yMMMd().format(detail.trip.tripDate)),
//         trailing: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '₹${detail.tripPassenger.costShare.toStringAsFixed(2)}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               detail.tripPassenger.isPaid ? 'Paid' : 'Unpaid',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: detail.tripPassenger.isPaid ? Colors.green : Colors.orange,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }