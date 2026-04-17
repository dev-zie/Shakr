import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shakr/core/models/location_result.dart';

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final fallback = await _getFallbackLocation();
        return LocationResult(location: fallback, isFallback: true);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LocationResult(
        location: GeoPoint(position.latitude, position.longitude),
        isFallback: false,
      );
    } catch (e) {
      final fallback = await _getFallbackLocation();
      return LocationResult(location: fallback, isFallback: true);
    }
  }

  Future<GeoPoint> _getFallbackLocation() async {
    try {
      final ipRes = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 5));

      String ip = '';
      if (ipRes.statusCode == 200) {
        ip = (jsonDecode(ipRes.body) as Map<String, dynamic>)['ip'] as String? ?? '';
      }

      final url = ip.isNotEmpty
          ? 'http://ip-api.com/json/$ip?fields=city,lat,lon'
          : 'http://ip-api.com/json/?fields=city,lat,lon';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['lat'] != null && data['lon'] != null) {
          return GeoPoint(data['lat'] as double, data['lon'] as double);
        }
      }
      throw Exception('IP api geçersiz yanıt verdi.');
    } catch (e) {
      throw Exception('Konum alınamadı (GPS ve IP fallback başarısız): $e');
    }
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }
}
