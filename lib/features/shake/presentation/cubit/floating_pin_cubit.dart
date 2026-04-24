import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FloatingPinState {
  final double dx;
  final double dy;

  const FloatingPinState({required this.dx, required this.dy});
}

// AnimationController'ın ihtiyaç duyduğu TickerProvider'ı
// State olmadan sağlar. Widget ağacından bağımsız çalışır.
class _SingleTicker implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class FloatingPinCubit extends Cubit<FloatingPinState> {
  late final AnimationController controller;
  late final Animation<double> opacity;
  late final Animation<double> scale;
  final _rng = Random();

  FloatingPinCubit(Duration initialDelay)
      : super(const FloatingPinState(dx: 0, dy: 0)) {
    randomize();

    controller = AnimationController(
      vsync: _SingleTicker(),
      duration: const Duration(milliseconds: 5000),
    );

    opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(controller);

    scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
    ]).animate(controller);

    controller.addStatusListener(_onStatusChanged);

    Future.delayed(initialDelay, () {
      if (!isClosed) controller.forward();
    });
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      randomize();
      Future.delayed(Duration(milliseconds: _rng.nextInt(2000) + 100), () {
        if (!isClosed) controller.forward(from: 0);
      });
    }
  }

  void randomize() {
    emit(FloatingPinState(
      dx: (_rng.nextDouble() * 1.7) - 0.85,
      dy: (_rng.nextDouble() * 1.7) - 0.85,
    ));
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
