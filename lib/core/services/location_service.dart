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
        return LocationResult(location: await _getCityLocation());
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LocationResult(
        location: GeoPoint(position.latitude, position.longitude),
      );
    } catch (_) {
      return LocationResult(location: await _getCityLocation());
    }
  }

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<GeoPoint> _getCityLocation() async {
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['lat'] != null && data['lon'] != null) {
          return GeoPoint(data['lat'] as double, data['lon'] as double);
        }
      }
    } catch (_) {}

    return const GeoPoint(0, 0);
  }
}
