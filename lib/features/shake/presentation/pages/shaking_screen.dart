import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
import 'package:shakr/features/shake/presentation/widgets/match_not_found_dialog.dart';
import 'package:shakr/features/shake/presentation/widgets/shaking_body.dart';
import 'package:shakr/common/getit/injection.dart';

class ShakingScreen extends StatelessWidget {
  const ShakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state is MatchFound) {
            sl<ShakeCubit>().disposeScreen();
            context.go('/match/${state.match.matchId}');
          }
        },
        child: BlocConsumer<ShakeCubit, ShakeState>(
          bloc: sl<ShakeCubit>(),
          listener: (context, state) {
            if (state is ShakeNoMatch) {
              showCupertinoDialog(
                context: context,
                builder: (context) => const MatchNotFoundDialog(),
              );
            }
            if (state is ShakeRecorded && state.isFallbackLocation) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.locationFallbackWarning)),
              );
            }
          },
          builder: (context, state) {
            return ShakingBody(state: state);
          },
        ),
      ),
    );
  }
}
