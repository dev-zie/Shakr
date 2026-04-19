import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, loaded, error, saved, accountDeleted }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final List<String> selectedVibes;
  final bool notificationsEnabled;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.selectedVibes = const [],
    this.notificationsEnabled = true,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    List<String>? selectedVibes,
    bool? notificationsEnabled,
    String? errorMessage,
  }) => SettingsState(
    status: status ?? this.status,
    selectedVibes: selectedVibes ?? this.selectedVibes,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, selectedVibes, notificationsEnabled, errorMessage];
}
