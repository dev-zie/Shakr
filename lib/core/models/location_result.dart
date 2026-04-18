import 'package:cloud_firestore/cloud_firestore.dart';

class LocationResult {
  final GeoPoint location;

  const LocationResult({required this.location});
}
