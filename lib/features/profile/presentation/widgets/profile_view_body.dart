import 'package:flutter/material.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/extensions/gender_extension.dart';
import 'package:shakr/common/widgets/vibe_card.dart';
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
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Center(
          child: Text(
            '${user.age} ${AppStrings.yearsOld} • ${user.gender.toGenderLabel()}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(AppStrings.vibes, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.m),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: user.vibes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.s,
            crossAxisSpacing: AppSpacing.s,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            return VibeCard(vibe: user.vibes[index], isSelected: true);
          },
        ),
      ],
    );
  }
}
