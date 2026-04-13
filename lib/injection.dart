import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/shake_service.dart';
import 'package:shakr/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shakr/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';
import 'package:shakr/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/get_user_vibes_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/save_vibes_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:shakr/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:shakr/features/chat/domain/repositories/chat_repository.dart';
import 'package:shakr/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:shakr/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:shakr/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:shakr/features/match/data/datasources/match_remote_datasource.dart';
import 'package:shakr/features/match/data/repositories/match_repository_impl.dart';
import 'package:shakr/features/match/domain/repositories/match_repository.dart';
import 'package:shakr/features/match/domain/usecases/delete_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/expire_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/get_match_usecase.dart';
import 'package:shakr/features/match/domain/usecases/keep_connection_usecase.dart';
import 'package:shakr/features/match/domain/usecases/watch_match_usecase.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:shakr/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shakr/features/shake/data/datasources/shake_remote_datasource.dart';
import 'package:shakr/features/shake/data/repositories/shake_repository_impl.dart';
import 'package:shakr/features/shake/domain/repositories/shake_repository.dart';
import 'package:shakr/features/shake/domain/usecases/delete_shake_usecase.dart';
import 'package:shakr/features/shake/domain/usecases/record_shake_usecase.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => LocalStorageService());

  //auth
  sl.registerLazySingleton(
    () => AuthRemoteDatasource(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => GetCurrentUserUsecase(repo: sl()));
  sl.registerLazySingleton(() => SignInAnonymouslyUsecase(repo: sl()));
  sl.registerLazySingleton(() => SaveVibesUsecase(repo: sl()));
  sl.registerLazySingleton(() => GetUserVibesUsecase(repo: sl()));
  sl.registerLazySingleton(
    () =>
        AuthCubit(getCurrentUserUsecase: sl(), signInAnonymouslyUsecase: sl()),
  );

  //onboard
  sl.registerLazySingleton(
    () => OnboardingCubit(lsc: sl(), saveVibesUsecase: sl()),
  );

  // Shake
  sl.registerLazySingleton(() => ShakeRemoteDatasource(db: sl()));
  sl.registerLazySingleton<ShakeRepository>(
    () => ShakeRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => RecordShakeUsecase(repo: sl()));
  sl.registerLazySingleton(() => DeleteShakeUsecase(repo: sl()));
  sl.registerLazySingleton(
    () => ShakeCubit(recordShakeUsecase: sl(), deleteShakeUsecase: sl()),
  );
  sl.registerLazySingleton(() => ShakeService());

  sl.registerLazySingleton(() => LocationService());

  // Match
  sl.registerLazySingleton(() => MatchRemoteDatasource(db: sl()));
  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => WatchMatchUsecase(repo: sl()));
  sl.registerLazySingleton(() => GetMatchUsecase(repo: sl()));
  sl.registerLazySingleton(() => KeepConnectionUsecase(repo: sl()));
  sl.registerLazySingleton(() => ExpireMatchUsecase(repo: sl()));
  sl.registerLazySingleton(() => DeleteMatchUsecase(repo: sl()));

  sl.registerLazySingleton(
    () => MatchCubit(
      watchMatchUsecase: sl(),
      getMatchUsecase: sl(),
      keepConnectionUsecase: sl(),
      deleteMatchUsecase: sl(),
      expireMatchUsecase: sl(),
    ),
  );

  // Chat
  sl.registerLazySingleton(() => ChatRemoteDatasource(db: sl()));
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton(() => SendMessageUsecase(repo: sl()));
  sl.registerLazySingleton(() => WatchMessagesUsecase(repo: sl()));

  sl.registerLazySingleton(
    () => ChatCubit(sendMessageUsecase: sl(), watchMessagesUsecase: sl()),
  );

  //settings
  sl.registerFactory(
    () => SettingsCubit(getUserVibesUsecase: sl(), saveVibesUsecase: sl()),
  );
}
