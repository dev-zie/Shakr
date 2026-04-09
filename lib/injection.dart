import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shakr/core/services/local_storage_service.dart';
import 'package:shakr/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shakr/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shakr/features/auth/domain/repositories/auth_repository.dart';
import 'package:shakr/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/onboarding/presentation/cubit/onboarding_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => LocalStorageService());

  sl.registerLazySingleton(
    () => AuthRemoteDatasource(firebaseAuth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => GetCurrentUserUsecase(repo: sl()));
  sl.registerLazySingleton(() => SignInAnonymouslyUsecase(repo: sl()));

  sl.registerLazySingleton(
    () =>
        AuthCubit(getCurrentUserUsecase: sl(), signInAnonymouslyUsecase: sl()),
  );

  sl.registerLazySingleton(() => OnboardingCubit(lsc: sl()));
}
