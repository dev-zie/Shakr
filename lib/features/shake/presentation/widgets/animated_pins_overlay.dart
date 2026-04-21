import 'package:flutter/material.dart';
import 'package:shakr/features/shake/presentation/widgets/floating_pin.dart';

class AnimatedPinsOverlay extends StatelessWidget {
  const AnimatedPinsOverlay({super.key});

  static const _delays = [
    Duration(milliseconds: 0),
    Duration(milliseconds: 700),
    Duration(milliseconds: 1400),
    Duration(milliseconds: 300),
    Duration(milliseconds: 1100),
    Duration(milliseconds: 600),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          for (var i = 0; i < _delays.length; i++)
            FloatingPin(initialDelay: _delays[i]),
        ],
      ),
    );
  }
}
