import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
import 'package:shakr/features/shake/presentation/widgets/searching_body.dart';
import 'package:shakr/features/shake/presentation/widgets/shake_body.dart';

class ShakingBody extends StatelessWidget {
  final ShakeState state;

  const ShakingBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is ShakeInitial) return const ShakeBody();
    if (state is ShakeDetected || state is ShakeRecorded) {
      return const SearchingBody();
    }
    if (state is ShakeError) {
      final msg = (state as ShakeError).message;
      return Center(child: Text(msg));
    }
    if (state is ShakeNoMatch) {
      return const Center(child: Text(AppStrings.matchNotFound));
    }
    return const SizedBox();
  }
}
