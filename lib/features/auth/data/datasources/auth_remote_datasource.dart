import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shakr/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDatasource({required this.firebaseAuth, required this.firestore});

  Future<UserModel> signInAnonymously() async {
    var userCredential = await firebaseAuth.signInAnonymously();
    return UserModel.fromFirebase(userCredential.user!);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebase(user);
  }
}
