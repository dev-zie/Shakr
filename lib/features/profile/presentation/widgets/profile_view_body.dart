import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'profile_avatar.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Center(child: ProfileAvatar(photoUrl: user.photoUrl)),
        const SizedBox(height: AppSpacing.l),
        Center(
          child: Text(
            user.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Center(
          child: Text(
            '${user.age} ${AppStrings.yearsOld} • ${user.gender}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(AppStrings.vibes, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: user.vibes
              .map(
                (vibe) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    vibe,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
