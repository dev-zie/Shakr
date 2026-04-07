import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String matchId;
  const ChatScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('chat Screen')));
  }
}
