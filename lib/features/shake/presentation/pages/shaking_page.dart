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

class ShakingPage extends StatelessWidget {
  const ShakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.shakeString)),
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state.status == MatchCubitStatus.found) {
            sl<ShakeCubit>().disposeScreen();
            context.go('/match/${state.match!.matchId}');
          }
        },
        child: BlocConsumer<ShakeCubit, ShakeState>(
          bloc: sl<ShakeCubit>(),
          listener: (context, state) {
            if (state.status == ShakeCubitStatus.noMatch) {
              showCupertinoDialog(
                context: context,
                builder: (context) => const MatchNotFoundDialog(),
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
