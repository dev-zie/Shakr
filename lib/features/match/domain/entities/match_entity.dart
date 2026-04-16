enum MatchStatus { active, expired, unknown }

extension MatchStatusExt on MatchStatus {
  String get name {
    switch (this) {
      case MatchStatus.active:
        return 'active';
      case MatchStatus.expired:
        return 'expired';
      default:
        return 'unknown';
    }
  }

  static MatchStatus fromString(String val) {
    switch (val) {
      case 'active':
        return MatchStatus.active;
      case 'expired':
        return MatchStatus.expired;
      default:
        return MatchStatus.unknown;
    }
  }
}

class MatchEntity {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final List<String> user1Vibes;
  final List<String> user2Vibes;
  final DateTime createdAt;
  final DateTime? chatStartedAt;
  final MatchStatus status;
  final bool user1KeepConnection;
  final bool user2KeepConnection;
  final bool user1Accepted;
  final bool user2Accepted;

  MatchEntity({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.chatStartedAt,
    required this.status,
    required this.user1Vibes,
    required this.user2Vibes,
    this.user1KeepConnection = false,
    this.user2KeepConnection = false,
    this.user1Accepted = false,
    this.user2Accepted = false,
  });
}

