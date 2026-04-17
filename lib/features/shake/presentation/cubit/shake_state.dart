import 'package:equatable/equatable.dart';

class ShakeState {}

class ShakeInitial extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ShakeDetected extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

/// GPS izni reddedildi; IP bazlı şehir düzeyinde konum kullanıldı.
/// UI bu state'te kullanıcıyı uyarır, sallama akışı yine de devam eder.
class ShakeRecorded extends ShakeState with EquatableMixin {
  final bool isFallbackLocation;

  ShakeRecorded({this.isFallbackLocation = false});

  @override
  List<Object?> get props => [isFallbackLocation];
}

class ShakeNoMatch extends ShakeState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class ShakeError extends ShakeState with EquatableMixin {
  final String message;

  ShakeError(this.message);

  @override
  List<Object?> get props => [message];
}
