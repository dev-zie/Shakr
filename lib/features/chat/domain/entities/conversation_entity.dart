class ConversationEntity {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String otherUserName;
  final String? otherUserPhoto;
  final List<String> otherUserVibes;

  ConversationEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.otherUserName,
    this.otherUserPhoto,
    this.otherUserVibes = const [],
  });
}
