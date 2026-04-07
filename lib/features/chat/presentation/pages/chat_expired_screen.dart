import 'package:flutter/material.dart';

class ChatExpiredScreen extends StatelessWidget {
  final String matchId;
  const ChatExpiredScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Chat Expired Screen')));
  }
}
