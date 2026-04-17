import 'package:cloud_firestore/cloud_firestore.dart';

class LocationResult {
  final GeoPoint location;
  final bool isFallback;

  const LocationResult({required this.location, required this.isFallback});
}
