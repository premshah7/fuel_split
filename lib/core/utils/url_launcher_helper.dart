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
  }) {
    return '''
🚗 *Trip Receipt: $startLocation to $endLocation*

Hey! Thanks for riding along. Here is the split for our recent trip:
- *Total Fuel Cost:* ₹${totalCost.toStringAsFixed(0)}
- *Your Share:* ₹${yourShare.toStringAsFixed(0)}

Please send ₹${yourShare.toStringAsFixed(0)} to $driverName when you get a chance!
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
