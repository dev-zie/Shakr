import 'package:equatable/equatable.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class AuthSucces extends AuthState with EquatableMixin {
  final UserEntity user;

  AuthSucces(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState with EquatableMixin {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
