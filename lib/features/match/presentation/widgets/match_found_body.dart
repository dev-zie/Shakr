import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchFoundBody extends StatelessWidget {
  const MatchFoundBody({
    super.key,
    required this.otherUserVibes,
    required this.matchId,
    required this.createdAt,
  });
  final List otherUserVibes;
  final String matchId;
  final DateTime createdAt;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Esleme Bulundu!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: otherUserVibes
                .map((vibe) => Chip(label: Text(vibe)))
                .toList(),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => context.go('/chat/$matchId', extra: createdAt),
            child: const Text('Sohbete Basla'),
          ),
        ],
      ),
    );
  }
}
