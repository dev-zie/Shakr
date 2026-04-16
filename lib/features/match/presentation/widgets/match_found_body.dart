import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shakr/features/match/presentation/cubit/match_cubit.dart';
import 'package:shakr/common/getit/injection.dart';

class MatchFoundBody extends StatefulWidget {
  const MatchFoundBody({
    super.key,
    required this.otherUserVibes,
    required this.matchId,
    required this.createdAt,
    this.isPending = false,
  });

  final List<String> otherUserVibes;
  final String matchId;
  final DateTime createdAt;
  final bool isPending;

  @override
  State<MatchFoundBody> createState() => _MatchFoundBodyState();
}

class _MatchFoundBodyState extends State<MatchFoundBody> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _secondsRemaining = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..reverse(from: 1.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        sl<MatchCubit>().deleteMatch(widget.matchId);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.matchFound,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Karşı tarafın modları:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              alignment: WrapAlignment.center,
              children: widget.otherUserVibes
                  .map((vibe) => Chip(
                        label: Text(vibe),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      );
                    },
                  ),
                ),
                Text(
                  '$_secondsRemaining',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (widget.isPending) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.m),
              const Text(
                AppStrings.waitDecision,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  final uid = sl<AuthCubit>().currentUid;
                  if (uid != null) {
                    sl<MatchCubit>().acceptMatch(widget.matchId, uid);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.m),
                  ),
                ),
                child: const Text(AppStrings.startChat),
              ),
              const SizedBox(height: AppSpacing.m),
              TextButton(
                onPressed: () => sl<MatchCubit>().deleteMatch(widget.matchId),
                child: const Text(
                  'İptal Et',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
