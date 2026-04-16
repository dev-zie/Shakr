import 'package:cloud_firestore/cloud_firestore.dart';

enum ShakeStatus { waiting, active, matched, unknown }

extension ShakeStatusExt on ShakeStatus {
  String get name {
    switch (this) {
      case ShakeStatus.waiting:
        return 'waiting';
      case ShakeStatus.active:
        return 'active';
      case ShakeStatus.matched:
        return 'matched';
      default:
        return 'unknown';
    }
  }

  static ShakeStatus fromString(String val) {
    switch (val) {
      case 'waiting':
        return ShakeStatus.waiting;
      case 'active':
        return ShakeStatus.active;
      case 'matched':
        return ShakeStatus.matched;
      default:
        return ShakeStatus.unknown;
    }
  }
}

class ShakeEntity {
  final String uid;
  final GeoPoint location;
  final ShakeStatus status;
  final DateTime timestamp;

  ShakeEntity({
    required this.uid,
    required this.location,
    required this.status,
    required this.timestamp,
  });
}
