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
  final bool notificationsEnabled;
  
  SettingsLoaded({
    required this.selectedVibes,
    required this.notificationsEnabled,
  });

  SettingsLoaded copyWith({
    List<String>? selectedVibes,
    bool? notificationsEnabled,
  }) {
    return SettingsLoaded(
      selectedVibes: selectedVibes ?? this.selectedVibes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [selectedVibes, notificationsEnabled];
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

class SettingsAccountDeleted extends SettingsState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
