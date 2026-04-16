import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  MatchModel({
    required super.matchId,
    required super.user1Id,
    required super.user2Id,
    required super.createdAt,
    super.chatStartedAt,
    required super.status,
    required super.user1Vibes,
    required super.user2Vibes,
    super.user1KeepConnection = false,
    super.user2KeepConnection = false,
    super.user1Accepted = false,
    super.user2Accepted = false,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      matchId: id,
      user1Id: map['user1'],
      user2Id: map['user2'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      chatStartedAt: map['chatStartedAt'] != null
          ? (map['chatStartedAt'] as Timestamp).toDate()
          : null,
      status: MatchStatusExt.fromString(map['status'] ?? ''),
      user1Vibes: List<String>.from(map['user1Vibes'] ?? []),
      user2Vibes: List<String>.from(map['user2Vibes'] ?? []),
      user1KeepConnection: map['user1KeepConnection'] ?? false,
      user2KeepConnection: map['user2KeepConnection'] ?? false,
      user1Accepted: map['user1Accepted'] ?? false,
      user2Accepted: map['user2Accepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1': user1Id,
      'user2': user2Id,
      'users': [user1Id, user2Id],
      'createdAt': Timestamp.fromDate(createdAt),
      'chatStartedAt':
          chatStartedAt != null ? Timestamp.fromDate(chatStartedAt!) : null,
      'status': status.name,
      'user1KeepConnection': user1KeepConnection,
      'user2KeepConnection': user2KeepConnection,
      'user1Accepted': user1Accepted,
      'user2Accepted': user2Accepted,
      'user1Vibes': user1Vibes,
      'user2Vibes': user2Vibes,
    };
  }
}
