import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<GeoPoint> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Konum izni verilmedi');
      }
      final position = await Geolocator.getCurrentPosition();
      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Konum alinamadi: $e');
    }
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }
}
