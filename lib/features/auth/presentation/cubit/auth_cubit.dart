import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/save_profile_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final SignInAnonymouslyUsecase signInAnonymouslyUsecase;
  final SaveProfileUsecase saveProfileUsecase;
  final GetProfileUsecase getProfileUsecase;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  AuthCubit({
    required this.getCurrentUserUsecase,
    required this.signInAnonymouslyUsecase,
    required this.saveProfileUsecase,
    required this.getProfileUsecase,
  }) : super(const AuthState());

  Future<void> getCurrentUser() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await getCurrentUserUsecase.call();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, message: failure.message)),
      (user) => emit(state.copyWith(status: AuthStatus.success, user: user)),
    );
  }

  Future<void> signInAnonymously() async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await signInAnonymouslyUsecase.call();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, message: failure.message)),
      (user) => emit(state.copyWith(status: AuthStatus.success, user: user)),
    );
  }

  Future<void> saveProfile(UserEntity user) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await saveProfileUsecase.call(user);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, message: failure.message)),
      (r) => emit(state.copyWith(status: AuthStatus.profileSaved, user: user)),
    );
  }

  Future<void> getProfile(String uid) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await getProfileUsecase.call(uid);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, message: failure.message)),
      (user) => emit(state.copyWith(status: AuthStatus.success, user: user)),
    );
  }

  
}
