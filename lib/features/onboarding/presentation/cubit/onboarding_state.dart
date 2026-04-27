import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, stepChanged, completed, error }

class OnboardingState extends Equatable {
  final OnboardingStatus status;
  final int step;
  final String name;
  final int? age;
  final String? gender;
  final String? photoUrl;
  final List<String> vibes;
  final int introPage;
  final bool introLastPageSeen;
  final String? errorMessage;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.step = 0,
    this.name = '',
    this.age,
    this.gender,
    this.photoUrl,
    this.vibes = const [],
    this.introPage = 0,
    this.introLastPageSeen = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? step,
    String? name,
    int? age,
    String? gender,
    String? photoUrl,
    List<String>? vibes,
    int? introPage,
    bool? introLastPageSeen,
    String? errorMessage,
  }) => OnboardingState(
    status: status ?? this.status,
    step: step ?? this.step,
    name: name ?? this.name,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    photoUrl: photoUrl ?? this.photoUrl,
    vibes: vibes ?? this.vibes,
    introPage: introPage ?? this.introPage,
    introLastPageSeen: introLastPageSeen ?? this.introLastPageSeen,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    step,
    name,
    age,
    gender,
    photoUrl,
    vibes,
    introPage,
    introLastPageSeen,
    errorMessage,
  ];
}
