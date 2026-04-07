import 'package:flutter/material.dart';

class MatchFoundScreen extends StatelessWidget {
  final String matchId;
  const MatchFoundScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Match Found Screen'),
      ),
    );
  }
}