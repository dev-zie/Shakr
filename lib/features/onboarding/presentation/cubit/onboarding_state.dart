import 'package:equatable/equatable.dart';

class OnboardingState {}

class OnboardingInitial extends OnboardingState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class OnboardingStepChanged extends OnboardingState with EquatableMixin {
  final int step;
  final String name;
  final int? age;
  final String? gender;
  final String? photoUrl;
  final List<String> vibes;

  OnboardingStepChanged({
    required this.step,
    this.name = '',
    this.age,
    this.gender,
    this.photoUrl,
    this.vibes = const [],
  });

  OnboardingStepChanged copyWith({
    int? step,
    String? name,
    int? age,
    String? gender,
    String? photoUrl,
    List<String>? vibes,
  }) {
    return OnboardingStepChanged(
      step: step ?? this.step,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      vibes: vibes ?? this.vibes,
    );
  }

  @override
  List<Object?> get props => [step, name, age, gender, photoUrl, vibes];
}

class OnboardingCompleted extends OnboardingState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class OnboardingError extends OnboardingState with EquatableMixin {
  final String message;
  OnboardingError({required this.message});
  @override
  List<Object?> get props => [message];
}
