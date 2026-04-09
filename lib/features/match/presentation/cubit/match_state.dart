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

