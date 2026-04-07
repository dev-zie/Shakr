import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends UserEntity {
  UserModel({required super.uid, required super.vibes});

  factory UserModel.fromFirebase(User user) {
    return UserModel(uid: user.uid, vibes: []);
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'vibes': vibes};
  }
}
