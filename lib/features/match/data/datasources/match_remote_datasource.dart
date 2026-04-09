import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/match/data/models/match_model.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

class MatchRemoteDatasource {
  final FirebaseFirestore db;

  MatchRemoteDatasource({required this.db});

  Stream<MatchEntity?> watchMatch(String uid) {
    return db
        .collection('matches')
        .where('users', arrayContains: uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return MatchModel.fromMap(doc.data(), doc.id);
    });
  }
}