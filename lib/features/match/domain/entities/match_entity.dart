
class MatchEntity {
    final String matchId;

  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final String status;

  MatchEntity({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.status,
  });
}
