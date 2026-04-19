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
    if (state.status == ShakeCubitStatus.initial) return const ShakeBody();
    if (state.status == ShakeCubitStatus.detected ||
        state.status == ShakeCubitStatus.recorded) {
      return const SearchingBody();
    }
    if (state.status == ShakeCubitStatus.error) {
      return Center(child: Text(state.errorMessage ?? ''));
    }
    if (state.status == ShakeCubitStatus.noMatch) {
      return const Center(child: Text(AppStrings.matchNotFound));
    }
    return const SizedBox();
  }
}
