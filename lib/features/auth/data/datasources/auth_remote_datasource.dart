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

  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final batch = firestore.batch();

    final matches = await firestore
        .collection('matches')
        .where('users', arrayContains: uid)
        .get();

    for (var doc in matches.docs) {
      final messages = await doc.reference.collection('messages').get();
      for (var msg in messages.docs) {
        batch.delete(msg.reference);
      }
      batch.delete(doc.reference);

      final chatRef = firestore.collection('chats').doc(doc.id);
      final chatMessages = await chatRef.collection('messages').get();
      for (var msg in chatMessages.docs) {
        batch.delete(msg.reference);
      }
      batch.delete(chatRef);
    }

    final conversations = await firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .get();

    for (var doc in conversations.docs) {
      final messages = await doc.reference.collection('messages').get();
      for (var msg in messages.docs) {
        batch.delete(msg.reference);
      }
      batch.delete(doc.reference);
    }

    batch.delete(firestore.collection('users').doc(uid));

    await batch.commit();

    await user.delete();
  }
}
