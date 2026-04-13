import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
import 'package:shakr/features/shake/presentation/widgets/go_back_button.dart';
import 'package:shakr/features/shake/presentation/widgets/match_not_found_dialog.dart';
import 'package:shakr/features/shake/presentation/widgets/searching_body.dart';
import 'package:shakr/features/shake/presentation/widgets/shake_body.dart';
import 'package:shakr/injection.dart';

class ShakingScreen extends StatelessWidget {
  const ShakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GoBackButton(
          onPressed: () {
            sl<ShakeCubit>().disposeScreen();
            context.go('/home');
          },
        ),
      ),
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state is MatchFound) {
            sl<ShakeCubit>().disposeScreen();
            sl<MatchCubit>().init(state.match.matchId);
            context.go('/match/${state.match.matchId}');
          }
        },
        child: BlocConsumer<ShakeCubit, ShakeState>(
          bloc: sl<ShakeCubit>(),
          listener: (context, state) {
            if (state is ShakeRecorded) {
              sl<ShakeCubit>().startMatchTimer();
            }

            if (state is ShakeNoMatch) {
              showCupertinoDialog(
                context: context,
                builder: (context) => MatchNotFoundDialog(),
              );
            }
          },
          builder: (context, state) {
            if (state is ShakeInitial) return const ShakeBody();
            if (state is ShakeDetected || state is ShakeRecorded) {
              return const SearchingBody();
            }
            if (state is ShakeError) return Center(child: Text(state.message));
            if (state is ShakeNoMatch) {
              return const Center(child: Text(AppStrings.matchNotFound));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
