import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shakr/core/services/location_service.dart';
import 'package:shakr/core/services/shake_service.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_state.dart';
import 'package:shakr/features/shake/domain/entities/shake_entity.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_cubit.dart';
import 'package:shakr/features/shake/presentation/cubit/shake_state.dart';
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
    sl<ShakeService>().startListening(() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final location = await sl<LocationService>().getCurrentLocation();

      final shake = ShakeEntity(
        uid: uid,
        location: location,
        status: 'waiting',
        timestamp: DateTime.now(),
      );

      sl<ShakeCubit>().recordShake(shake);
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      sl<MatchCubit>().watchMatch(uid);
    }
  }

  @override
  void dispose() {
    sl<ShakeService>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state is MatchFound) {
            sl<ShakeService>().stopListening();
            context.go('/match/${state.match.matchId}');
          }
        },
        child: BlocConsumer<ShakeCubit, ShakeState>(
          bloc: sl<ShakeCubit>(),
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ShakeInitial) {
              return Center(child: Text('Telefonunu salla!'));
            }
            if (state is ShakeDetected || state is ShakeRecorded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 50),
                    Text('Araniyor..'),
                  ],
                ),
              );
            }
            if (state is ShakeError) {
              return Center(child: Text(state.message));
            }

            if (state is ShakeNoMatch) {
              return Center(child: Text('Kimse bulunamadi'));
            }

            return SizedBox();
          },
        ),
      ),
    );
  }
}
