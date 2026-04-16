import 'package:firebase_auth/firebase_auth.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.name,
    required super.age,
    required super.gender,
    super.photoUrl,
    required super.vibes,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      name: '',
      age: 0,
      gender: '',
      photoUrl: null,
      vibes: [],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      photoUrl: map['photoUrl'],
      vibes: List<String>.from(map['vibes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'photoUrl': photoUrl,
      'vibes': vibes,
    };
  }
}
