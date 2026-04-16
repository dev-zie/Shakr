import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shakr/common/theme/app_colors.dart';

/// Hem view hem edit modunda kullanılan profil fotoğrafı widget'ı.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 60});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary50,
        image: photoUrl != null
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 3,
        ),
      ),
      child: photoUrl == null
          ? Icon(LucideIcons.user, size: radius * 0.8, color: AppColors.primary)
          : null,
    );
  }
}

