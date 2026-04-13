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
import 'package:shakr/features/shake/presentation/widgets/searching_body.dart';
import 'package:shakr/features/shake/presentation/widgets/shake_body.dart';
import 'package:shakr/injection.dart';

class ShakingScreen extends StatefulWidget {
  const ShakingScreen({super.key});

  @override
  State<ShakingScreen> createState() => _ShakingScreenState();
}

class _ShakingScreenState extends State<ShakingScreen> {
  @override
  void initState() {
    super.initState();
    sl<ShakeCubit>().init();
  }

  @override
  void dispose() {
    sl<ShakeCubit>().disposeScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GoBackButton(onPressed: () => context.go('/home')),
      ),
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state is MatchFound) {
            sl<ShakeCubit>().cancelMatchTimer();
            context.go('/match/${state.match.matchId}');
          }
        },
        child: BlocConsumer<ShakeCubit, ShakeState>(
          bloc: sl<ShakeCubit>(),
          listener: (context, state) {
            if (state is ShakeRecorded) {
              sl<ShakeCubit>().startMatchTimer(() {
                if (!context.mounted) return;
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text(AppStrings.matchNotFound),
                    content: const Text(AppStrings.noBodyFound),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text(AppStrings.okay),
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/home');
                        },
                      ),
                    ],
                  ),
                );
              });
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
