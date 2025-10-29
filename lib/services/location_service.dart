import 'package:fuel_split/services/exports.dart';

class LocationService {
  /// Checks and requests location permissions. Returns true if granted.
  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You can show a snackbar or dialog here if you want
      // print("Location services are disabled.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // print("Location permissions are denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // print("Location permissions are permanently denied.");
      return false;
    }

    return true;
  }

  /// Converts GPS coordinates into a human-readable address string.
  static Future<String> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality}, ${place.administrativeArea}";
      }
      return "Address not found";
    } catch (e) {
      // print("Error getting address: $e");
      return "Could not get address";
    }
  }
}