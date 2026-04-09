import 'package:cloud_firestore/cloud_firestore.dart';

class ShakeEntity {
  final String uid;
  final GeoPoint location;
  final String status;
  final DateTime timestamp;

  ShakeEntity({
    required this.uid,
    required this.location,
    required this.status,
    required this.timestamp,
  });
}
