import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required super.id,
    required super.participants,
    required super.lastMessage,
    required super.lastMessageAt,
    required super.otherUserName,
    super.otherUserPhoto,
    super.otherUserVibes = const [],
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp).toDate(),
      otherUserName: map['otherUserName'] ?? '',
      otherUserPhoto: map['otherUserPhoto'],
      otherUserVibes: List<String>.from(map['otherUserVibes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'otherUserName': otherUserName,
      'otherUserPhoto': otherUserPhoto,
      'otherUserVibes': otherUserVibes,
    };
  }
}
