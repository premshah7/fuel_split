import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> launchWhatsApp(String? phone, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    Uri url;

    if (phone != null && phone.isNotEmpty) {
      // Remove any non-numeric characters for the phone number
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      url = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
    } else {
      url = Uri.parse('whatsapp://send?text=$encodedMessage');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to web if WhatsApp app is not installed
      final fallbackUrl = Uri.parse('https://wa.me/?text=$encodedMessage');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp.';
      }
    }
  }

  static String generateTripReceiptMessage({
    required String driverName,
    required String startLocation,
    required String endLocation,
    required double totalCost,
    required double yourShare,
    required DateTime tripDate,
    required double distance,
  }) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(tripDate);
    return '''
🚗 *Trip Summary* 🚗
--------------------
📍 *From:* $startLocation
📍 *To:* $endLocation
🗓️ *Date:* $dateStr
📐 *Distance:* ${distance.toStringAsFixed(1)} km
💰 *Total Cost:* ₹${totalCost.toStringAsFixed(2)}
💰 *Your Share:* *₹${yourShare.toStringAsFixed(2)}*

Please send ₹${yourShare.toStringAsFixed(2)} to $driverName when you get a chance!
''';
  }

  static String generateTotalDebtMessage({
    required String driverName,
    required double totalOwed,
  }) {
    return '''
👋 *Payment Reminder*

Hey! Just a quick reminder that you have an outstanding balance for recent trips.
- *Total Owed:* ₹${totalOwed.toStringAsFixed(0)}

Please send ₹${totalOwed.toStringAsFixed(0)} to $driverName when you get a chance!
''';
  }
}
