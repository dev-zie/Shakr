import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  Timer? _matchTimer;

  @override
  void initState() {
    super.initState();
    sl<MatchCubit>().reset();
    sl<ShakeCubit>().reset();
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

  void _startMatchTimer() {
    _matchTimer?.cancel();
    _matchTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Esleme Bulunamadi'),
          content: const Text('Yakininda kimse bulunamadi. Tekrar dene!'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.pop(context);
                sl<ShakeCubit>().deleteShake(
                  FirebaseAuth.instance.currentUser?.uid ?? '',
                );
                context.go('/home');
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    sl<ShakeService>().stopListening();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      sl<ShakeCubit>().deleteShake(uid);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            sl<ShakeService>().stopListening();
            context.go('/home');
          },
        ),
      ),
      body: BlocListener<MatchCubit, MatchState>(
        bloc: sl<MatchCubit>(),
        listener: (context, state) {
          if (state is MatchFound) {
            _matchTimer?.cancel();
            sl<ShakeService>().stopListening();
            context.go('/match/${state.match.matchId}');
          }
        },
        child: BlocConsumer<ShakeCubit, ShakeState>(
          bloc: sl<ShakeCubit>(),
          listener: (context, state) {
            if (state is ShakeRecorded) {
              _startMatchTimer();
            }
          },
          builder: (context, state) {
            if (state is ShakeInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Telefonunu salla!'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return;
                        final location = await sl<LocationService>()
                            .getCurrentLocation();
                        final shake = ShakeEntity(
                          uid: uid,
                          location: location,
                          status: 'waiting',
                          timestamp: DateTime.now(),
                        );
                        sl<ShakeCubit>().recordShake(shake);
                      },
                      child: const Text('TEST: Salla'),
                    ),
                  ],
                ),
              );
            }
            if (state is ShakeDetected || state is ShakeRecorded) {
              return const Center(
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
              return const Center(child: Text('Kimse bulunamadi'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
