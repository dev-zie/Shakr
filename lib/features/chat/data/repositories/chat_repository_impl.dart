import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:shakr/features/chat/data/models/conversation_model.dart';
import 'package:shakr/features/chat/domain/entities/conversation_entity.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, void>> sendMessage(
    String id,
    MessageEntity message, {
    bool isPermanent = false,
  }) async {
    try {
      await remoteDatasource.sendMessage(id, message, isPermanent: isPermanent);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessage(
    String id, {
    bool isPermanent = false,
  }) {
    return remoteDatasource.watchMessage(id, isPermanent: isPermanent);
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await remoteDatasource.deleteConversation(conversationId);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Stream<Either<Failure, List<ConversationEntity>>> watchConversations(
    String uid,
  ) {
    return remoteDatasource.watchConversations(uid).map((list) {
      try {
        final conversations = list.map((m) {
          final isUser1 = m['user1'] == uid;
          final otherName = isUser1
              ? (m['user2Name'] ?? '')
              : (m['user1Name'] ?? '');
          final otherPhoto = isUser1 ? m['user2Photo'] : m['user1Photo'];
          final otherVibes = List<String>.from(
            isUser1 ? (m['user2Vibes'] ?? []) : (m['user1Vibes'] ?? []),
          );

          return ConversationModel(
            id: m['id'],
            participants: List<String>.from(m['participants'] ?? []),
            lastMessage: m['lastMessage'] ?? '',
            lastMessageAt: (m['lastMessageAt'] as Timestamp).toDate(),
            otherUserName: otherName,
            otherUserPhoto: otherPhoto,
            otherUserVibes: otherVibes,
          );
        }).toList();
        return Right(conversations);
      } catch (e) {
        return Left(UnexpectedFailure());
      }
    });
  }
}
