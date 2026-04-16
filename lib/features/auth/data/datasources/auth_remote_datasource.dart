import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shakr/features/auth/data/models/user_model.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';

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

  Future<void> saveVibes(String uid, List<String> vibes) async {
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'vibes': vibes,
    });
  }

  Future<List<String>> getUserVibes(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    return List<String>.from(data['vibes'] ?? []);
  }

  Future<void> saveProfile(UserEntity user) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .set(
          UserModel(
            uid: user.uid,
            name: user.name,
            age: user.age,
            gender: user.gender,
            photoUrl: user.photoUrl,
            vibes: user.vibes,
          ).toMap(),
        );
  }

  Future<UserEntity?> getProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<String> uploadPhoto(String uid, String filePath) async {
    final ref = FirebaseStorage.instance.ref().child('profile_photos/$uid');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
