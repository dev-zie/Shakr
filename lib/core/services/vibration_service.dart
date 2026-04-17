import 'package:vibration/vibration.dart';

class VibrationService {
  Future<void> shakeFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }
  }

  Future<void> shakeRecordedFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100); // Kısa tek titreşim
    }
  }

  Future<void> matchFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 300, 200, 300]); // İki kez
    }
  }

  Future<void> matchAcceptedFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 150, 100, 150]);
    }
  }

  Future<void> chatStartedFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }
  }

  Future<void> endFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 150);
    }
  }
}
