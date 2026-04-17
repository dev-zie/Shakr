import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';

class ShakeModel extends ShakeEntity {
  ShakeModel({
    required super.uid,
    required super.location,
    required super.status,
    required super.timestamp,
  });

  factory ShakeModel.fromMap(Map<String, dynamic> map, String id) {
    return ShakeModel(
      uid: id,
      location: map['location'],
      status: ShakeStatusExt.fromString(map['status'] ?? ''),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
