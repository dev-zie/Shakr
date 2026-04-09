import 'package:equatable/equatable.dart';

class OnboardingState {}

class OnboardingInitial extends OnboardingState with EquatableMixin {
  @override
  List<Object?> get props => [];

}

class OnboardingVibeSelected extends OnboardingState with EquatableMixin {
  final List<String> selectedVibes;

  OnboardingVibeSelected({required this.selectedVibes});

  @override
  List<Object?> get props => [selectedVibes];
}

class OnboardingCompleted extends OnboardingState with EquatableMixin {
  final List<String> selectedVibes;

  OnboardingCompleted({required this.selectedVibes});

  @override
  List<Object?> get props => [selectedVibes];
}

class OnboardingError extends OnboardingState with EquatableMixin {
  final String message;

  OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}
