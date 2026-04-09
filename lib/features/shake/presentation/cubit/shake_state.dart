import 'package:equatable/equatable.dart';

class ShakeState {}

class ShakeInitial extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ShakeDetected extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ShakeRecorded extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ShakeNoMatch extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ShakeError extends ShakeState with EquatableMixin {
  final String message;

  ShakeError(this.message);

  @override
  List<Object?> get props => [message];
}
