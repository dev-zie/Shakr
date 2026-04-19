import 'package:equatable/equatable.dart';

enum ShakeCubitStatus { initial, detected, recorded, noMatch, error }

class ShakeState extends Equatable {
  final ShakeCubitStatus status;
  final String? errorMessage;

  const ShakeState({this.status = ShakeCubitStatus.initial, this.errorMessage});

  ShakeState copyWith({ShakeCubitStatus? status, String? errorMessage}) =>
      ShakeState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, errorMessage];
}
