import 'package:fuel_split/services/exports.dart';
import 'package:drift/drift.dart' as drift;
import 'package:permission_handler/permission_handler.dart';

class ContactService {
  static Future<void> pickContactAndSave(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      debugPrint("DEBUG: Requesting contact permission via permission_handler...");
      // Use the new, more reliable package to ask for permission.
      PermissionStatus status = await Permission.contacts.request();
      debugPrint("DEBUG: permission_handler status: $status");

      if (status.isGranted) {
        debugPrint("DEBUG: Permission is granted. Opening external contact picker...");
        Contact? contact = await FlutterContacts.openExternalPick();

        if (contact != null) {
          debugPrint("DEBUG: SUCCESS! Contact selected: ${contact.displayName}");
          String name = contact.displayName;
          String? number = contact.phones.isNotEmpty ? contact.phones.first.number : null;

          final newPassenger = PassengersCompanion(
            name: drift.Value(name),
            contactNumber: drift.Value(number),
          );
          await database.insertPassenger(newPassenger);

          messenger.showSnackBar(
            SnackBar(content: Text('$name was added from your contacts.')),
          );
        } else {
          debugPrint("DEBUG: Contact picker returned NULL.");
        }
      } else if (status.isPermanentlyDenied) {
        debugPrint("DEBUG: Permission is permanently denied. Opening app settings...");
        messenger.showSnackBar(const SnackBar(content: Text('Contact permission is needed. Please enable it in app settings.')));
        await openAppSettings();
      }
      else {
        debugPrint("DEBUG: Permission was denied.");
        messenger.showSnackBar(
          const SnackBar(content: Text('Permission to access contacts was denied.')),
        );
      }
    } catch (e, s) {
      debugPrint("DEBUG: CRITICAL ERROR in ContactService: $e");
      debugPrintStack(stackTrace: s);
    }
  }
}