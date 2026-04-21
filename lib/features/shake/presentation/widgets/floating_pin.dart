import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_assets.dart';

class FloatingPin extends StatefulWidget {
  final Duration initialDelay;

  const FloatingPin({super.key, required this.initialDelay});

  @override
  State<FloatingPin> createState() => _FloatingPinState();
}

class _FloatingPinState extends State<FloatingPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  final _rng = Random();
  double _dx = 0;
  double _dy = 0;

  @override
  void initState() {
    super.initState();
    _randomize();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
    ]).animate(_controller);

    _controller.addStatusListener(_onStatusChanged);

    Future.delayed(widget.initialDelay, () {
      if (mounted) _controller.forward();
    });
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(_randomize);
      Future.delayed(Duration(milliseconds: _rng.nextInt(2000) + 100), () {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  void _randomize() {
    _dx = (_rng.nextDouble() * 1.7) - 0.85;
    _dy = (_rng.nextDouble() * 1.7) - 0.85;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(_dx, _dy),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scale.value.clamp(0.0, 2.0),
            child: child,
          ),
        ),
        child: Image.asset(AppAssets.locationPin, width: 46, height: 46),
      ),
    );
  }
}
