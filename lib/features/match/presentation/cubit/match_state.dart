import 'package:equatable/equatable.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

class MatchState {}

class MatchInitial extends MatchState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class MatchLoading extends MatchState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class MatchFound extends MatchState with EquatableMixin {
  final MatchEntity match;

  MatchFound(this.match);

  @override
  List<Object?> get props => [match];
}

class MatchNotFound extends MatchState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class MatchError extends MatchState with EquatableMixin {
  final String message;

  MatchError(this.message);

  @override
  List<Object?> get props => [message];
}

class MatchExpired extends MatchState with EquatableMixin {
  final MatchEntity match;
  MatchExpired(this.match);
  @override
  List<Object?> get props => [match];
}

class MatchDeleted extends MatchState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class MatchBothKept extends MatchState with EquatableMixin {
  final MatchEntity match;
  MatchBothKept(this.match);
  @override
  List<Object?> get props => [match];
}

/// Kullanıcı bağlantıyı korumak istedi ama karşı taraf henüz karar vermedi.
class MatchConnectionPending extends MatchState with EquatableMixin {
  final MatchEntity match;
  MatchConnectionPending(this.match);
  @override
  List<Object?> get props => [match];
}

/// Kullanıcı sohbete başlamayı kabul etti ama karşı taraf henüz karar vermedi.
class MatchAcceptancePending extends MatchState with EquatableMixin {
  final MatchEntity match;
  MatchAcceptancePending(this.match);
  @override
  List<Object?> get props => [match];
}

/// Her iki taraf da sohbete başlamayı kabul etti.
class MatchAccepted extends MatchState with EquatableMixin {
  final MatchEntity match;
  MatchAccepted(this.match);
  @override
  List<Object?> get props => [match];
}
