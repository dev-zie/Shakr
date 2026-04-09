class MatchEntity {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final List<String> user1Vibes;
  final List<String> user2Vibes;
  final DateTime createdAt;
  final String status;

  MatchEntity({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    required this.status,
    required this.user1Vibes,
    required this.user2Vibes,
  });
}
