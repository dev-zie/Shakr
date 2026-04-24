import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/core/services/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final LocalStorageService localStorageService;

  ThemeCubit({required this.localStorageService}) : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final isDark = await localStorageService.getDarkMode();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggle(bool isDark) async {
    await localStorageService.setDarkMode(isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
