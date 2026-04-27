enum Gender { male, female, other }

enum ShakeSensitivity {
  hassas(10.0),
  normal(15.0),
  sert(22.0);

  final double threshold;
  const ShakeSensitivity(this.threshold);
}

enum ShakeStatus { waiting, matched, expired }

enum MatchStatus { active, expired, deleted }

enum ChatStatus { active, expired }
