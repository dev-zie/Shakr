import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:shakr/core/error/failures.dart';
import 'package:shakr/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:shakr/features/chat/domain/entities/message_entity.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, void>> sendMessage(
    String matchId,
    MessageEntity message,
  ) async {
    try {
      await remoteDatasource.sendMessage(matchId, message);
      return Right(unit);
    } on SocketException {
      return Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessage(String matchId) {
    return remoteDatasource.watchMessage(matchId);
  }
}
