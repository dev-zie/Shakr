import 'package:equatable/equatable.dart';
import 'package:shakr/features/match/domain/entities/match_entity.dart';

enum MatchCubitStatus {
  initial,
  loading,
  found,
  notFound,
  error,
  expired,
  deleted,
  bothKept,
  connectionPending,
  acceptancePending,
  accepted,
  cooldownActive,
}

class MatchState extends Equatable {
  final MatchCubitStatus status;
  final MatchEntity? match;
  final String? errorMessage;

  const MatchState({
    this.status = MatchCubitStatus.initial,
    this.match,
    this.errorMessage,
  });

  MatchState copyWith({
    MatchCubitStatus? status,
    MatchEntity? match,
    String? errorMessage,
  }) => MatchState(
    status: status ?? this.status,
    match: match ?? this.match,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, match, errorMessage];
}
