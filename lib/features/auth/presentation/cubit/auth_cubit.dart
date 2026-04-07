import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shakr/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final SignInAnonymouslyUsecase signInAnonymouslyUsecase;
  AuthCubit({
    required this.getCurrentUserUsecase,
    required this.signInAnonymouslyUsecase,
  }) : super(AuthInitial());

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    final user = await getCurrentUserUsecase.call();

    user.fold(
      (l) => emit(AuthError(l.message)),
      (user) => emit(AuthSucces(user)),
    );
  }

  Future<void> signInAnonymously() async {
    emit(AuthLoading());
    final result = await signInAnonymouslyUsecase.call();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSucces(user)),
    );
  }
}
