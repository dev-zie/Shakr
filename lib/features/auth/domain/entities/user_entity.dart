class UserEntity {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String? photoUrl;
  final List<String> vibes;

  UserEntity({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    this.photoUrl,
    required this.vibes,
  });

  UserEntity copyWith({
    String? uid,
    String? name,
    int? age,
    String? gender,
    String? photoUrl,
    List<String>? vibes,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      vibes: vibes ?? this.vibes,
    );
  }
}
