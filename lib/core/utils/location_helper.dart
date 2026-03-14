import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  /// Fetches the current location and returns a human-readable address.
  static Future<String?> getCurrentAddress(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable them in settings.')),
          );
        }
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied.')),
          );
        }
        return null;
      }

      // Permissions are granted and we can continue accessing the position of the device.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fetching current location...')),
        );
      }

      Position position = await Geolocator.getCurrentPosition();

      // Convert coordinates to an address
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Construct a readable address (e.g., "1600 Amphitheatre Pkwy, Mountain View")
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
        if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
        
        return addressParts.join(', ');
      }
      
      return '${position.latitude}, ${position.longitude}'; // Fallback to coordinates
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
      return null;
    }
  }

  /// Searches for matching locations based on a string query using Photon (OpenStreetMap).
  static Future<List<String>> searchLocations(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=5');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        List<String> results = [];
        for (var feature in features) {
          final properties = feature['properties'];
          
          List<String> parts = [];
          
          if (properties['name'] != null) {
            parts.add(properties['name'].toString());
          }
          if (properties['street'] != null) {
            parts.add(properties['street'].toString());
          }
          if (properties['district'] != null && properties['district'] != properties['name']) {
            parts.add(properties['district'].toString());
          }
          if (properties['city'] != null && properties['city'] != properties['name']) {
            parts.add(properties['city'].toString());
          }
          if (properties['state'] != null && properties['state'] != properties['name']) {
            parts.add(properties['state'].toString());
          }
          if (properties['country'] != null) {
            parts.add(properties['country'].toString());
          }
          
          // Deduplicate the current parts and combine them
          final uniqueParts = parts.toSet().toList();
          final formattedLocation = uniqueParts.join(', ');
          
          if (formattedLocation.isNotEmpty && !results.contains(formattedLocation)) {
            results.add(formattedLocation);
          }
        }
        
        return results;
      }
    } catch (e) {
      debugPrint('Error searching locations: $e');
    }
    
    return [];
  }
}
