import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.matchId,
    required super.user1Id,
    required super.user2Id,
    required super.createdAt,
    required super.status,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      matchId: id,
      user1Id: map['user1'],
      user2Id: map['user2'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1': user1Id,
      'user2': user2Id,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
