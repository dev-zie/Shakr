import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<GeoPoint> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return await _getFallbackLocation();
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5), // Hızlı timeout, fallback'e düşsün
      );
      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      // Permission hatası veya timeout durumunda fallback kullan
      return await _getFallbackLocation();
    }
  }

  Future<GeoPoint> _getFallbackLocation() async {
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lat'] != null && data['lon'] != null) {
          return GeoPoint(data['lat'], data['lon']);
        }
      }
      throw Exception('IP api eksik veya hatali yanit verdi.');
    } catch (e) {
      throw Exception('Konum alınamadı (GPS ve IP fallback başarisiz): \$e');
    }
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }
}
