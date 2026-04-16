import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primary => [
        BoxShadow(
          color: const Color(0xFF7C77EC).withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}
