import 'package:equatable/equatable.dart';
import 'package:shakr/common/constants/app_enums.dart';

enum SettingsStatus { initial, loading, loaded, error, saved, accountDeleted }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final List<String> selectedVibes;
  final bool notificationsEnabled;
  final ShakeSensitivity shakeSensitivity;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.selectedVibes = const [],
    this.notificationsEnabled = true,
    this.shakeSensitivity = ShakeSensitivity.normal,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    List<String>? selectedVibes,
    bool? notificationsEnabled,
    ShakeSensitivity? shakeSensitivity,
    String? errorMessage,
  }) => SettingsState(
    status: status ?? this.status,
    selectedVibes: selectedVibes ?? this.selectedVibes,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    selectedVibes,
    notificationsEnabled,
    shakeSensitivity,
    errorMessage,
  ];
}
