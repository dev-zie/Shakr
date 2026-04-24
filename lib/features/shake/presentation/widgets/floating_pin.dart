import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakr/common/constants/app_assets.dart';
import 'package:shakr/features/shake/presentation/cubit/floating_pin_cubit.dart';

class FloatingPin extends StatelessWidget {
  final Duration initialDelay;

  const FloatingPin({super.key, required this.initialDelay});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FloatingPinCubit(initialDelay),
      child: BlocBuilder<FloatingPinCubit, FloatingPinState>(
        builder: (context, state) {
          final cubit = context.read<FloatingPinCubit>();
          return Align(
            alignment: Alignment(state.dx, state.dy),
            child: AnimatedBuilder(
              animation: cubit.controller,
              builder: (context, child) => Opacity(
                opacity: cubit.opacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: cubit.scale.value.clamp(0.0, 2.0),
                  child: child,
                ),
              ),
              child: Image.asset(AppAssets.locationPin, width: 46, height: 46),
            ),
          );
        },
      ),
    );
  }
}
