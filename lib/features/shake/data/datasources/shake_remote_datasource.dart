import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/shake/data/models/shake_model.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';

class ShakeRemoteDatasource {
  final FirebaseFirestore db;

  ShakeRemoteDatasource({required this.db});

  Future<void> recordShake(ShakeEntity shake) async {
    final shakeModel = ShakeModel(
      uid: shake.uid,
      location: shake.location,
      status: shake.status,
      timestamp: shake.timestamp,
    );

    await db.collection('shakes').doc(shake.uid).set(shakeModel.toMap());
  }

  Future<void> deleteShake(String uid) async {
    await db.collection('shakes').doc(uid).delete();
  }
}
