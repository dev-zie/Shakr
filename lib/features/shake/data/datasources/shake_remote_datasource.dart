import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/core/utils/geohash_utils.dart';
import 'package:shakr/features/shake/data/models/shake_model.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';

class ShakeRemoteDatasource {
  final FirebaseFirestore db;

  ShakeRemoteDatasource({required this.db});

  Future<void> recordShake(ShakeEntity shake) async {
    final geohash = GeoHashUtils.encode(
      shake.location.latitude,
      shake.location.longitude,
    );
    final shakeModel = ShakeModel(
      uid: shake.uid,
      location: shake.location,
      status: shake.status,
      timestamp: shake.timestamp,
    );
    await db.collection('shakes').doc(shake.uid).set({
      ...shakeModel.toMap(),
      'geohash': geohash,
    });
  }

  Future<void> deleteShake(String uid) async {
    await db.collection('shakes').doc(uid).delete();
  }

  /// Kullanıcının aktif bir eşleşmesi olup olmadığını kontrol eder.
  /// Sallama kaydedilmeden önce çağrılır; aktif eşleşme varsa yeni shake engellenir.
  Future<bool> hasActiveMatch(String uid) async {
    final snapshot = await db
        .collection('matches')
        .where('users', arrayContains: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
