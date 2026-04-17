import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/constants/app_spacing.dart';
import 'package:shakr/common/constants/app_strings.dart';
import 'package:shakr/common/theme/app_colors.dart';
import 'package:shakr/features/auth/domain/entities/user_entity.dart';
import 'package:shakr/features/profile/presentation/cubit/profile_cubit.dart';
import 'profile_avatar.dart';
import 'vibe_card.dart';

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
            '${user.age} ${AppStrings.yearsOld} • ${user.gender}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
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
        const SizedBox(height: AppSpacing.xxl),
        const Divider(),
        const SizedBox(height: AppSpacing.l),

        // Hesabı Sil Butonu
        ListTile(
          leading: const Icon(LucideIcons.trash2, color: AppColors.error),
          title: const Text(
            'Hesabı Sil',
            style: TextStyle(color: AppColors.error),
          ),
          trailing: const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.error,
          ),
          onTap: () => _showDeleteAccountDialog(context),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Hesabı Sil',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'Hesabını ve tüm geçmişini silmek istediğinden emin misin? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProfileCubit>().deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );
  }
}
