import 'package:fuel_split/services/exports.dart';

class SharingService {
  static Future<void> launchWhatsApp(BuildContext context, {required Passenger passenger, required String message}) async {
    if (passenger.contactNumber == null || passenger.contactNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No contact number for this passenger.')));
      return;
    }
    String phoneNumber = passenger.contactNumber!.replaceAll(RegExp(r'[^0-9]'), '');
    if (!phoneNumber.startsWith('91')) phoneNumber = '91$phoneNumber';
    final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WhatsApp. Error: $e')));
    }
  }
}