import 'package:equatable/equatable.dart';

class SettingsState {}

class SettingsInitial extends SettingsState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class SettingsLoading extends SettingsState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsState with EquatableMixin {
  final List<String> selectedVibes;
  SettingsLoaded(this.selectedVibes);
  @override
  List<Object?> get props => [selectedVibes];
}

class SettingsError extends SettingsState with EquatableMixin {
  final String message;
  SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SettingsSaved extends SettingsState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
