import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);
  void goToShake() => emit(0);
  void goToChats() => emit(1);
  void goToProfile() => emit(2);
}
